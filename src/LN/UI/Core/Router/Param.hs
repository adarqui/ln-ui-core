{-# LANGUAGE OverloadedStrings #-}

module LN.UI.Core.Router.Param (
  Params,
  emptyParams,
  lookupParam,
  fixParams,
  buildParams,
  fromWebRoutesParams,
  updateParams_Offset,
  updateParams_Limit,
  updateParams_Offset_Limit
) where



import           Data.Int   (Int64)
import           Data.Map   (Map)
import qualified Data.Map   as Map
import           Data.Maybe (Maybe (..), catMaybes, maybe)
import           Data.Text  (Text)
import qualified Data.Text  as Text
import           Text.Read  (readMaybe)

import           LN.T




type Params = Map ParamTag Param



emptyParams :: Params
emptyParams = Map.empty



lookupParam :: ParamTag -> Params -> Maybe Param
lookupParam p_tag params = Map.lookup p_tag params



buildParams :: [(ParamTag, Param)] -> Params
buildParams = Map.fromList



sanitizeWebRoutesParams :: [(Text, Maybe Text)] -> [(Text, Text)]
sanitizeWebRoutesParams m_params = catMaybes $ map mapParam m_params
  where
  mapParam (_, Nothing) = Nothing
  mapParam (k, Just v)  = Just (k, v)



fromWebRoutesParams :: [(Text, Maybe Text)] -> [(ParamTag, Param)]
fromWebRoutesParams = catMaybes . map paramFromKV_ . sanitizeWebRoutesParams



fixParams :: Params -> Params
fixParams = id



paramFromKV_ :: (Text, Text) -> Maybe (ParamTag, Param)
paramFromKV_ (k, v) =
  case (readMaybe $ Text.unpack k) of
    Nothing    -> Nothing
    Just ParamTag_Limit     -> maybe Nothing (\v' -> Just (ParamTag_Limit, Limit v')) (readMaybe $ Text.unpack v)
    Just ParamTag_Offset    -> maybe Nothing (\v' -> Just (ParamTag_Offset, Offset v')) (readMaybe $ Text.unpack v)
    Just ParamTag_Order     -> Just (ParamTag_Order, Order $ read $ Text.unpack v)
    Just ParamTag_SortOrder -> Just (ParamTag_SortOrder, SortOrder $ read $ Text.unpack v)
    Just _                  -> Nothing



-- | Updates only the Offset param
updateParams_Offset :: Int64 -> Params -> Params
updateParams_Offset offset = Map.alter (\_ -> Just $ Offset offset) ParamTag_Offset



updateParams_Limit :: Int64 -> Params -> Params
updateParams_Limit limit = Map.alter (\_ -> Just $ Limit limit) ParamTag_Limit



updateParams_Offset_Limit :: Int64 -> Int64 -> Params -> Params
updateParams_Offset_Limit offset limit params = updateParams_Offset offset $ updateParams_Limit limit params
