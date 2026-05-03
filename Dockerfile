FROM haskell:9.8-bullseye

WORKDIR /app

# Copia os arquivos de configuração primeiro para o Docker fazer cache
COPY stack.yaml package.yaml ./

# Copia o resto do projeto
COPY . .

# Compila o projeto
RUN stack build --system-ghc --allow-different-user

# O comando que mantém o servidor de pé na nuvem
CMD ["stack", "run", "--allow-different-user"]
