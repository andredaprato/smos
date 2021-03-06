{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE OverloadedStrings #-}

module Smos.Query.Projects where

import Data.List
import Data.Text (Text)

import Conduit
import qualified Data.Conduit.List as C
import Rainbow

import Smos.Data

import Smos.Report.Filter
import Smos.Report.Projects
import Smos.Report.Streaming

import Smos.Query.Config
import Smos.Query.Formatting
import Smos.Query.OptParse.Types
import Smos.Query.Streaming

projects :: ProjectsSettings -> Q ()
projects ProjectsSettings {..} = do
  projs <-
    sourceToList $
    streamSmosProjects .| parseSmosFiles .| printShouldPrint PrintWarning .|
    smosMFilter (FilterFst <$> projectsSetFilter) .|
    C.map (uncurry makeProjectEntry)
  liftIO $
    putTableLn $ renderProjectsReport $ sortOn (fmap entryState . projectEntryCurrentEntry) projs

renderProjectsReport :: [ProjectEntry] -> Table
renderProjectsReport = formatAsTable . map renderProjectEntry

renderProjectEntry :: ProjectEntry -> [Chunk Text]
renderProjectEntry ProjectEntry {..} =
  rootedPathChunk projectEntryFilePath :
  case projectEntryCurrentEntry of
    Nothing -> [chunk "No next action"]
    Just e@Entry {..} -> [mTodoStateChunk $ entryState e, headerChunk entryHeader]
