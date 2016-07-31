{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections     #-}

module LN.UI.Core.Router.Route (
  RouteWith (..),
  routeWith,
  routeWith',
  fromRouteWith,
  fromRouteWithHash,
  toRouteWith,
  toRouteWithHash,
  Route (..),
  HasLinkName,
  linkName,
  HasCrumb,
  crumb
) where



import           Control.Applicative        ((*>), (<$), (<$>), (<*>), (<|>))
import           Control.DeepSeq            (NFData)
import           Data.ByteString.Char8      (ByteString)
import qualified Data.ByteString.Char8      as BSC
import           Data.Either                (Either (..))
import qualified Data.Map                   as Map
import           Data.Maybe                 (Maybe (Just))
import           Data.Monoid                (mempty, (<>))
import           Data.Text                  (Text)
import           Prelude                    (Eq, Int, Show, fmap, map, pure,
                                             ($), (.))
import           Text.Parsec.Prim           (try)
import           Web.Routes

import           Haskell.Api.Helpers.Shared (qp)
import           LN.T
import           LN.UI.Core.Helpers.GHCJS   (JSString, textToJSString')
import           LN.UI.Core.Router.CRUD     (CRUD (..))
import           LN.UI.Core.Router.Crumb    (HasCrumb, crumb)
import           LN.UI.Core.Router.LinkName (HasLinkName, linkName)
import           LN.UI.Core.Router.Param    (Params, buildParams,
                                             fromWebRoutesParams)



data RouteWith
  = RouteWith Route Params
  deriving (Eq, Show, Generic, NFData)



routeWith :: Route -> [(ParamTag, Param)] -> RouteWith
routeWith route params = RouteWith route (buildParams params)



routeWith' :: Route -> RouteWith
routeWith' route = routeWith route mempty



fromRouteWith :: RouteWith -> Text
fromRouteWith (RouteWith route params) =
  toPathInfoParams route params'
  where
  params' = map (fmap Just . qp) $ Map.elems params



fromRouteWithHash :: RouteWith -> JSString
fromRouteWithHash = textToJSString' . ("#" <>) <$> fromRouteWith



toRouteWith :: ByteString -> RouteWith
toRouteWith url =
  case (fromPathInfoParams url) of
    Left _              -> routeWith' NotFound
    Right (url_, params) -> routeWith url_ $ fromWebRoutesParams params



toRouteWithHash :: ByteString -> RouteWith
toRouteWithHash = toRouteWith . BSC.drop 1



data Route
  = Home
  | About
  | Me
  | Errors
  | Portal
  | Organizations CRUD
  | OrganizationsForums Text CRUD
  | OrganizationsForumsBoards Text Text CRUD
  | OrganizationsForumsBoardsThreads Text Text Text CRUD
  | OrganizationsForumsBoardsThreadsPosts Text Text Text Text CRUD
  | OrganizationsTeams Text CRUD
  | OrganizationsTeamsMembers Text Text CRUD
  | OrganizationsMembersOnly Text
  | OrganizationsMembership Text CRUD
  | Users CRUD
  | UsersProfile Text
  | UsersSettings Text
  | UsersPMs Text
  | UsersThreads Text
  | UsersThreadPosts Text
  | UsersWorkouts Text
  | UsersResources Text
  | UsersLeurons Text
  | UsersLikes Text
  | Resources CRUD
  | ResourcesLeurons Int CRUD
  | ResourcesSiftLeurons Int
  | ResourcesSiftLeuronsLinear Int CRUD
  | ResourcesSiftLeuronsRandom Int
  | Login
  | Logout
  | NotFound
  deriving (Eq, Show, Generic, NFData)



instance HasLinkName Route where
  linkName route = case route of
    Home                            -> "Home"
    About                           -> "About"
    Portal                          -> "Portal"
    Organizations Index             -> "Organizations"
    Organizations New               -> "New"
    Organizations (ShowS org_sid)   -> org_sid
    Organizations (EditS org_sid)   -> org_sid
    Organizations (DeleteS org_sid) -> org_sid
    OrganizationsForums _ Index               -> "Forums"
    OrganizationsForums _ New                 -> "New"
    OrganizationsForums _ (ShowS forum_sid)   -> forum_sid
    OrganizationsForums _ (EditS forum_sid)   -> forum_sid
    OrganizationsForums _ (DeleteS forum_sid) -> forum_sid
    (Users Index)                   -> "Users"
    Users (ShowS user_sid)          -> user_sid
    Users (EditS user_sid)          -> user_sid
    Users (DeleteS user_sid)        -> user_sid
    Login                           -> "Login"
    Logout                          -> "Logout"
    _                               -> "Unknown"



instance HasLinkName RouteWith where
  linkName (RouteWith route _) = linkName route



instance HasCrumb Route where

  crumb route =
    case route of
       Home   -> []
       About  -> []
       Me     -> []
       Errors -> []
       Portal -> []

       Organizations Index             -> []
       Organizations New               -> [Organizations Index]
       Organizations (ShowS _)         -> [Organizations Index]
       Organizations (EditS org_sid)   -> organizations_repetitive org_sid
       Organizations (DeleteS org_sid) -> organizations_repetitive org_sid

       -- TODO FIXME: Remove eventually, needs to be accurately total
       _ -> [NotFound]

    where
    organizations_repetitive org_sid =
      [ Organizations Index
      , Organizations (ShowS org_sid) ]



instance PathInfo Route where

  toPathSegments route = case route of
    Home                     -> pure ""
    About                    -> pure "about"
    Me                       -> pure "me"
    Errors                   -> pure "errors"
    Portal                   -> pure "portal"
    Organizations Index      -> pure "organizations"
    Organizations (ShowS s)  -> pure s
    Organizations crud       -> (pure $ "organizations") <> toPathSegments crud
    OrganizationsForums org_sid Index -> (pure org_sid) <> pure "f"
    OrganizationsForums org_sid crud -> (pure org_sid) <> pure "f" <> toPathSegments crud
    OrganizationsForumsBoards org_sid forum_sid Index -> (pure org_sid) <> pure "f" <> pure forum_sid
    OrganizationsForumsBoards org_sid forum_sid crud -> (pure org_sid) <> pure "f" <> pure forum_sid <> toPathSegments crud
    OrganizationsForumsBoardsThreads org_sid forum_sid board_sid Index -> (pure org_sid) <> pure "f" <> pure forum_sid <> pure board_sid
    OrganizationsForumsBoardsThreads org_sid forum_sid board_sid crud -> (pure org_sid) <> pure "f" <> pure forum_sid <> pure board_sid <> toPathSegments crud
    OrganizationsForumsBoardsThreadsPosts org_sid forum_sid board_sid thread_sid Index -> (pure org_sid) <> pure "f" <> pure forum_sid <> pure board_sid <> pure thread_sid
    OrganizationsForumsBoardsThreadsPosts org_sid forum_sid board_sid thread_sid crud -> (pure org_sid) <> pure "f" <> pure forum_sid <> pure board_sid <> pure thread_sid <> toPathSegments crud
    Users Index              -> pure "users"
    Users crud               -> (pure $ "users") <> toPathSegments crud
    _                        -> pure ""

  fromPathSegments =
        About         <$ segment "about"
    <|> Me            <$ segment "me"
    <|> Errors        <$ segment "errors"
    <|> Portal        <$ segment "portal"
    <|> Users         <$ segment "users" <*> fromPathSegments
--    <|> try (OrganizationsForumsBoardsThreadsPosts <$> anySegment <*> (segment "f" *> fromPathSegments)) <*> fromPathSegments <*> fromPathSegments <*> fromPathSegments
--    <|> try (OrganizationsForumsBoardsThreads <$> anySegment <*> (segment "f" *> fromPathSegments)) <*> fromPathSegments <*> fromPathSegments
    <|> try (OrganizationsForumsBoards <$> anySegment <*> (segment "f" *> fromPathSegments)) <*> fromPathSegments
    <|> try (OrganizationsForums <$> anySegment <*> (segment "f" *> fromPathSegments))
    <|> Organizations <$ segment "organizations" <*> fromPathSegments
    <|> Organizations <$> (ShowS <$> anySegment)
    <|> pure Home
    -- TODO FIXME: Can't do Home <$ segment "" because it fails to pattern match. Though, pure Index works because it's terminal.
