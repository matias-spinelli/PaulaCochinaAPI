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
        // Buscar token en query (?auth=xxx) o header Authorization
        let token: String?
        if let authQuery = request.query[String.self, at: "auth"] {
            token = authQuery
        } else if let bearer = request.headers.bearerAuthorization {
            token = bearer.token
        } else {
            throw Abort(.unauthorized, reason: "No auth token provided")
        }

        guard let token = token else {
            throw Abort(.unauthorized, reason: "Missing token")
        }

        do {
            let payload = try request.jwt.verify(token, as: AuthPayload.self)
            
            // Podés guardar el email o userId en el Request para usar después
            request.auth.login(UserIdentity(uid: payload.uid, email: payload.email))

            return try await next.respond(to: request)
        } catch {
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
    }
}
