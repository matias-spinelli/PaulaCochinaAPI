# Imagen oficial de Swift
FROM swift:6.0-amazonlinux2 as build

# Crear carpeta de trabajo
WORKDIR /app

# Copiar los archivos de tu proyecto
COPY . .

# Compilar en release
RUN swift build -c release

# Imagen más liviana para correr
FROM amazonlinux:2

# Instalar dependencias necesarias
RUN yum -y install libatomic sqlite

# Copiar el binario desde la etapa de build
COPY --from=build /app/.build/release/RecetasAPI /run

# Puerto que usará Render
ENV PORT=8080

# Exponer el puerto
EXPOSE 8080

# Ejecutar la app
CMD ["/run"]
