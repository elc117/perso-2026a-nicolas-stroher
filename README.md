
## 1. Identificação
- Nome: Nícolas Atkinson Ströher
- Curso: Sistemas de Informação (3° semestre) - UFSM/2026
## 2. Tema/Objetivo
O objetivo desse trabalho é desenvolver habilidades com o uso de linguagem funcional, sendo ela o Haskell.
A implementação consiste em um aplicativo web que avalia expressões lógicas.
- FRONTEND: Javascript em framework Vite
  - O frontend recebe as expressões do usuário e as envia para o backend. O próprio frontend já valida parcialmente expressões válidas ou inválidas.
- BACKEND - Haskell, com bibliotecas de web (Scotty) e parsing (megaparsec)
  - O backend recebe as expressões e é responsável por interpretá-las. Isso acontece através de parsers e de uma função avaliadora.
 
A funcionalidade do backend se apoia fortemente em bibliotecas externas, destacadamente Megaparsec. Ainda assim, reforçou fortemente meu conhecimento quanto à sintaxe do Haskell e seus recursos, visto que para entender a biblioteca e para juntar os fragmentos no código foi necessário um bom conhecimento e ampla pesquisa sobre a sintaxe e funcionamento do Haskell.
Recursos novos que foram pesquisados e utilizados consistem em:
-  Operadores, como "<|>" e "*>";
- Tipos de dados, como Maybe, Just, Either (Left, Right);
- Customização de tipos de dados com "data", "deriving", "type" e "instance"; 
- Manipulação de dados com parsers e com a biblioteca Data; 
- Utilização da biblioteca HUnit para testes unitários; 
- Aplicação de um middleware para controle de tráfego HTTP (CORS);
- Biblioteca de comunicação server-like (Scotty);
- Entre outros recursos fora do Haskell (Docker, Render, Javascript...).

## 3. Processo de Desenvolvimento
O desenvolvimento começou pela biblioteca do Scotty. Com a ideia principal de criar um avaliador lógico já em mente, primeiro foi testado um código robusto em Haskell para receber um pacote Json de um frontend em puro HTML/Javascript. Essa parte não foi tão desafiadora, visto que é bem simples definir rotas com a biblioteca Scotty.
O primeiro problema surgiu ao tentar retornar uma resposta para o frontend. Para permitir o tráfego nas rotas/portas definidas, foi utilizado inicialmente o middleware simpleCors. O simpleCors, porém, não conseguia tratar os métodos POST e OPTION corretamete. Quando isso foi descoberto, o middleware teve que ser alterado com uma política mais robusta do Cors
```
politicaCors :: Middleware
politicaCors = cors (const $ Just policy)
	where
		policy = simpleCorsResourcePolicy {
			(...) -- define métodos, origens e headers
		}


main = do
	-- middleware simpleCors - não cobre mais todas as possibilidades
	middleware politicaCors
```
Assim que o servidor Scotty funcionou corretamente para todos os métodos necessários (GET, POST, OPTIONS), o foco se tornou começar o desenvolvimento da lógica de expressões. Para começar, foram definidos os operadores a serem suportados: NOT, AND, OR, XOR, IMPLIESRIGHT e IMPLIESLEFT. Então, precisava-se de uma forma tratar uma expressão lógica e identificar os operadores. Isso foi feito com um novo tipo de dado:
```
data Expression
	= Value Bool
	| Variable String
	| Not  Expression
	| And Expression Expression
	| Xor Expression Expression
	| Or Expression Expression
	| ImpliesRight Expression Expression
	| ImpliesLeft Expression Expression
```
Uma Expression pode significar um dado no formato de qualquer um de seus construtores (Value, Variable...). Note que, com exceção dos construtores Value e Variable, todos representam um operador lógico, e contêm outra(s) expressão/expressões em seu corpo.
```
let Expression bool1 = Value True
let Expression var1 = Variable "Variavel"

let Expression expr = And bool1 var1
```
Como comentado, Value e Variable não representam operadores. Isso é porquê a ideia para interpretar uma Expression se baseia em recursividade: divide-se as Expressions repetidamente até alcançar uma que possua um valor booleano, ou seja, uma Expression Valor.
Mas Variable não possui valor booleano. Isso é porquê  a string representa o nome de uma variável, o valor booleano será retirado dessa variável.
A esse ponto, sabemos o que fazer: devemos implementar um jeito de interpretar Value e Variable, e a interpretação do restante se reduz à essas duas. Isso foi feito em uma função "evaluate":
```
evaluate :: Expression -> Environment -> Bool
evaluate expression env = 
	case expression of
		Value boolean -> boolean
		
		Variable name -> case lookup name env of
			Just value -> value
			Nothing -> error "Variavel nao encontrada no ambiente"
		
		Not exp -> not (evaluate exp env)
		
		And left right -> (evaluate left env) && (evaluate right env)
		(...)
```
Environment nada mais é do que um sinônimo para uma lista de tuplas, que simboliza as variáveis disponíveis no ambiente.
```
type Environment = [(String, bool)]

-- Ex.: [("A", True), ("B", False)]
-- OBS: True e False NÃO são case sensitive no parsing e interpretação das expressões
```
Assim, temos uma forma de reduzir uma Expression a um valor booleano.
Para completar o interpretador, só precisamos de uma forma de identificar vários operadores em uma expressão e organizar as operações em ordem de precedência (NOT > AND > XOR > OR > IMPLIESRIGHT > IMPLIESLEFT).
Como não tinha conhecimento de como fazer isso, fui pesquisar sobre o que era e como implementar um "parser".

O parser nada mais é do que um programa ou componente que transforma dados brutos em um formato compreensível. Nesse caso, o resultado deve ser compreensível para evaluate. Isso é feito ao gerar uma Árvore Sintática (AST), que representa a expressão original (String) como uma Expression que pode ser analisada por evaluate. 
Vimos que evaluate reduz as expressções a valores booleanos. Então, precisamos conseguir "parsar" esses valores:
```
parseBool  ::  Parser  Expression
parseBool = parseTrue <|> parseFalse

parseTrue  ::  Parser  Expression
parseTrue =  Value  True  <$ parserLexeme (string' "true")

parseFalse  ::  Parser  Expression
parseFalse =  Value  False  <$ parserLexeme (string' "false")
```
O parserLexeme nada mais é que um parser que funciona como um "wrapper" para outro parser, removendo espaços em branco da expressão.
Agora, precisamos de um parser para nossas expressões em geral. A implementação completa pode ser vista em Parser.hs, mas sua funcionalidade parcial é essa:
```
parseExpression :: Parser Expression
parseExpression = (...)

let expr = "!A && B"
let Right ast = parse parserExpression "" expr

-- ast = (And (Not (Variable "A")) (Variable "B"))
```
Agora temos uma expressão no formato aceito pelo nosso tipo de dado Expression. Assim, podemos utilizá-lo em evaluate para obter nosso resultado booleano.

## 4. Testes
