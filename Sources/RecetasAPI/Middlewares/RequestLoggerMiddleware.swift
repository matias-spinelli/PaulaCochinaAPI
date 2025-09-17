//
//  RequestLoggerMiddleware.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 17/09/2025.
//

import Vapor

struct RequestLoggerMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let startTime = Date()
        request.logger.info("📥 \(request.method.rawValue) \(request.url.path)")

        // Intentar leer el body (si existe)
        if let bodyData = request.body.data,
           let bodyString = bodyData.getString(at: 0, length: bodyData.readableBytes) {
            
            // Intentar parsear como JSON
            if let json = try? JSONSerialization.jsonObject(with: Data(bodyString.utf8), options: []) as? [String: Any] {
                var sanitized = json
                // Ocultar campos sensibles
                for key in ["password", "token", "authorization"] {
                    if sanitized[key] != nil {
                        sanitized[key] = "****"
                    }
                }
                request.logger.info("📦 Body: \(sanitized)")
            } else {
                // Si no es JSON, loguear como string plano
                request.logger.info("📦 Body: \(bodyString)")
            }
        }

        // Pasar la request a la siguiente capa
        let response = try await next.respond(to: request)

        let duration = Date().timeIntervalSince(startTime)
        request.logger.info("📤 \(request.method.rawValue) \(request.url.path) -> \(response.status.code) (\(String(format: "%.2f", duration))s)")

        return response
    }
}
