module LN.UI.Core.Router.Util (
  mkUri,
  unUri,
  slash,
  preSlash,
  postSlash,
  unslash
) where



import           Data.Monoid ((<>))
import           Prelude     (String, undefined)



mkUri :: String -> String
mkUri _ = undefined -- encodeURI url



unUri :: String -> String
unUri _ = undefined -- decodeURI url



-- HACK TODO FIXME: adding trailing slashes (<> /) to all of the Show routes...
-- otherwise we get double ajax calls when we click a bread crumb.. why????????
-- also need slash to make sure there's not multiple trailing slashes, ie, dropWhileEnd which doesn't exist
slash :: String -> String
slash s = s <> "/"



preSlash :: String -> String
preSlash s = "/" <> s



postSlash :: String -> String
postSlash = slash


unslash :: String -> String
unslash = undefined -- joinWith "" <<< split "/"
