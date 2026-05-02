module Logica where

data Expressao
    = Valor Bool
    | Variavel String
    | Nao Expressao
    | E Expressao Expressao
    | Ou Expressao Expressao
    deriving(Show, Eq)

type Ambiente = [(String, Bool)]

atualizaAmbiente :: Ambiente -> Ambiente -> Ambiente
atualizaAmbiente novo env = novo ++ env

avaliar :: Ambiente -> Expressao -> Bool
avaliar env expressao =
    case expressao of
        Valor booleano -> booleano

        Variavel nome -> case lookup nome env of
            Just valor -> valor
            Nothing -> error "Variável não encontrada no ambiente"
        
        Nao exp-> not (avaliar env exp)
        
        E esq dir -> avaliar env esq && avaliar env dir

        Ou esq dir -> avaliar env esq || avaliar env dir
