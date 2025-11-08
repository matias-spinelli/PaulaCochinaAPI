//
//  FavoritesController.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 07/11/2025.
//

import Vapor
import MongoKitten

struct FavoritesController {
    private func getCollection() -> MongoCollection {
        return mongoDB["favorites"]
    }

    // GET /api/users/:uid/favorites
    func index(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return Response(status: .badRequest, body: .init(string: "Falta el UID"))
        }

        let docs = try await getCollection().find("user_id" == uid).drain()
        let favorites = try docs.map { try BSONDecoder().decode(Favorite.self, from: $0) }
        return try Response(status: .ok, body: .init(data: JSONEncoder().encode(favorites)))
    }

    // POST /api/users/:uid/favorites  (toggle favorite/unfavorite)
    func toggle(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return Response(status: .badRequest, body: .init(string: "Falta el UID"))
        }

        var favorite = try req.content.decode(Favorite.self)
        favorite.user_id = uid

        // Buscar si ya existe
        if let existing = try await getCollection().findOne("user_id" == uid && "recipe_id" == favorite.recipe_id) {
            // Si ya existe, eliminar (unfavorite)
            try await getCollection().deleteOne(where: "_id" == existing["_id"])
            return Response(status: .ok, body: .init(string: "Receta eliminada de favoritos"))
        } else {
            // Si no existe, agregar
            try await getCollection().insertEncoded(favorite)
            return try Response(status: .created, body: .init(data: JSONEncoder().encode(favorite)))
        }
    }

    // DELETE /api/users/:uid/favorites/:recipeId (por si querés mantener endpoint explícito)
    func delete(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid"),
              let recipeId = req.parameters.get("recipeId") else {
            return Response(status: .badRequest, body: .init(string: "Falta UID o recipeId"))
        }

        try await getCollection().deleteOne(where: "user_id" == uid && "recipe_id" == recipeId)
        return Response(status: .noContent)
    }
}
