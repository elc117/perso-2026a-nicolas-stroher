import Test.HUnit
import Logica

testeAmbiente :: Test
testeAmbiente = TestCase $ do
    assertEqual "Deve adicionar lista de tuplas ao ambiente" [("A", True)] (atualizaAmbiente [("A", True)] [])
    assertEqual "Deve adicionar lista de tuplas ao ambiente" [("B", False), ("A", True)] (atualizaAmbiente [("B", False)] [("A", True)])

testeAvaliar :: Test
testeAvaliar = TestCase $ do
    assertEqual "Em caso de Bool, deve retornar o proprio valor" True (avaliar [] (Valor True))
    assertEqual "Em caso de variavel, deve retornar o valor da variavel no ambiente" True (avaliar [("A", True)] (Variavel "A"))
    assertEqual "Em caso de operador 'NOT', deve retornar (not expressao)" False (avaliar [] (Nao (Valor True)))
    assertEqual "Em caso de operador 'AND', deve retornar (esq && dir)" False (avaliar [] (E (Valor True) (Valor False)))
    assertEqual "Em caso de operador 'OR', deve retornar (esq || dir)" True (avaliar [] (Ou (Valor True) (Valor False)))

testSuite :: Test
testSuite = TestList
    [TestLabel "Teste de Ambiente" testeAmbiente,
     TestLabel "Teste de avaliacao de expressoes" testeAvaliar
    ]

main :: IO Counts
main = do
    runTestTT testSuite
