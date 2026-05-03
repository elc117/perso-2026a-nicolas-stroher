import Text.Megaparsec
import Test.HUnit
import Logica
import Parser



testeAmbiente :: Test
testeAmbiente = TestCase $ do
    assertEqual "Deve adicionar lista de tuplas ao ambiente" 
                [("A", True)] (atualizaAmbiente [("A", True)] [])

    assertEqual "Deve adicionar lista de tuplas ao ambiente" 
                [("B", False), ("A", True)] (atualizaAmbiente [("B", False)] [("A", True)])

testeAvaliar :: Test
testeAvaliar = TestCase $ do
    assertEqual "Em caso de Bool, deve retornar o proprio valor" 
                True (avaliar [] (Valor True))

    assertEqual "Em caso de variavel, deve retornar o valor da variavel no ambiente" 
                True (avaliar [("A", True)] (Variavel "A"))

    assertEqual "Em caso de operador 'NOT', deve retornar (not expressao)" 
                False (avaliar [] (Not (Valor True)))

    assertEqual "Em caso de operador 'AND', deve retornar (esq && dir)" 
                False (avaliar [] (And (Valor True) (Valor False)))

    assertEqual "Em caso de operador 'OR', deve retornar (esq || dir)" 
                True (avaliar [] (Or (Valor True) (Valor False)))



assertParse :: String -> Expressao -> String -> Assertion
assertParse mensagem esperado input = assertEqual mensagem (Right esperado) (parse parseExpressao "source" input)

testeParser :: Test
testeParser = TestCase $ do
    assertParse "parseExpressao - variavel isolada" 
                (Variavel "A") "A"

    assertParse "parseExpressao - operador NOT" 
                (Not (Variavel "A")) "!A"

    assertParse "parseExpressao - operador AND" 
                (And (Variavel "A") (Variavel "B")) "A && B"

    assertParse "parseExpressao - operador OR" 
                (Or (Variavel "A") (Variavel "B")) "A || B"

    assertParse "parseExpressao - hierarquia (! > && > ||)" 
                (Or (Not (Variavel "A"))(And (Variavel "B") (Variavel "C")))"!A || B && C"

testeParseBool :: Test
testeParseBool = TestCase $ do
    assertEqual "parseBool deve retornar True para 'true'" 
                (Right (Valor True)) (parse parseBool "source" "true")

    assertEqual "parseBool deve retornar False para 'false'" 
                (Right (Valor False)) (parse parseBool "source" "false")



testSuite :: Test
testSuite = TestList
    [TestLabel "Teste de Ambiente" testeAmbiente
    ,TestLabel "Teste de avaliacao de expressoes" testeAvaliar
    ,TestLabel "Teste de parseBool" testeParseBool
    ,TestLabel "Teste de parseExpressao" testeParser
    ]

main :: IO Counts
main = do
    runTestTT testSuite
