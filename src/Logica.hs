module Logica where

data Expressao
    = Valor Bool
    | Variavel String
    | Not Expressao
    | And Expressao Expressao
    | Or Expressao Expressao
    deriving(Show, Eq)

-- Lista de variaveis disponiveis - comunicacao com o parser a ser implementada
type Ambiente = [(String, Bool)]

-- Env local, retorno deve ser armazenado. Provavelmente vai ser melhorado
atualizaAmbiente :: Ambiente -> Ambiente -> Ambiente
atualizaAmbiente novo env = novo ++ env

avaliar :: Ambiente -> Expressao -> Bool
avaliar env expressao =
    case expressao of
        Valor booleano -> booleano

        Variavel nome -> case lookup nome env of
            Just valor -> valor
            Nothing -> error "Variável não encontrada no ambiente"
        
        Not exp -> not (avaliar env exp)
        
        And esq dir -> avaliar env esq && avaliar env dir

        Or esq dir -> avaliar env esq || avaliar env dir
