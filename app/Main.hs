import Analytics (TopArticle, getTopArticles)
import Auth (AuthToken, getAuthToken)
import System.Exit
import Data.Aeson

main :: IO ()
main = do
    accessToken <- getAuthToken
    case accessToken of
        Just token -> do
            articles <- getTopArticles token
            case articles of
                Just articles -> do
                    putStrLn $ show $ Data.Aeson.encode articles
                    exitSuccess
                Nothing ->
                    die "Error parsing server response."
        Nothing ->
            die "Error parsing the analytics credentials file."
