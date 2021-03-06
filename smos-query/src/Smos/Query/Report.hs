{-# LANGUAGE RecordWildCards #-}

module Smos.Query.Report
  ( report
  ) where

import Conduit

import Data.Map as M
import Data.Maybe
import Data.Text as T

import System.Exit

import Smos.Report.Projection
import Smos.Report.Report

import Smos.Query.Config
import Smos.Query.Entry
import Smos.Query.OptParse.Types

report :: ReportSettings -> Q ()
report ReportSettings {..} =
  case M.lookup reportSetReportName reportSetAvailableReports of
    Nothing -> liftIO $ die $ "No such prepared report configured: " <> T.unpack reportSetReportName
    Just PreparedReport {..} ->
      entry
        EntrySettings
          { entrySetFilter = perparedReportFilter
          , entrySetProjection = fromMaybe defaultProjection perparedReportProjection
          , entrySetSorter = preparedReportSorter
          , entrySetHideArchive = fromMaybe HideArchive preparedReportHideArchive
          }
