{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TypeFamilies      #-}

module LN.UI.Core.State.Internal (
  Store (..),
  Action (..)
) where



import           Control.DeepSeq          (NFData)
import           Data.Int                 (Int64)
import           Data.Map                 (Map)
import qualified Data.Map                 as Map
import           Data.Typeable            (Typeable)
import           GHC.Generics             (Generic)

import           LN.T
import           LN.T.Pack.Sanitized.User (UserSanitizedPackResponse (..))
import           LN.T.User                (UserResponse (..))
import           LN.UI.Core.Loader        (Loader (..))
import           LN.UI.Core.Router        (Route (..), RouteWith, routeWith')
import           LN.UI.Core.Types



data Store = Store {
      _route           :: RouteWith
    , _m_me            :: Maybe UserResponse
    , _meId            :: UserId
    , _usersCache      :: Map UserId UserSanitizedPackResponse
    , _l_organizations :: Loader (Map OrganizationId OrganizationPackResponse)
    , _l_users         :: Loader (Map UserId UserSanitizedPackResponse)
    , _l_forums        :: Loader (Map ForumId ForumPackResponse)
    , _l_boards        :: Loader (Map BoardId BoardPackResponse)
    , _l_threads       :: Loader (Map ThreadId ThreadPackResponse)
    , _l_posts         :: Loader (Map ThreadId ThreadPostPackResponse)
    } deriving (Typeable, Generic)



data Action
  = Init
  | SetRoute RouteWith
  | SyncUsers [Int64]
  | Nop
  deriving (Show, Typeable, Generic, NFData)



defaultStore :: Store
defaultStore = Store {
      _route           = routeWith' Home
    , _m_me            = Nothing
    , _meId            = 0
    , _usersCache      = Map.empty
    , _l_organizations = Loaded Map.empty
    , _l_users         = Loaded Map.empty
    , _l_forums        = Loaded Map.empty
    , _l_boards        = Loaded Map.empty
    , _l_threads       = Loaded Map.empty
    , _l_posts         = Loaded Map.empty
    }