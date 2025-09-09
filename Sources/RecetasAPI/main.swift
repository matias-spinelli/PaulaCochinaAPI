import Vapor
import Fluent
import FluentSQLiteDriver

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

if let portString = Environment.get("PORT"), let port = Int(portString) {
    app.http.server.configuration.port = port
}

try configure(app)
try app.run()
