# ======================
# Etapa de build
# ======================
FROM swift:5.9 as build

WORKDIR /app

# Copiar dependencias primero (cacheo)
COPY Package.* ./
RUN swift package resolve

# Copiar código
COPY . .

# Compilar en release (con stdlib estática de Swift)
RUN swift build -c release --static-swift-stdlib


# ======================
# Etapa de runtime
# ======================
FROM swift:5.9 as runtime

WORKDIR /app

# Copiar el binario compilado
COPY --from=build /app/.build/release/RecetasAPI /app/RecetasAPI
RUN chmod +x /app/RecetasAPI

# Instalar sqlite3 si lo necesitás en runtime
RUN apt-get update && apt-get install -y sqlite3 libsqlite3-dev && rm -rf /var/lib/apt/lists/*

# Puerto que expone Vapor
EXPOSE 8080

# Comando de arranque
CMD ["/app/RecetasAPI"]
