import Vapor
import MongoKitten

var mongoDB: MongoDatabase!

public func configure(_ app: Application) throws {
    // Puerto dinámico (Render)
    if let portEnv = Environment.get("PORT"), let port = Int(portEnv) {
        app.http.server.configuration.port = port
    }

    // 🚀 Conexión a MongoKitten (async)
    Task {
        do {
            guard let mongoURL = Environment.get("MONGO_URL") else {
                fatalError("❌ Faltó configurar MONGO_URL en las variables de entorno")
            }

            mongoDB = try await MongoDatabase.connect(to: mongoURL)
            app.logger.info("✅ Conectado a MongoDB")
        } catch {
            app.logger.error("❌ Error conectando a MongoDB: \(error)")
        }
    }

    // Rutas
    try routes(app)
}
