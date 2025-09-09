# Etapa de build
FROM swift:5.9 as build

WORKDIR /app

# Copiar dependencias primero (cacheo)
COPY Package.* ./
RUN swift package resolve

# Copiar código
COPY . .

# Compilar en release
RUN swift build -c release --static-swift-stdlib

# Etapa de runtime
FROM amazonlinux:2

RUN yum -y install libatomic sqlite tar gzip && yum clean all

WORKDIR /app

# Copiar el binario
COPY --from=build /app/.build/release/RecetasAPI /app/RecetasAPI
RUN chmod +x /app/RecetasAPI

EXPOSE 8080

CMD ["/app/RecetasAPI"]
