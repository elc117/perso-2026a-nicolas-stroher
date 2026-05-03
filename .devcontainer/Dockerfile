FROM haskell:9.8-bullseye

# 1. Instala as dependências de sistema e o Node.js 20 LTS
RUN apt-get update && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Configura as variáveis de ambiente para instalação silenciosa do GHCup
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV BOOTSTRAP_HASKELL_MINIMAL=1

# 3. Baixa e instala o GHCup, e adiciona ele ao PATH do sistema
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ENV PATH="/root/.ghcup/bin:${PATH}"