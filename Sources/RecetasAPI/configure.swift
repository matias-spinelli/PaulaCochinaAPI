import Vapor
import Fluent
import FluentMongoDriver

public func configure(_ app: Application) throws {
    
    // Puerto dinámico para Render
    if let portEnv = Environment.get("PORT"), let port = Int(portEnv) {
        app.http.server.configuration.port = port
    }

    // 🚀 Configurar conexión a MongoDB
    guard let mongoURL = Environment.get("MONGO_URL") else {
        fatalError("❌ Faltó configurar MONGO_URL en las variables de entorno")
    }

    try app.databases.use(.mongo(connectionString: mongoURL), as: .mongo)

    // Migraciones (si vas a usar)
    app.migrations.add(CreateRecipe())

    // Rutas
    try routes(app)

    try app.autoMigrate().wait()
}
