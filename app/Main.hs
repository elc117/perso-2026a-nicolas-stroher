{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main (main) where

import qualified Data.Map as Map
import Text.Megaparsec
import Web.Scotty
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Cors (cors, simpleCorsResourcePolicy, corsMethods, corsRequestHeaders)
import Network.Wai (Middleware)
import Network.HTTP.Types.Status
import Data.Aeson (object, (.=), FromJSON, Value(String))
import GHC.Generics (Generic)

-- Modulos Haskell (src/)
import Logic
import Parser

data DadosRecebidos = DadosRecebidos
    { expression :: String
    , variables :: Map.Map String Bool
    } deriving (Show, Generic)    

instance FromJSON DadosRecebidos


politicaCors :: Middleware
politicaCors = cors (const $ Just policy)
    where
        policy = simpleCorsResourcePolicy {
            corsOrigins = Just (["https://logic-app-5rb3.onrender.com"], True),
            corsMethods = ["GET", "POST", "OPTIONS"],
            corsRequestHeaders = ["Content-Type"]
        }


main :: IO ()
main = scotty 3000 $ do
    middleware logStdoutDev
    middleware politicaCors

    get "/api/health" $ do
        text "OK"

    post "/api/evaluate" $ do
        dados <- jsonData :: ActionM DadosRecebidos

        let exp = expression dados
            env = Map.toList $ variables dados

        let parsedExp = parse parseExpression "" exp

        case parsedExp of

            Left error -> do
                liftIO $ putStrLn $ ">>> Erro de sintaxe: " ++ show error
                status badRequest400
                json $ object ["error" .= (String "Erro de sintaxe na expressão")]

            Right parsedExp -> do
                liftIO $ putStrLn  $ ">>> Árvore gerada com sucesso"
                let result = evaluate parsedExp env
                json $ object ["result" .= result]
