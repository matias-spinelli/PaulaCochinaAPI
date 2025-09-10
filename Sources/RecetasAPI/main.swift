import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

// Puerto dinámico (para Render, etc.)
if let portString = Environment.get("PORT"), let port = Int(portString) {
    app.http.server.configuration.port = port
}

// 👇 IMPORTANTE: escuchar en todas las interfaces
app.http.server.configuration.hostname = "0.0.0.0"

// Configuración general (Mongo, rutas, etc.)
try configure(app)

// Ejecutar la app
try app.run()
