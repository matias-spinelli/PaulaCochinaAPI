import Vapor
import Fluent
import FluentSQLiteDriver

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

// Puerto dinámico
if let portString = Environment.get("PORT"), let port = Int(portString) {
    app.http.server.configuration.port = port
}

// 👇 FIX: siempre escuchar en 0.0.0.0 (no localhost)
app.http.server.configuration.hostname = "0.0.0.0"

try configure(app)
try app.run()
