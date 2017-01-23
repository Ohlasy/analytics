-- Simple Network.Google.OAuth2 wrapper with token caching
module Auth (AuthToken, getAuthToken) where

import Network.Google.OAuth2 (getAccessToken, OAuth2Token, OAuth2Client(..))
import Credentials (loadOAuth2Credentials, OAuth2Credentials(..))

type AuthToken = OAuth2Token

-- Load OAuth2 credentials from a cache and exchange them for an access token
getAuthToken :: IO (Maybe AuthToken)
getAuthToken = do
    creds <- loadOAuth2Credentials credentialsCache
    case creds of
        Just creds -> do
            let client = OAuth2Client (getClientID creds) (getClientSecret creds)
            token <- getAccessToken client scope (Just tokenCache)
            return $ Just token
        Nothing -> return Nothing
    where
        scope = ["https://www.google.com/analytics/feeds/"]
        credentialsCache = "auth-credentials.yml"
        tokenCache = "auth-token.yml"
