//
//  AuthMiddleware.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 11/09/2025.
//

import Vapor
import JWT

struct AuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Buscar token en query (?auth=xxx) o en header Authorization
        let rawToken: String? = request.query[String.self, at: "auth"]
            ?? request.headers.bearerAuthorization?.token

        guard var token = rawToken?.trimmingCharacters(in: .whitespacesAndNewlines),
              !token.isEmpty else {
            return makeErrorResponse(.unauthorized, "No se envió token de autenticación (?auth=)")
        }

        // Decodificar si viene URL-encoded (ej: %2E por ".")
        if let decoded = token.removingPercentEncoding {
            token = decoded
        }

        do {
            // Verificar el token JWT
            let payload = try request.jwt.verify(token, as: AuthPayload.self)
            request.auth.login(UserIdentity(uid: payload.uid, email: payload.email))
            request.logger.info("✅ JWT verificado para usuario: \(payload.email)")

            return try await next.respond(to: request)

        } catch let jwtError as JWTError {
            // Errores propios del JWT (firma, expiración, formato, etc.)
            request.logger.warning("❌ JWT Error: \(jwtError)")
            return makeErrorResponse(.unauthorized, "Token inválido o expirado (\(jwtError.localizedDescription))")

        } catch let decodingError as DecodingError {
            // Errores de decodificación (JSON mal formado, token corrupto, etc.)
            let contextDescription = describeDecodingError(decodingError)
            request.logger.warning("⚠️ Decoding error: \(contextDescription)")
            return makeErrorResponse(.badRequest, "Error interpretando datos del request: \(contextDescription)")

        } catch {
            // Cualquier otro error inesperado
            request.logger.warning("💥 Auth unexpected error: \(error)")
            return makeErrorResponse(.internalServerError, "Error inesperado en autenticación (\(error.localizedDescription))")
        }
    }

    /// Construye un texto descriptivo del DecodingError (más útil para debugging)
    private func describeDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Tipo inesperado '\(type)' en \(context.codingPath.map(\.stringValue).joined(separator: ".")) — \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Valor faltante para '\(type)' en \(context.codingPath.map(\.stringValue).joined(separator: ".")) — \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Falta la clave '\(key.stringValue)' en el JSON — \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Datos corruptos o formato inválido — \(context.debugDescription)"
        @unknown default:
            return "Error desconocido decodificando payload"
        }
    }

    private func makeErrorResponse(_ status: HTTPResponseStatus, _ error: String) -> Response {
        let payload = ErrorResponse(error)
        let data = try! JSONEncoder().encode(payload)
        return Response(status: status, body: .init(data: data))
    }
}
