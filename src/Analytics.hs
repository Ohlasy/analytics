{-# LANGUAGE OverloadedStrings #-}

module Analytics (
    ServerResponse,
    TopArticle,
    runAnalyticsQuery,
    getTopArticles
) where

import Auth (AuthToken)
import Data.Aeson
import Control.Monad
import Data.Maybe (mapMaybe)
import qualified Data.ByteString.Char8 as B8
import Network.HTTP.Types (hAuthorization)
import Network.HTTP.Conduit
import Data.Monoid

--
-- Generic Query
--

-- Generic Google Analytics response, see https://goo.gl/W9DjEe for details
data ServerResponse = ServerResponse {
    responseRows :: [[String]]
} deriving (Show, Eq)

instance FromJSON ServerResponse where
    parseJSON (Object value) = ServerResponse <$> value .: "rows"
    parseJSON _ = mzero

runAnalyticsQuery :: AuthToken -> String -> IO (Maybe ServerResponse)
runAnalyticsQuery token queryURL = do
    manager <- newManager tlsManagerSettings
    request <- parseUrlThrow queryURL
    response <- httpLbs (authorize token request) manager
    return $ parseResponse $ responseBody response
    where
        parseResponse = Data.Aeson.decode
        authorize token request = request {
            requestHeaders = [(hAuthorization, B8.pack $ "Bearer " <> token)]
        }

--
-- Top Articles
--

data TopArticle = TopArticle {
    articleTitle :: String,
    articleURL :: String
} deriving (Show, Eq)

instance ToJSON TopArticle where
    toJSON (TopArticle title url) =
        object ["title" .= title, "url" .= url]

topArticlesQuery = "https://www.googleapis.com/analytics/v3/data/ga?ids=ga%3A97173197&start-date=60daysAgo&end-date=yesterday&metrics=ga%3Ausers%2Cga%3Apageviews&dimensions=ga%3ApagePath%2Cga%3ApageTitle&sort=-ga%3Apageviews&filters=ga%3ApagePath%3D%40%2Fclanky%2F20&max-results=10"

getTopArticles :: AuthToken -> IO (Maybe [TopArticle])
getTopArticles token = do
    response <- runAnalyticsQuery token topArticlesQuery
    case response of
        Just response ->
            return $ Just $ parseTopArticlesResponse response
        Nothing ->
            return Nothing

parseTopArticlesResponse :: ServerResponse -> [TopArticle]
parseTopArticlesResponse response =
    mapMaybe parseTopArticleResponseRow (responseRows response)

parseTopArticleResponseRow :: [String] -> Maybe TopArticle
parseTopArticleResponseRow (url:(title:_)) =
    case title of
        "(not set)" -> Nothing
        _ -> Just TopArticle { articleTitle = title, articleURL = url }
parseResponseRow _ = Nothing
