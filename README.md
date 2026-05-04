
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
Para finalizar, o frontend foi feito inteiramente com o Vercel AI e integrado manualmente ao projeto em um diretório frontend/. Além de alguns ajustes, a única parte do frontend em que foi preciso mais atenção foi na implementação de uma função fetch() para comunicação com o backend.

## 4. Testes
Para teste, utilizou-se a biblioteca HUnit para criar uma suíte de testes unitários. A suíte é formada essencialmente por testes de parser e de evaluate.
Como a lógica de interpretação é bem concisa, o teste dessas três funções (parseExpression, parseBool e evaluate) já é suficiente para garantir a lógica principal do programa.
```
testSuite  ::  Test
testSuite =  TestList
	[TestLabel  "Teste de avaliacao de expressoes" testEvaluate
	,TestLabel  "Teste de parseBool" testParseBool
	,TestLabel  "Teste de parseExpressao" testParser
]
```

## 5. Execução
A execução do projeto requer duas partes: a execução do backend e a execução do frontend.
Para executar o backend, é necessário possuir o GHCup, o GHC e o Stack instalado. Na raiz do projeto, execute simplesmente:
```
stack setup
stack run
```
Isso coloca o backend em funcionamento, pronto para receber dados do frontend.
Já quanto ao frontend, é necessário possuir o Node.js e o npm instalado. Na pasta frontend/, execute:
```
npm run dev
```
Assim, o frontend está funcionando e pronto para enviar dados para o backend e receber o resultado.
O repositório contém também um Dockerfile, que pode ser utilizado para resolver as dependências automaticamente em um container. Se você utiliza o VS Code, basta instalar o Docker e a extensão Dev Containers. Ao abrir o projeto como container, o Docker automaticamente instala as dependencias necessarias em um ambiente delimitado.

## 6. Deploy

O app está disponível em: https://logic-app-5rb3.onrender.com

O app está hosteado na web através do Render.
O deploy do app foi feito em duas partes: o deploy de um web service, e o deploy de um aplicativo estático.

Primeiro, foi feito o deploy do backend Haskell como web service. Esse web service é isolado do frontend, e é responsável exclusivamente por receber dados do frontend e processá-los para obter o resultado final. Por ser um web service, ele executa sob demanda de chamadas HTTP provenientes do frontend.

Depois, foi feito o deploy do frontend como um aplicativo estático. Ele é isolado do backend, e é responsável somente pela interface, comunicação com o usuário e por enviar a expressão crua para o backend.

Assim, o aplicativo na web é formado por duas partes essenciais, mas que não estão juntas em um único ambiente. Ao invés disso, elas são lançadas independentemente, e se comunicam através de regras de tráfego, gerenciadas pelo CORS.

## 7. Resultado Final

## 8. Uso de IA
### 8.1. IAs utilizadas
Ao longo do desenvolvimento, foi utilizado o apoio do Gemini 3 Pro e do GPT. O Gemini foi a principal IA utilizada, servindo principalmente como ferramenta de consulta de bibliotecas, para resolver dúvidas de sintaxe e para identificar problemas no geral. O GPT foi utilizado integrado no VS Code; por ter uma visão ampla do projeto a todo momento, foi a melhor opção em casos de problemas não identificados amplos, em que o problema pode estar em vários arquivos.

### 8.2. Interações relevantes

#### Dúvida de sintaxe/biblioteca
- Objetivo: esclarecer dúvidas quanto a sintaxe e utilização da biblioteca Aeson
```
No código haskell, a que 'object' e '.=' se referem? como eles são classificados e como
funcionam de acordo com a documentação do Aeson?
```
- O que foi aproveitado: 

## 9. Referências e Créditos
- Documentação do Megaparsec - https://hackage.haskell.org/package/megaparsec
- Blog Monday Morning Haskell - https://mmhaskell.com/
- Canal do Youtube "Purely Haskell" - https://www.youtube.com/watch?v=-VFBFutfT-s&t=1231s
