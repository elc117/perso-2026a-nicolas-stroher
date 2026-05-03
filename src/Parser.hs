{-# LANGUAGE OverloadedStrings #-}
module Parser where

import Text.Megaparsec
import Text.Megaparsec.Char
import Control.Monad.Combinators.Expr
import Text.Megaparsec.Char.Lexer as L
import Data.Void
import Logic

type Parser = Parsec Void String



-- Implementa somente a remocao de espaços em branco, sem tratar comentarios
ws :: Parser ()
ws = L.space space1 empty empty

-- Funciona como um wrapper para parsers, eliminando os espacos em branco
parserLexeme :: Parser a -> Parser a
parserLexeme = L.lexeme ws

operatorSymbol :: String -> Parser String
operatorSymbol = L.symbol ws

keyword :: String -> Parser String
keyword word = try (string' word <* notFollowedBy alphaNumChar) <* ws



-- Construtores na tabela sao tratados em makeExprParser, que cria os parsers
-- Possivel futura implementacao de XOR
operatorTable :: [[Operator Parser Expression]]
operatorTable = 
    [ [Prefix (Not <$ operatorSymbol "!"), Prefix (Not <$ keyword "NOT")]
    , [InfixL (And <$ operatorSymbol "&&"), InfixL (And <$ keyword "AND")]
    , [InfixL (Xor <$ keyword "XOR")]
    , [InfixL (Or <$ operatorSymbol "||"), InfixL (Or <$ keyword "OR")]
    , [InfixL (ImpliesRight <$ operatorSymbol "->")]
    , [InfixL (ImpliesLeft <$ operatorSymbol "<-")]
    ]

-- makeExprParser trata os operadores em operatorTable. Caso nenhum seja o procurado, passa para parseTerm
parseExpression :: Parser Expression
parseExpression = ws *> makeExprParser parseTerm operatorTable <* eof

parseVariable :: Parser Expression
parseVariable = Variable <$> parserLexeme (some letterChar)

parseTerm :: Parser Expression
parseTerm = parseBool <|> parseVariable <|> parseParantheses
    where
        parseParantheses = operatorSymbol "(" *> parseExpression <* operatorSymbol ")"



parseBool :: Parser Expression
parseBool = parseTrue <|> parseFalse

parseTrue :: Parser Expression
parseTrue = Value True <$ parserLexeme (string' "true") 

parseFalse :: Parser Expression
parseFalse = Value False <$ parserLexeme (string' "false")
