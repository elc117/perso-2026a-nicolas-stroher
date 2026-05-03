import Text.Megaparsec
import Test.HUnit
import Logica
import Parser


testEvaluate :: Test
testEvaluate = TestCase $ do
    assertEqual "Em caso de Bool, deve retornar o proprio valor" 
                True (evaluate [] (Valor True))

    assertEqual "Em caso de variavel, deve retornar o valor da variavel no ambiente" 
                True (evaluate [("A", True)] (Variavel "A"))

    assertEqual "Em caso de operador 'NOT', deve retornar (not expressao)" 
                False (evaluate [] (Not (Valor True)))

    assertEqual "Em caso de operador 'AND', deve retornar (esq && dir)" 
                False (evaluate [] (And (Valor True) (Valor False)))

    assertEqual "Em caso de operador 'OR', deve retornar (esq || dir)" 
                True (evaluate [] (Or (Valor True) (Valor False)))



assertParse :: String -> Expressao -> String -> Assertion
assertParse message expected input = assertEqual message (Right expected) (parse parseExpressao "source" input)

testParser :: Test
testParser = TestCase $ do
    assertParse "parseExpressao - variavel isolada" 
                (Variable "A") "A"

    assertParse "parseExpressao - operador NOT" 
                (Not (Variable "A")) "!A"

    assertParse "parseExpressao - operador AND" 
                (And (Variable "A") (Variable "B")) "A && B"

    assertParse "parseExpressao - operador OR" 
                (Or (Variable "A") (Variable "B")) "A || B"

    assertParse ""

    assertParse "parseExpressao - hierarquia (! > && > ||)" 
                (Or (Not (Variable "A"))(And (Variable "B") (Variable "C")))"!A || B && C"

testParseBool :: Test
testParseBool = TestCase $ do
    assertEqual "parseBool deve retornar True para 'true'" 
                (Right (Value True)) (parse parseBool "source" "true")

    assertEqual "parseBool deve retornar False para 'false'" 
                (Right (Value False)) (parse parseBool "source" "false")



testSuite :: Test
testSuite = TestList
    [TestLabel "Teste de avaliacao de expressoes" testEvaluate
    ,TestLabel "Teste de parseBool" testParseBool
    ,TestLabel "Teste de parseExpressao" testParser
    ]

main :: IO Counts
main = do
    runTestTT testSuite
