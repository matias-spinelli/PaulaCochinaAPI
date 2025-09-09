import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
    // Puerto dinámico para Render
    if let portEnv = Environment.get("PORT"), let port = Int(portEnv) {
        app.http.server.configuration.port = port
    }
    
    // DB SQLite (archivo local db.sqlite)
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Migraciones
    app.migrations.add(CreateRecipe())
    
    // Rutas
    try routes(app)

    try app.autoMigrate().wait()
}
