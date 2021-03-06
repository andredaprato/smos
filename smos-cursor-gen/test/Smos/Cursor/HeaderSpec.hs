{-# LANGUAGE TypeApplications #-}

module Smos.Cursor.HeaderSpec where

import Test.Hspec
import Test.Validity

import Smos.Data.Gen ()

import Smos.Cursor.Header
import Smos.Cursor.Header.Gen ()

spec :: Spec
spec = do
  eqSpec @HeaderCursor
  genValidSpec @HeaderCursor
  shrinkValidSpecWithLimit @HeaderCursor 100
  describe "makeHeaderCursor" $
    it "produces valid cursors" $ producesValidsOnValids makeHeaderCursor
  describe "rebuildHeaderCursor" $ do
    it "produces valid cursors" $ producesValidsOnValids rebuildHeaderCursor
    it "is the inverse of makeHeaderCursor" $
      inverseFunctionsOnValid makeHeaderCursor rebuildHeaderCursor
  describe "headerCursorInsert" $ do
    it "produces valid cursors when inserting '\n'" $
      forAllValid $ \tsc -> shouldBeValid $ headerCursorInsert '\n' tsc
    it "produces valid cursors when inserting an unsafe character" $
      forAllValid $ \tsc -> shouldBeValid $ headerCursorInsert '\55810' tsc
    it "produces valid cursors" $ producesValidsOnValids2 headerCursorInsert
  describe "headerCursorAppend" $ do
    it "produces valid cursors when inserting '\n'" $
      forAllValid $ \tsc -> shouldBeValid $ headerCursorAppend '\n' tsc
    it "produces valid cursors when inserting an unsafe character" $
      forAllValid $ \tsc -> shouldBeValid $ headerCursorAppend '\55810' tsc
    it "produces valid cursors" $ producesValidsOnValids2 headerCursorAppend
  describe "headerCursorRemove" $
    it "produces valid cursors" $ producesValidsOnValids headerCursorRemove
  describe "headerCursorDelete" $
    it "produces valid cursors" $ producesValidsOnValids headerCursorDelete
  describe "headerCursorSelectPrev" $
    it "produces valid cursors" $ producesValidsOnValids headerCursorSelectPrev
  describe "headerCursorSelectNext" $
    it "produces valid cursors" $ producesValidsOnValids headerCursorSelectNext
  describe "headerCursorSelectStart" $
    it "produces valid cursors" $ producesValidsOnValids headerCursorSelectStart
  describe "headerCursorSelectEnd" $
    it "produces valid cursors" $ producesValidsOnValids headerCursorSelectEnd
