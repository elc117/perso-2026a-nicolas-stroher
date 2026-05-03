module Logic where

data Expression
    = Value Bool
    | Variable String
    | Not Expression
    | And Expression Expression
    | Or Expression Expression
    | Xor Expression Expression
    | ImpliesRight Expression Expression
    | ImpliesLeft Expression Expression
    deriving(Show, Eq)

-- Lista de variaveis disponiveis
type Environment = [(String, Bool)]

evaluate :: Expression -> Environment -> Bool
evaluate expression env  =
    case expression of
        Value boolean -> boolean

        Variable name -> case lookup name env of
            Just value -> value
            Nothing -> error "Variavel nao encontrada no ambiente"
        
        Not exp -> not (evaluate exp env)
        
        And left right -> evaluate left env && evaluate right env

        Xor left right -> (evaluate left env) /= (evaluate right env)

        Or left right -> evaluate left env || evaluate right env

        ImpliesRight left right -> evaluate (Or (Not left) (right)) env

        ImpliesLeft left right -> evaluate (Or (Not right) (left)) env
