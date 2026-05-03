{-# LANGUAGE OverloadedStrings #-}
module Parser where

import Text.Megaparsec
import Text.Megaparsec.Char
import Control.Monad.Combinators.Expr
import Text.Megaparsec.Char.Lexer as L
import Data.Void
import Logica

type Parser = Parsec Void String



-- Implementa somente a remocao de espaços em branco, sem tratar comentarios
ws :: Parser ()
ws = L.space space1 empty empty

-- Funciona como um wrapper para parsers, eliminando os espacos em branco
parserLexeme :: Parser a -> Parser a
parserLexeme p = p <* ws



-- Construtores na tabela sao tratados em makeExprParser, que cria os parsers
-- Possivel futura implementacao de XOR
tabelaOperacoes :: [[Operator Parser Expressao]]
tabelaOperacoes = 
    [ [Prefix (Not <$ parserLexeme (char '!'))]
    , [InfixL (And <$ parserLexeme (string "&&"))]
    , [InfixL (Or <$ parserLexeme (string "||"))]
    ]

-- makeExprParser trata os operadores em tabelaOperacoes. Caso nenhum seja o procurado, passa para parseTermo
parseExpressao :: Parser Expressao
parseExpressao = makeExprParser parseTermo tabelaOperacoes

parseVariavel :: Parser Expressao
parseVariavel = Variavel <$> parserLexeme (some letterChar)

parseTermo :: Parser Expressao
parseTermo = parseBool <|> parseVariavel <|> parseEntreParenteses
    where
        parseEntreParenteses = char '(' *> parseExpressao <* char ')'



parseBool :: Parser Expressao
parseBool = parseTrue <|> parseFalse

parseTrue :: Parser Expressao
parseTrue = Valor True <$ parserLexeme (string' "true") 

parseFalse :: Parser Expressao
parseFalse = Valor False <$ parserLexeme (string' "false")
