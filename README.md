# PaulaCochina API 🍲

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![Vapor](https://img.shields.io/badge/Vapor-0D0D0D?style=for-the-badge&logo=vapor&logoColor=blue)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**PaulaCochina API** es el backend desarrollado en **Swift** utilizando el framework **Vapor**.
Expone un **CRUD de recetas** conectado a **MongoDB**, con soporte de autenticación basada en **JWT**.
El proyecto forma parte del trabajo práctico final de un curso, complementando al frontend hecho en Angular.

---

## 🚀 Tecnologías utilizadas

- **Swift 6+**
- **Vapor 4**
- **MongoKitten** (para conexión con MongoDB)
- **JWT** (para autenticación con tokens)
- **CORS Middleware** (para permitir requests desde frontend)
- Deploy en **Render.com**

---

## ✨ Funcionalidades principales

- 📌 **Autenticación** con JWT (login y protección de endpoints).
- 📖 **CRUD de Recetas**:
  - Crear (`POST /api/recipes/add`)
  - Leer (`GET /api/recipes/get`)
  - Editar (`PUT /api/recipes/edit/:id`)
  - Eliminar (`DELETE /api/recipes/delete/:id`)
- 🛡️ **Middleware de seguridad**: validación de tokens, cierre de sesión si expira.
- 📜 **Middleware de logging**: registra método, ruta, body (con password/token ocultos) y headers.

---

## 📂 Estructura del proyecto

Sources/
├── RecetasAPI/
│ ├── Controllers/          # Controladores de rutas (RecipesController, AuthController, etc.)
│ ├── Middleware/           # Middlewares personalizados (LoggingMiddleware, etc.)
│ ├── Models/               # Modelos de datos (Recipe, User)
│ ├── configure.swift       # Configuración inicial (MongoDB, JWT, CORS)
│ └── routes.swift          # Definición de rutas
└── Run/
└── main.swift              # Punto de entrada de la app


---

## 🔧 Instalación y ejecución local

```bash
# Clonar el repositorio
git clone https://github.com/matias-spinelli/PaulaCochina-API.git

# Entrar al directorio
cd PaulaCochina-API

# Instalar dependencias con SwiftPM
swift build

# Ejecutar en modo desarrollo
swift run
La API corre por defecto en http://localhost:8080.
```

---

## 🌍 Variables de entorno necesarias

Antes de ejecutar, asegurate de configurar:

```bash
MONGO_URL=mongodb+srv://<user>:<password>@cluster-url/dbname
JWT_SECRET=super-secret-key
PORT=8080   # (opcional, Render asigna uno dinámicamente)
```
---

## 🔥 Ejemplo de endpoints
Obtener recetas

```bash
GET /api/recipes/get?auth=<JWT_TOKEN>
```

Crear receta

```bash
POST /api/recipes/add?auth=<JWT_TOKEN>

Content-Type: application/json

{
  "name": "Milanesa con papas fritas",
  "description": "Clásico argentino 💙💛💙",
  "imagePath": "https://mis-imagenes.com/milanesa.jpg",
  "ingredients": [
    { "name": "Carne", "amount": 1 },
    { "name": "Papas", "amount": 3 }
  ]
}
```

---

## ☁️ Deploy

La API está deployada en Render.com y disponible públicamente:

👉 https://recetasapi.onrender.com/

---

## 🌟 Créditos

Proyecto creado por **Matías Spinelli**
([@matias-spinelli](https://github.com/matias-spinelli))\
Backend desarrollado en **Swift** + **Vapor**, como parte de un curso con fines de práctica y aprendizaje.

---

## 📜 Licencia

MIT License © 2025
