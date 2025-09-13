//
//  AuthMiddleware.swift
//  RecetasAPI
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
            let payload = try request.jwt.verify(token, as: AuthPayload.self)
            request.auth.login(UserIdentity(uid: payload.uid, email: payload.email))
            request.logger.info("✅ JWT verificado para usuario: \(payload.email)")
            return try await next.respond(to: request)
        } catch let error as JWTError {
            request.logger.warning("❌ JWT error: \(error)")
            return makeErrorResponse(.unauthorized, "Token inválido o expirado (\(error.localizedDescription))")
        } catch let error as DecodingError {
            request.logger.warning("❌ Decoding error: \(error)")
            return makeErrorResponse(.badRequest, "Error parseando payload del token (\(error.localizedDescription))")
        } catch {
            request.logger.warning("❌ Auth unexpected error: \(error)")
            return makeErrorResponse(.internalServerError, "Error inesperado en autenticación")
        }
    }

    private func makeErrorResponse(_ status: HTTPResponseStatus, _ error: String) -> Response {
        let payload = ErrorResponse(error)
        let data = try! JSONEncoder().encode(payload)
        return Response(status: status, body: .init(data: data))
    }
}
