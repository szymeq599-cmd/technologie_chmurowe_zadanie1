# syntax=docker/dockerfile:1.7

# ---------------------- ETAP 1:  
FROM node:18-slim AS builder

# Informacja o autorze zgodna ze standardem OCI
LABEL org.opencontainers.image.authors="Szymon Dobrasiewicz"

WORKDIR /app

# Kopiujemy tylko pliki potrzebne do instalacji zależności
COPY package*.json ./

# Instalacja tylko zależności produkcyjnych
RUN npm install --only=production

# Kopiujemy resztę plików źródłowych
COPY . .

# ---------------------- ETAP 2:  

# Wersja slim dla minimalizacji rozmiaru
FROM node:18-slim

WORKDIR /app

# Kopiujemy zainstalowane moduły i kod z etapu budowania
COPY --from=builder /app /app

ENV PORT=3030
EXPOSE 3030

# Healthcheck 
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3030', (r) => { if (r.statusCode === 200) process.exit(0); else process.exit(1); })"

CMD ["node", "app.js"]

