{-# LANGUAGE ExplicitForAll  #-}
{-# LANGUAGE RankNTypes      #-}
{-# LANGUAGE RecordWildCards #-}

-- | Not used right now.. need to figure out how to make this generic for use in React.Flux for example.
--

module LN.UI.Core.Access (
  HasAccess,
  open,
  empty,
  isMemberOfOrganization,
  isMemberOfOrganizationHTML,
  isMemberOfOrganizationHTML',
  permissionsHTML,
  permissionsHTML',
  permCreateEmpty,
  permReadEmpty,
  permUpdateEmpty,
  permDeleteEmpty,
  permExecuteEmpty,
  permissionsMatchCreateHTML,
  permissionsMatchReadHTML,
  permissionsMatchUpdateHTML,
  permissionsMatchDeleteHTML,
  permissionsMatchExecuteHTML,
  permissionsMatchHTML,
  ifte_Self,
  ifte_NotSelf,
  self,
  notSelf,
  ifte_OrgMember,
  orgMember,
  orgMemberHTML,
  orgMemberHTML',
  ifte_OrgOwner,
  orgOwner,
  orgOwnerHTML,
  orgOwnerHTML'
) where



import           LN.T
import           LN.UI.Core.Types



class Monoid m => HasAccess m where
  open :: m -> m
  empty :: m



-- | Check whether a user is a member of Team_Members
--
isMemberOfOrganization :: OrganizationPackResponse -> Bool
isMemberOfOrganization OrganizationPackResponse{..} = Team_Members `elem` organizationPackResponseTeams



-- | Supports handlers for if a user is/isnt a member
--
isMemberOfOrganizationHTML
  :: forall m. HasAccess m
  => OrganizationPackResponse
  -> m
  -> m
  -> m

isMemberOfOrganizationHTML pack is_member_handler isnt_member_handler =
  if isMemberOfOrganization pack
    then is_member_handler
    else isnt_member_handler



-- | Supports a handler if a user is a member
--
isMemberOfOrganizationHTML'
  :: forall m. HasAccess m
  => OrganizationPackResponse
  -> m
  -> m

isMemberOfOrganizationHTML' pack is_member_handler =
  if isMemberOfOrganization pack
    then is_member_handler
    else empty



permissionsHTML
  :: forall m. HasAccess m
  => Permissions
  -> m
  -> m
  -> m
  -> m
  -> m
  -> m
  -> m
  -> m
  -> m
  -> m
  -> m
permissionsHTML perms create_cb no_create_cb read_cb no_read_cb update_cb no_update_cb delete_cb no_delete_cb execute_cb no_execute_cb = do
  open $ do
    mconcat
      [ if Perm_Create  `elem` perms then create_cb  else no_create_cb
      , if Perm_Read    `elem` perms then read_cb    else no_read_cb
      , if Perm_Update  `elem` perms then update_cb  else no_update_cb
      , if Perm_Delete  `elem` perms then delete_cb  else no_delete_cb
      , if Perm_Execute `elem` perms then execute_cb else no_execute_cb
      ]



permissionsHTML'
  :: forall m. HasAccess m
  => Permissions
  -> m
  -> m
  -> m
  -> m
  -> m
  -> m
permissionsHTML' perms create_cb read_cb update_cb delete_cb execute_cb =
  permissionsHTML perms create_cb empty read_cb empty update_cb empty delete_cb empty execute_cb empty



permCreateEmpty, permReadEmpty, permUpdateEmpty, permDeleteEmpty, permExecuteEmpty :: forall m. HasAccess m => m
permCreateEmpty  = empty
permReadEmpty    = empty
permUpdateEmpty  = empty
permDeleteEmpty  = empty
permExecuteEmpty = empty



permissionsMatchCreateHTML :: forall m. HasAccess m => Permissions -> m -> m -> m
permissionsMatchCreateHTML = permissionsMatchHTML Perm_Create



permissionsMatchReadHTML :: forall m. HasAccess m => Permissions -> m -> m -> m
permissionsMatchReadHTML = permissionsMatchHTML Perm_Read



permissionsMatchUpdateHTML :: forall m. HasAccess m => Permissions -> m -> m -> m
permissionsMatchUpdateHTML = permissionsMatchHTML Perm_Update



permissionsMatchDeleteHTML :: forall m. HasAccess m => Permissions -> m -> m -> m
permissionsMatchDeleteHTML = permissionsMatchHTML Perm_Delete



permissionsMatchExecuteHTML :: forall m. HasAccess m => Permissions -> m -> m -> m
permissionsMatchExecuteHTML = permissionsMatchHTML Perm_Execute



permissionsMatchHTML
  :: forall m. HasAccess m
  => Permission
  -> Permissions
  -> m
  -> m
  -> m
permissionsMatchHTML perm_to_match permissions is_match_handler isnt_match_handler =
  if perm_to_match `elem` permissions then is_match_handler else isnt_match_handler





ifte_Self :: forall m. HasAccess m => UserId -> UserId -> m -> m -> m
ifte_Self my_id questionable_id t e =
  if my_id == questionable_id
     then t
     else e



ifte_NotSelf :: forall m. HasAccess m => UserId -> UserId -> m -> m -> m
ifte_NotSelf my_id questionable_id t e =
  if my_id /= questionable_id
     then t
     else e



self :: UserId -> UserId -> Bool
self my_id questionable_id = my_id == questionable_id



notSelf :: UserId -> UserId -> Bool
notSelf my_id questionable_id = my_id /= questionable_id



--
-- Owner Helpers
--

ifte_OrgOwner :: forall m. HasAccess m => OrganizationPackResponse -> m -> m -> m
ifte_OrgOwner pack t e =
  if orgOwner pack
     then t
     else e



orgOwner :: OrganizationPackResponse -> Bool
orgOwner OrganizationPackResponse{..} = Team_Owners `elem` organizationPackResponseTeams



orgOwnerHTML :: forall m. HasAccess m => OrganizationPackResponse -> m -> m -> m
orgOwnerHTML pack owner_cb no_owner_cb =
  if orgOwner pack
    then owner_cb
    else no_owner_cb



orgOwnerHTML' :: forall m. HasAccess m => OrganizationPackResponse -> m -> m
orgOwnerHTML' pack owner_cb = orgOwnerHTML pack owner_cb empty



--
-- Member helpers
--

ifte_OrgMember :: forall m. HasAccess m => OrganizationPackResponse -> m -> m -> m
ifte_OrgMember pack t e =
  if orgMember pack
     then t
     else e



orgMember :: OrganizationPackResponse -> Bool
orgMember OrganizationPackResponse{..} = Team_Members `elem` organizationPackResponseTeams



orgMemberHTML :: forall m. HasAccess m => OrganizationPackResponse -> m -> m -> m
orgMemberHTML pack member_cb no_member_cb =
  if orgMember pack
    then member_cb
    else no_member_cb



orgMemberHTML' :: forall m. HasAccess m => OrganizationPackResponse -> m -> m
orgMemberHTML' pack member_cb = orgMemberHTML pack member_cb empty
