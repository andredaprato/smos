{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Smos.Sync.API where

import GHC.Generics (Generic)

import Data.Aeson as JSON
import Data.Aeson.Types as JSON
import Data.ByteString (ByteString)
import Data.ByteString.Base64 as Base64
import qualified Data.ByteString.Char8 as SB8
import qualified Data.ByteString.Lazy as LB
import qualified Data.Text as T
import qualified Data.UUID as UUID
import Data.UUID.Typed as UUID
import Data.Validity
import Data.Validity.ByteString ()
import Data.Validity.Path ()
import Data.Validity.UUID ()

import Path
import Path.Internal

import Database.Persist
import Database.Persist.Sql

import qualified Data.Mergeful as Mergeful
import Data.Mergeful.Timed

import Servant

type FileUUID = UUID SyncFile

data SyncServer

type ServerUUID = UUID SyncServer

instance FromJSONKey (Path Rel File) where
  fromJSONKey =
    FromJSONKeyTextParser $ \t ->
      case parseRelFile (T.unpack t) of
        Nothing -> fail "failed to parse relative file"
        Just rf -> pure rf

instance ToJSONKey (Path Rel File) where
  toJSONKey = toJSONKeyText $ T.pack . fromRelFile

deriving instance PersistFieldSql (Path Rel File) -- TODO Not entirely safe

deriving instance PersistField (Path Rel File) -- TODO Not entirely safe

deriving instance PersistFieldSql ServerTime

deriving instance PersistField ServerTime

instance PersistField (UUID a) where
  toPersistValue (UUID uuid) = PersistByteString $ LB.toStrict $ UUID.toByteString uuid
  fromPersistValue (PersistByteString bs) =
    case UUID.fromByteString $ LB.fromStrict bs of
      Nothing -> Left "Invalidy Bytestring to convert to UUID"
      Just uuid -> Right $ UUID uuid
  fromPersistValue pv = Left $ "Invalid Persist value to parse to UUID: " <> T.pack (show pv)

instance PersistFieldSql (UUID a) where
  sqlType Proxy = SqlBlob

data SyncFile =
  SyncFile
    { syncFilePath :: Path Rel File
    , syncFileContents :: ByteString
    }
  deriving (Show, Eq, Generic)

instance Validity SyncFile

instance FromJSON SyncFile where
  parseJSON =
    withObject "SyncFile" $ \o ->
      SyncFile <$> o .: "path" <*>
      (do base64Contents <- SB8.pack <$> o .: "contents"
          case Base64.decode base64Contents of
            Left err -> fail err
            Right r -> pure r)

instance ToJSON SyncFile where
  toJSON SyncFile {..} =
    object ["path" .= syncFilePath, "contents" .= SB8.unpack (Base64.encode syncFileContents)]

syncAPI :: Proxy SyncAPI
syncAPI = Proxy

type SyncRequest = Mergeful.SyncRequest FileUUID SyncFile

data SyncResponse =
  SyncResponse
    { syncResponseServerId :: ServerUUID
    , syncResponseItems :: Mergeful.SyncResponse FileUUID SyncFile
    }
  deriving (Show, Eq, Generic)

instance Validity SyncResponse

instance FromJSON SyncResponse where
  parseJSON = withObject "SyncResponse" $ \o -> SyncResponse <$> o .: "server-id" <*> o .: "items"

instance ToJSON SyncResponse where
  toJSON SyncResponse {..} =
    object ["server-id" .= syncResponseServerId, "items" .= syncResponseItems]

type SyncAPI = "sync" :> ReqBody '[ JSON] SyncRequest :> Post '[ JSON] SyncResponse
