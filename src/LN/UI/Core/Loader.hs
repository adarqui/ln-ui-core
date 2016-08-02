{-# LANGUAGE ExplicitForAll    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Rank2Types        #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module LN.UI.Core.Loader (
  Loader (..),
  HasLoader,
  loading,
  cantLoad,
  loader1,
  maybeLoader1,
  loader2,
  maybeLoader2,
  loader3,
  maybeLoader3,
  loader4,
  loader5,
  loading
) where



import           Control.DeepSeq (NFData)
import           Data.Typeable   (Typeable)
import           GHC.Generics    (Generic)



data Loader a
  = Loaded a
  | Loading
  | CantLoad
  deriving (Generic, Typeable, NFData)



class HasLoader a where
  loading :: a
  cantLoad :: a



loader1 :: forall m v. HasLoader m => Loader v -> (v -> m) -> m
loader1 loading_v loaded =
  case loading_v of
    Loaded v -> loaded v
    Loading  -> loading
    CantLoad -> cantLoad



maybeLoader1 :: forall m v. HasLoader m => Loader (Maybe v) -> (v -> m) -> m
maybeLoader1 loading_v loaded =
  case loading_v of
    Loaded (Just v) -> loaded v
    Loading         -> loading
    _               -> cantLoad



loader2 :: forall m v1 v2. HasLoader m => Loader v1 -> Loader v2 -> (v1 -> v2 -> m) -> m
loader2 loading_v1 loading_v2 loaded =
  case (loading_v1, loading_v2) of
    (Loaded v1, Loaded v2) -> loaded v1 v2
    (Loading, _)           -> loading
    (_, Loading)           -> loading
    _                      -> cantLoad



maybeLoader2 :: forall m v1 v2. HasLoader m => Loader (Maybe v1) -> Loader (Maybe v2) -> (v1 -> v2 -> m) -> m
maybeLoader2 loading_v1 loading_v2 loaded =
  case (loading_v1, loading_v2) of
    (Loaded (Just v1), Loaded (Just v2)) -> loaded v1 v2
    (Loading, _)                         -> loading
    (_, Loading)                         -> loading
    _                                    -> cantLoad



loader3 :: forall m v1 v2 v3. HasLoader m => Loader v1 -> Loader v2 -> Loader v3 -> (v1 -> v2 -> v3 -> m) -> m
loader3 loading_v1 loading_v2 loading_v3 loaded =
  case (loading_v1, loading_v2, loading_v3) of
    (Loaded v1, Loaded v2, Loaded v3) -> loaded v1 v2 v3
    (Loading, _, _)                   -> loading
    (_, Loading, _)                   -> loading
    (_, _, Loading)                   -> loading
    _                                 -> cantLoad



maybeLoader3 :: forall m v1 v2 v3. HasLoader m => Loader (Maybe v1) -> Loader (Maybe v2) -> Loader (Maybe v3) -> (v1 -> v2 -> v3 -> m) -> m
maybeLoader3 loading_v1 loading_v2 loading_v3 loaded =
  case (loading_v1, loading_v2, loading_v3) of
    (Loaded (Just v1), Loaded (Just v2), Loaded (Just v3)) -> loaded v1 v2 v3
    (Loading, _, _)                   -> loading
    (_, Loading, _)                   -> loading
    (_, _, Loading)                   -> loading
    _                                 -> cantLoad



loader4 :: forall m v1 v2 v3 v4. HasLoader m => Loader v1 -> Loader v2 -> Loader v3 -> Loader v4 -> (v1 -> v2 -> v3 -> v4 -> m) -> m
loader4 loading_v1 loading_v2 loading_v3 loading_v4 loaded =
  case (loading_v1, loading_v2, loading_v3, loading_v4) of
    (Loaded v1, Loaded v2, Loaded v3, Loaded v4) -> loaded v1 v2 v3 v4
    (Loading, _, _, _)                   -> loading
    (_, Loading, _, _)                   -> loading
    (_, _, Loading, _)                   -> loading
    (_, _, _, Loading)                   -> loading
    _                                    -> cantLoad




loader5 :: forall m v1 v2 v3 v4 v5. HasLoader m => Loader v1 -> Loader v2 -> Loader v3 -> Loader v4 -> Loader v5 -> (v1 -> v2 -> v3 -> v4 -> v5 -> m) -> m
loader5 loading_v1 loading_v2 loading_v3 loading_v4 loading_v5 loaded =
  loader4 loading_v1 loading_v2 loading_v3 loading_v4 $ \v1 v2 v3 v4 -> do
    loader1 loading_v5 (loaded v1 v2 v3 v4)
