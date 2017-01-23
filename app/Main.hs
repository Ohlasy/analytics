import Analytics (TopArticle, getTopArticles)
import Auth (AuthToken, getAuthToken)
import qualified Data.ByteString.Lazy as B
import qualified Data.Aeson.Encode.Pretty as Aeson
import System.Exit

main :: IO ()
main = do
    accessToken <- getAuthToken
    case accessToken of
        Just token -> do
            articles <- getTopArticles token
            case articles of
                Just articles -> do
                    B.writeFile "top-articles.json" $ Aeson.encodePretty articles
                    exitSuccess
                Nothing ->
                    die "Error parsing server response."
        Nothing ->
            die "Error parsing the analytics credentials file."
