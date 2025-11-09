# PaulaCochina API 🍲

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![Vapor](https://img.shields.io/badge/Vapor-0D0D0D?style=for-the-badge&logo=vapor&logoColor=blue)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**PaulaCochina API** es el backend desarrollado en **Swift** utilizando el framework **Vapor**.  
Expone un sistema completo de **usuarios, recetas, favoritos y lista de compras**,  
con persistencia en **MongoDB** y autenticación mediante **JWT**.  

El proyecto complementa al frontend hecho en **Angular**,  
como parte del trabajo práctico final del curso.


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

- 🔐 **Autenticación completa**
  - Registro (`/api/auth/signup`)
  - Login (`/api/auth/login`)
  - Tokens JWT con expiración y validación en middleware
- 📖 **CRUD de Recetas**
  - Crear, obtener, actualizar y eliminar recetas
  - Validaciones: título ≥3 caracteres, descripción ≥10, ingredientes obligatorios
- 💖 **Favoritos**
  - Marcar y desmarcar recetas como favoritas por usuario
  - Consultar todas las recetas favoritas
- 🛒 **Lista de Compras**
  - Agregar ingredientes manualmente o desde una receta
  - Editar, eliminar o vaciar lista completa
- 🧩 **Middlewares personalizados**
  - Seguridad JWT
  - Logging de requests (con ocultamiento de contraseñas/tokens)
  - Manejo centralizado de errores
- 🧠 **Arquitectura limpia**
  - Separación clara entre controladores, modelos y middlewares
  - Respuestas uniformes con mensajes y status codes consistentes

---

## 📂 Estructura del proyecto

Sources/
├── PaulaCochinaAPI/
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

## 📡 Endpoints disponibles

### 🔐 Autenticación (`/api/auth`)
| Método | Endpoint | Descripción |
|:-------|:----------|:-------------|
| ![POST](https://img.shields.io/badge/POST-2196F3?style=for-the-badge&logo=) | `/signup` | Crear un nuevo usuario |
| ![POST](https://img.shields.io/badge/POST-2196F3?style=for-the-badge&logo=) | `/login` | Iniciar sesión y obtener token JWT |

---

### 📖 Recetas (`/api/recipes`)
| Método | Endpoint | Descripción |
|:-------|:----------|:-------------|
| ![GET](https://img.shields.io/badge/GET-4CAF50?style=for-the-badge&logo=) | `/` | Obtener todas las recetas del usuario |
| ![POST](https://img.shields.io/badge/POST-2196F3?style=for-the-badge&logo=) | `/` | Crear una nueva receta |
| ![PUT](https://img.shields.io/badge/PUT-FF9800?style=for-the-badge&logo=) | `/:id` | Actualizar una receta existente |
| ![DELETE](https://img.shields.io/badge/DELETE-F44336?style=for-the-badge&logo=) | `/:id` | Eliminar una receta |

---

### 💖 Favoritos (`/api/favorites`)
| Método | Endpoint | Descripción |
|:-------|:----------|:-------------|
| ![GET](https://img.shields.io/badge/GET-4CAF50?style=for-the-badge&logo=) | `/` | Obtener recetas favoritas del usuario |
| ![POST](https://img.shields.io/badge/POST-2196F3?style=for-the-badge&logo=) | `/users/:userId/favorites` | Agregar receta a favoritos |
| **DELETE** | `/favorites/:recipeId` | Quitar receta de favoritos |

---

### 🛒 Lista de Compras (`/api/shopping-list`)
| Método | Endpoint | Descripción |
|:-------|:----------|:-------------|
| ![GET](https://img.shields.io/badge/GET-4CAF50?style=for-the-badge&logo=) | `/` | Obtener lista completa |
| ![POST](https://img.shields.io/badge/POST-2196F3?style=for-the-badge&logo=)| `/` | Agregar ingredientes manualmente o desde receta |
| ![PUT](https://img.shields.io/badge/PUT-FF9800?style=for-the-badge&logo=)| `/users/:userId/shopping-list` | Editar ingrediente existente |
| ![DELETE](https://img.shields.io/badge/DELETE-F44336?style=for-the-badge&logo=) | `/shopping-list/:ingredientId` | Eliminar un ingrediente |
| ![DELETE](https://img.shields.io/badge/DELETE-F44336?style=for-the-badge&logo=) | `/shopping-list` | Vaciar lista completa |


---

## ☁️ Deploy

La API está deployada en Render.com y disponible públicamente:

👉 https://paulacochinaapi.onrender.com/

---

## 🌟 Créditos

Proyecto creado por **Matías Spinelli**
([@matias-spinelli](https://github.com/matias-spinelli))\
Backend desarrollado en **Swift** + **Vapor**, como parte de un curso con fines de práctica y aprendizaje.

---

## 📜 Licencia

MIT License © 2025
