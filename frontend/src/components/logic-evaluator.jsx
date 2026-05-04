"use client"

import { useState, useCallback } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import {
  Trash2,
  Play,
  RotateCcw,
  Sparkles,
  BookOpen,
  Lightbulb,
  History,
  X,
} from "lucide-react"

export function LogicEvaluator() {
  const [variables, setVariables] = useState([])
  const [expression, setExpression] = useState("")
  const [results, setResults] = useState([])
  const [varInput, setVarInput] = useState("")
  const [currentResult, setCurrentResult] = useState(null)
  const [isHistoryOpen, setIsHistoryOpen] = useState(false)
  const [inputError, setInputError] = useState("")

  // Verifica se o nome da variavel e valido (todas maiusculas OU inicia com maiuscula)
  const isValidVariableName = (name) => {
    if (!name || name.length === 0) return false
    // Aceita nomes totalmente em maiusculas (A, AB, VAR) ou iniciando com maiuscula (Var, Variable)
    return /^[A-Z][A-Za-z0-9]*$/.test(name)
  }

  // Faz o parse do valor booleano
  const parseBooleanValue = (value) => {
    const normalized = value.trim().toLowerCase()
    if (normalized === "true" || normalized === "1" || normalized === "t") {
      return true
    }
    if (normalized === "false" || normalized === "0" || normalized === "f") {
      return false
    }
    return null
  }

  // Adiciona variavel no formato "Nome = Valor"
  const addVariable = useCallback(() => {
    setInputError("")
    const input = varInput.trim()
    
    if (!input) return

    // Verifica se tem o formato "Nome = Valor"
    const match = input.match(/^([A-Za-z][A-Za-z0-9]*)\s*=\s*(.+)$/)
    
    if (!match) {
      setInputError("Use o formato: Nome = True ou Nome = False")
      return
    }

    const [, rawName, rawValue] = match
    const name = rawName.charAt(0).toUpperCase() + rawName.slice(1)
    
    if (!isValidVariableName(name)) {
      setInputError("Nome deve iniciar com letra maiuscula")
      return
    }

    const value = parseBooleanValue(rawValue)
    
    if (value === null) {
      setInputError("Valor deve ser True ou False")
      return
    }

    if (variables.some((v) => v.name === name)) {
      setInputError("Variavel ja existe")
      return
    }

    setVariables((prev) => [...prev, { name, value }])
    setVarInput("")
  }, [varInput, variables])

  const toggleVariable = useCallback((name) => {
    setVariables((prev) =>
      prev.map((v) => (v.name === name ? { ...v, value: !v.value } : v))
    )
  }, [])

  const removeVariable = useCallback((name) => {
    setVariables((prev) => prev.filter((v) => v.name !== name))
  }, [])

  // Envia a expressao para o haskell e recebe uma resposta
  // Envia a expressao para o haskell e recebe uma resposta
  // Envia um objeto de formato:
  // { expression: "!A && B", variables: { "A": true, "B": false } }
  // e espera receber um objeto de formato:
  // { result: false }
  const evaluate = useCallback(async () => {
    if (!expression.trim()) return

    // Converte array [{name, value}] para objeto {name: value} esperado pelo Haskell
    const variablesObj = variables.reduce((acc, { name, value }) => {
      acc[name] = value
      return acc
    }, {})

    const API_BASE_URL = import.meta.env.VITE_API_URL || ""

    const response = await fetch('/api/evaluate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json'},
      body: JSON.stringify({ expression, variables: variablesObj })
    })
    const { result } = await response.json()

    const newResult = {
      expression: expression.trim(),
      result,
      timestamp: new Date(),
    }

    setCurrentResult({
      expression: expression.trim(),
      result,
    })

    setResults((prev) => [newResult, ...prev.slice(0, 19)])

  }, [expression, variables])

  const clearAll = useCallback(() => {
    setVariables([])
    setExpression("")
    setCurrentResult(null)
    setInputError("")
  }, [])

  const clearHistory = useCallback(() => {
    setResults([])
  }, [])

  const insertExample = useCallback((example) => {
    setExpression(example)
    setCurrentResult(null)
  }, [])

  const examples = [
    { label: "A AND B", expr: "A AND B" },
    { label: "A && B", expr: "A && B" },
    { label: "A OR B", expr: "A OR B" },
    { label: "A || B", expr: "A || B" },
    { label: "NOT A", expr: "NOT A" },
    { label: "!A", expr: "!A" },
    { label: "A -> B", expr: "A -> B" },
    { label: "A <- B", expr: "A <- B" },
  ]

  return (
    <div className="flex min-h-dvh justify-center px-4 py-6 md:items-center md:px-8 md:py-8">
      <div className="mx-auto w-full max-w-6xl">
        {/* Header */}
        <header className="mb-8 text-center">
          <h1 className="mb-2 text-balance text-3xl font-bold tracking-tight text-secondary md:text-4xl">
            Avaliador de Expressões Lógicas
          </h1>
          <p className="text-pretty text-muted-foreground">
            Insira variáveis, defina valores e avalie expressões lógicas em
            tempo real
          </p>
        </header>

        <div className="grid gap-6 lg:grid-cols-3">
          {/* Variables Panel */}
          <Card className="border-2 border-secondary lg:col-span-1">
            <CardHeader className="border-b-2 border-secondary bg-secondary/5 pb-4">
              <CardTitle className="flex items-center gap-2 text-secondary">
                <BookOpen className="h-5 w-5" />
                Variáveis
              </CardTitle>
            </CardHeader>
            <CardContent className="p-4">
              {/* Add Variable */}
              <div className="mb-2">
                <input
                  type="text"
                  value={varInput}
                  onChange={(e) => {
                    setVarInput(e.target.value)
                    setInputError("")
                  }}
                  onKeyDown={(e) => e.key === "Enter" && addVariable()}
                  placeholder="Ex: A = True, Var = False"
                  className="w-full rounded-md border-2 border-secondary bg-input px-3 py-2 font-mono text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
              
              {inputError && (
                <p className="mb-3 text-xs text-destructive">{inputError}</p>
              )}
              
              <p className="mb-4 text-xs text-muted-foreground">
                Formato: Nome = True ou Nome = False
              </p>

              {/* Variables List */}
              {variables.length === 0 ? (
                <div className="rounded-lg border-2 border-dashed border-muted-foreground/30 p-6 text-center">
                  <p className="text-sm text-muted-foreground">
                    Nenhuma variável definida
                  </p>
                  <p className="mt-1 text-xs text-muted-foreground">
                    Adicione variáveis como A = True, B = False...
                  </p>
                </div>
              ) : (
                <div className="space-y-2">
                  {variables.map((variable) => (
                    <div
                      key={variable.name}
                      className="flex items-center justify-between rounded-lg border-2 border-secondary bg-card p-3 transition-all hover:shadow-md"
                    >
                      <span className="font-mono font-bold text-secondary">
                        {variable.name}
                      </span>
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => toggleVariable(variable.name)}
                          className={`rounded-full px-4 py-1.5 text-sm font-bold transition-all ${
                            variable.value
                              ? "bg-accent text-accent-foreground shadow-md"
                              : "bg-destructive text-destructive-foreground"
                          }`}
                        >
                          {variable.value ? "TRUE" : "FALSE"}
                        </button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeVariable(variable.name)}
                          className="h-8 w-8 text-muted-foreground hover:text-destructive"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Expression Input Panel */}
          <Card className="border-2 border-secondary lg:col-span-2">
            <CardHeader className="border-b-2 border-secondary bg-secondary/5 pb-4">
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center gap-2 text-secondary">
                  <Lightbulb className="h-5 w-5" />
                  Expressão Lógica
                </CardTitle>
                <Dialog open={isHistoryOpen} onOpenChange={setIsHistoryOpen}>
                  <DialogTrigger asChild>
                    <Button
                      variant="outline"
                      size="sm"
                      className="border-2 border-secondary text-secondary hover:bg-secondary hover:text-secondary-foreground"
                    >
                      <History className="mr-2 h-4 w-4" />
                      Histórico
                      {results.length > 0 && (
                        <Badge
                          variant="secondary"
                          className="ml-2 bg-primary text-primary-foreground"
                        >
                          {results.length}
                        </Badge>
                      )}
                    </Button>
                  </DialogTrigger>
                  <DialogContent className="max-h-[80vh] overflow-hidden border-2 border-secondary sm:max-w-2xl">
                    <DialogHeader className="border-b-2 border-secondary pb-4">
                      <div className="flex items-center justify-between">
                        <DialogTitle className="flex items-center gap-2 text-secondary">
                          <History className="h-5 w-5" />
                          Histórico de Avaliações
                        </DialogTitle>
                        {results.length > 0 && (
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={clearHistory}
                            className="text-muted-foreground hover:text-destructive"
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            Limpar
                          </Button>
                        )}
                      </div>
                    </DialogHeader>
                    <div className="max-h-[60vh] overflow-y-auto py-4">
                      {results.length === 0 ? (
                        <div className="rounded-lg border-2 border-dashed border-muted-foreground/30 p-8 text-center">
                          <History className="mx-auto mb-3 h-10 w-10 text-muted-foreground/50" />
                          <p className="text-sm text-muted-foreground">
                            Nenhuma avaliação realizada ainda
                          </p>
                          <p className="mt-1 text-xs text-muted-foreground">
                            As avaliações aparecerão aqui
                          </p>
                        </div>
                      ) : (
                        <div className="space-y-3">
                          {results.map((result, index) => (
                            <div
                              key={index}
                              className={`flex items-center justify-between rounded-lg border-2 p-4 transition-all ${
                                result.result === true
                                  ? "border-accent bg-accent/10"
                                  : result.result === false
                                    ? "border-destructive bg-destructive/10"
                                    : "border-muted-foreground bg-muted"
                              }`}
                            >
                              <div className="flex-1">
                                <code className="font-mono text-sm text-secondary">
                                  {result.expression}
                                </code>
                                <p className="mt-1 text-xs text-muted-foreground">
                                  {result.timestamp.toLocaleTimeString("pt-BR")}
                                </p>
                              </div>
                              <div
                                className={`rounded-full px-4 py-2 font-bold ${
                                  result.result === true
                                    ? "bg-accent text-accent-foreground"
                                    : result.result === false
                                      ? "bg-destructive text-destructive-foreground"
                                      : "bg-muted-foreground text-background"
                                }`}
                              >
                                {result.result === true
                                  ? "TRUE"
                                  : result.result === false
                                    ? "FALSE"
                                    : "ERRO"}
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </DialogContent>
                </Dialog>
              </div>
            </CardHeader>
            <CardContent className="p-4">
              {/* Examples */}
              <div className="mb-4">
                <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                  Exemplos rápidos:
                </p>
                <div className="flex flex-wrap gap-2">
                  {examples.map((ex) => (
                    <button
                      key={ex.label}
                      onClick={() => insertExample(ex.expr)}
                      className="rounded-md border-2 border-secondary/50 bg-muted px-3 py-1.5 font-mono text-xs transition-all hover:border-primary hover:bg-primary/10"
                    >
                      {ex.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Textarea */}
              <Textarea
                value={expression}
                onChange={(e) => {
                  setExpression(e.target.value)
                  setCurrentResult(null)
                }}
                onKeyDown={(e) => {
                  if (e.key === "Enter" && !e.shiftKey) {
                    e.preventDefault()
                    evaluate()
                  }
                }}
                placeholder={"Digite sua expressão lógica...\nEx: (A AND B) OR (NOT C)\nOperadores: AND/&&, OR/||, NOT/!, IMPLIES/-> ou <-"}
                className="mb-4 min-h-[120px] resize-none border-2 border-secondary bg-input font-mono text-secondary placeholder:text-muted-foreground focus:ring-2 focus:ring-primary"
              />

              {/* Current Result Display */}
              {currentResult && (
                <div
                  className={`mb-4 flex items-center justify-between rounded-lg border-2 p-4 transition-all ${
                    currentResult.result === true
                      ? "border-accent bg-accent/10"
                      : currentResult.result === false
                        ? "border-destructive bg-destructive/10"
                        : "border-muted-foreground bg-muted"
                  }`}
                >
                  <div className="flex-1">
                    <p className="mb-1 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                      Resultado:
                    </p>
                    <code className="font-mono text-sm text-secondary">
                      {currentResult.expression}
                    </code>
                  </div>
                  <div className="flex items-center gap-3">
                    <div
                      className={`rounded-full px-5 py-2.5 text-lg font-bold ${
                        currentResult.result === true
                          ? "bg-accent text-accent-foreground"
                          : currentResult.result === false
                            ? "bg-destructive text-destructive-foreground"
                            : "bg-muted-foreground text-background"
                      }`}
                    >
                      {currentResult.result === true
                        ? "TRUE"
                        : currentResult.result === false
                          ? "FALSE"
                          : "ERRO"}
                    </div>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => setCurrentResult(null)}
                      className="h-8 w-8 text-muted-foreground hover:text-destructive"
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              )}

              {/* Operator Reference */}
              <div className="mb-4 rounded-lg border-2 border-dashed border-muted-foreground/30 bg-muted/50 p-3">
                <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                  Operadores suportados:
                </p>
                <div className="flex flex-wrap gap-2 text-xs">
                  <Badge variant="outline" className="font-mono">
                    AND / {"&&"}
                  </Badge>
                  <Badge variant="outline" className="font-mono">
                    OR / ||
                  </Badge>
                  <Badge variant="outline" className="font-mono">
                    NOT / !
                  </Badge>
                  <Badge variant="outline" className="font-mono">
                    IMPLIES / {"->"}, {"<-"}
                  </Badge>
                </div>
              </div>

              {/* Actions */}
              <div className="flex gap-3">
                <Button
                  onClick={evaluate}
                  className="flex-1 bg-primary text-primary-foreground hover:bg-primary/90"
                  disabled={!expression.trim()}
                >
                  <Play className="mr-2 h-4 w-4" />
                  Avaliar
                </Button>
                <Button
                  onClick={clearAll}
                  variant="outline"
                  className="border-2 border-secondary text-secondary hover:bg-secondary hover:text-secondary-foreground"
                >
                  <RotateCcw className="mr-2 h-4 w-4" />
                  Limpar
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Footer */}
        <footer className="mt-8 text-center text-sm text-muted-foreground">
          <p>
            Pressione{" "}
            <kbd className="rounded border border-secondary bg-muted px-1.5 py-0.5 font-mono text-xs">
              Enter
            </kbd>{" "}
            para avaliar rapidamente
          </p>
        </footer>
      </div>
    </div>
  )
}
