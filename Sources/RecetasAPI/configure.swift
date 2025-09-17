//
//  configure.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 11/09/2025.
//

import Vapor
import MongoKitten
import JWT

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

    // 🔑 Configurar JWT signer
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "super-secret-key"))

    // 🌍 Middleware de CORS (permitimos todo porque es TP)
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    app.middleware.use(CORSMiddleware(configuration: corsConfiguration))

    // 📝 Middleware de logging custom
    app.middleware.use(RequestLoggerMiddleware())

    // Rutas
    try routes(app)
}
