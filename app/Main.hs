{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main (main) where

import Web.Scotty
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Cors (cors, simpleCorsResourcePolicy, corsMethods, corsRequestHeaders)
import Network.Wai (Middleware)
import Data.Aeson (object, (.=), FromJSON)
import GHC.Generics (Generic)

data DadosRecebidos = DadosRecebidos
    {expressao :: String}
    deriving (Show, Generic)
instance FromJSON DadosRecebidos

politicaCors :: Middleware
politicaCors = cors (const $ Just policy)
    where
        policy = simpleCorsResourcePolicy {
            corsMethods = ["GET", "POST", "OPTIONS"],
            corsRequestHeaders = ["Content-Type"]
        }


main :: IO ()
main = scotty 3000 $ do
    middleware logStdoutDev
    middleware politicaCors

    get "/api/health" $ do
        text "OK"

    post "/api/data" $ do
        dados <- jsonData :: ActionM DadosRecebidos
        liftIO $ putStrLn $ ">>> Chegou do JS: " ++ expressao dados
        json $ object["status" .= (expressao dados :: String)]
