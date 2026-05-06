import Text.Megaparsec
import Test.HUnit
import Logic
import Parser


testEvaluate :: Test
testEvaluate = TestCase $ do
    assertEqual "Em caso de Bool, deve retornar o proprio valor" 
                True (evaluate (Value True) [])

    assertEqual "Em caso de variavel, deve retornar o valor da variavel no ambiente" 
                True (evaluate (Variable "A") [("A", True)])

    assertEqual "Em caso de operador 'NOT', deve retornar (not expressao)" 
                False (evaluate (Not (Value True)) [])

    assertEqual "Em caso de operador 'AND', deve retornar (esq && dir)" 
                False (evaluate (And (Value True) (Value False)) [])

    assertEqual "Em caso de operador 'OR', deve retornar (esq || dir)" 
                True (evaluate (Or (Value True) (Value False)) [])



assertParse :: String -> Expression -> String -> Assertion
assertParse message expected input = assertEqual message (Right expected) (parse parseExpressionComplete "source" input)

testParser :: Test
testParser = TestCase $ do
    assertParse "parseExpression - variavel isolada" 
                (Variable "A") "A"

    assertParse "parseExpression - operador NOT" 
                (Not (Variable "A")) "!A"

    assertParse "parseExpression - operador AND" 
                (And (Variable "A") (Variable "B")) "A && B"

    assertParse "parseExpression - operador OR" 
                (Or (Variable "A") (Variable "B")) "A || B"

    assertParse "parseExpression - operador XOR"
                (Xor (Variable "A") (Variable "B")) "A XOR B"

    assertParse "parseExpression - operador ImpliesRight"
                (ImpliesRight (Variable "A") (Variable "B")) "A -> B"

    assertParse "parseExpression - operador ImpliesLeft"
                (ImpliesLeft (Variable "A") (Variable "B")) "A <- B"

    assertParse "parseExpression - hierarquia (! > && > XOR > || > '->' > '<-')" 
                (Or (Not (Variable "A"))(And (Variable "B") (Variable "C")))"!A || B && C"

    assertParse "parseExpression - hierarquia (! > && > XOR > || > '->' > '<-')"
                (ImpliesRight (Or (Variable "A") (Xor (Variable "B") (Variable "C"))) (Variable "A")) "A || B XOR C -> A"

    assertParse "parseExpression - hierarquia (! > && > XOR > || > '->' > '<-')"
                (ImpliesLeft (Variable "A") (Or (Xor (Variable "B") (Variable "C")) (Variable "A"))) "A <- B XOR C || A"

    assertParse "parseExpression - parenteses"
                (And (Not (Or (Variable "A") (Variable "B"))) (Variable "C")) "!(A || B) && C"

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
