
## 1. Identificação

- Nome: Nícolas Atkinson Ströher

- Curso: Sistemas de Informação (3° semestre) - UFSM/2026

## 2. Tema/Objetivo

O objetivo desse trabalho é desenvolver habilidades com o uso de linguagem funcional, sendo ela o Haskell.
A implementação consiste em um aplicativo web que avalia expressões lógicas.

- FRONTEND: Javascript em framework Vite
    O frontend recebe as expressões do usuário e as envia para o backend. O próprio frontend já valida parcialmente expressões válidas ou inválidas.

BACKEND: Haskell, com bibliotecas de web (Scotty) e parsing (megaparsec)
    O backend recebe as expressões e é responsável por interpretá-las. Isso acontece através de parsers e de uma função avaliadora. A lógica aceita os seguintes operadores:
```
NOT/! # tratado como '!'
AND/&&,
XOR,
OR/||,
IMPLIESRIGHT/->,
IMPLIESLEFT/<-
```
O parser trata o tipo Expression, que pode conter um construtor referente a um dos operadores disponíveis.