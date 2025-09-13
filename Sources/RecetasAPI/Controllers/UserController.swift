//
//  UserController.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 11/09/2025.
//

import Vapor
import MongoKitten
import JWT

struct UserController {
    // POST /api/auth/signup
    func signup(req: Request) async throws -> Response {
        let signupRequest = try req.content.decode(SignupRequest.self)
        let collection = mongoDB["users"]

        // Chequeo si ya existe
        if try await collection.findOne("email" == signupRequest.email) != nil {
            let error = ErrorResponse(.userExists)
            return try Response(
                status: .badRequest,
                body: .init(data: JSONEncoder().encode(error))
            )
        }

        // Validación simple de password
        guard signupRequest.password.count >= 6 else {
            let error = ErrorResponse(.passwordTooShort)
            return try Response(
                status: .badRequest,
                body: .init(data: JSONEncoder().encode(error))
            )
        }

        // Crear nuevo user
        let newUser = User(
            _id: ObjectId(),
            email: signupRequest.email,
            password: signupRequest.password // 🔥 plano, sin hash
        )

        try await collection.insertEncoded(newUser)

        // Generamos y devolvemos token response
        return try makeTokenResponse(for: newUser, req: req)
    }

    // POST /api/auth/login
    func login(req: Request) async throws -> Response {
        let loginRequest = try req.content.decode(LoginRequest.self)
        let collection = mongoDB["users"]

        guard let userDoc = try await collection.findOne("email" == loginRequest.email) else {
            let error = ErrorResponse(.userNotFound)
            return try Response(
                status: .unauthorized,
                body: .init(data: JSONEncoder().encode(error))
            )
        }

        let user = try BSONDecoder().decode(User.self, from: userDoc)

        guard user.password == loginRequest.password else {
            let error = ErrorResponse(.wrongPassword)
            return try Response(
                status: .unauthorized,
                body: .init(data: JSONEncoder().encode(error))
            )
        }

        // Generamos y devolvemos token response
        return try makeTokenResponse(for: user, req: req)
    }

    // MARK: - Helper
    private func makeTokenResponse(for user: User, req: Request) throws -> Response {
        // Expira en 1 hora
        let expiration = ExpirationClaim(value: Date().addingTimeInterval(3600))

        let payload = AuthPayload(
            uid: user._id.hexString,
            email: user.email,
            exp: expiration
        )

        let token = try req.jwt.sign(payload)

        let response = TokenResponse(
            email: user.email,
            localId: user._id.hexString,
            idToken: token,
            expiresIn: "3600"
        )

        return try Response(
            status: .ok,
            body: .init(data: JSONEncoder().encode(response))
        )
    }
}
