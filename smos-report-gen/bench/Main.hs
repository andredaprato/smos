{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Data.Map (Map)
import Data.Set (Set)

import Data.GenValidity.Containers ()
import Data.GenValidity.Criterion

import Criterion.Main as Criterion

import Cursor.Simple.Forest

import Smos.Data
import Smos.Data.Gen ()
import Smos.Report.Filter
import Smos.Report.Filter.Gen ()
import Smos.Report.Path
import Smos.Report.Time

main :: IO ()
main =
  Criterion.defaultMain
    [ genValidBench @(Filter RootedPath)
    , genValidBench @(Filter Time)
    , genValidBench @(Filter Tag)
    , genValidBench @(Filter Header)
    , genValidBench @(Filter TodoState)
    , genValidBench @(Filter Timestamp)
    , genValidBench @(Filter PropertyValue)
    , genValidBench @(Filter Entry)
    , genValidBench @(Filter (Maybe PropertyValue))
    , genValidBench @(Filter (Set Tag))
    , genValidBench @(Filter (Map PropertyName PropertyValue))
    , genValidBench @(Filter (ForestCursor Header))
    , genValidBench @(Filter (ForestCursor Entry))
    , genValidBench @(Filter (RootedPath, ForestCursor Entry))
    ]
