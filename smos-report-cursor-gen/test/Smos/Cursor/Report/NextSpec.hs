{-# LANGUAGE TypeApplications #-}

module Smos.Cursor.Report.NextSpec where

import Smos.Cursor.Report.Next
import Smos.Cursor.Report.Next.Gen ()
import Test.Hspec
import Test.Validity

spec :: Spec
spec = do
  eqSpecOnValid @NextActionReportCursor
  genValidSpec @NextActionReportCursor
  eqSpecOnValid @NextActionEntryCursor
  genValidSpec @NextActionEntryCursor
