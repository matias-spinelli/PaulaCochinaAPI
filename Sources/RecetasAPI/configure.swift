import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
    // DB SQLite (archivo local db.sqlite)
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Migraciones
    app.migrations.add(CreateRecipe())

    // Rutas
    try routes(app)

    try app.autoMigrate().wait()
}
