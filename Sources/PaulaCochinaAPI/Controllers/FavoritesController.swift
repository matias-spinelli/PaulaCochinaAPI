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
    // Devuelve las recetas completas favoritas del usuario
    func index(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return Response(status: .badRequest, body: .init(string: "Falta el UID"))
        }

        // Buscar favoritos por user_id
        let docs = try await getCollection().find("user_id" == uid).drain()
        let favorites = try docs.map { try BSONDecoder().decode(Favorite.self, from: $0) }

        // Obtener los recipe_ids
        let recipeIds = favorites.compactMap { ObjectId($0.recipe_id) }

        // Si no hay favoritos devolver array vacío
        if recipeIds.isEmpty {
            return try Response(status: .ok, body: .init(data: JSONEncoder().encode([Recipe]())))
        }

        // Buscar las recetas asociadas
        let recipesCollection = mongoDB["recipes"]
        let query: Document = ["_id": ["$in": recipeIds]]
        let recipeDocs = try await recipesCollection.find(query).drain()
        let recipes = try recipeDocs.map { try BSONDecoder().decode(Recipe.self, from: $0) }

        return try Response(status: .ok, body: .init(data: JSONEncoder().encode(recipes)))
    }

    // POST /api/users/:uid/favorites  (toggle favorite/unfavorite)
    // Body: { "recipe_id": "68c5efff6f91a8bb417419bd" }
    func toggle(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return Response(status: .badRequest, body: .init(string: "Falta el UID"))
        }

        // Decodificamos sólo el DTO (solo recipe_id viene del cliente)
        let body = try req.content.decode(FavoriteRequest.self)
        let recipeId = body.recipe_id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !recipeId.isEmpty else {
            return Response(status: .badRequest, body: .init(string: "recipe_id vacío"))
        }

        // Comprobamos si la receta existe (opcional pero útil)
        if ObjectId(recipeId) == nil {
            return Response(status: .badRequest, body: .init(string: "recipe_id inválido"))
        }

        // Buscar si ya existe
        if let existingDoc = try await getCollection().findOne("user_id" == uid && "recipe_id" == recipeId) {
            // Si ya existe, eliminar (unfavorite)
            try await getCollection().deleteOne(where: "_id" == existingDoc["_id"])
            return Response(status: .ok, body: .init(string: "Receta eliminada de favoritos"))
        } else {
            // Si no existe, agregar
            let favorite = Favorite(_id: ObjectId(), user_id: uid, recipe_id: recipeId)
            try await getCollection().insertEncoded(favorite)
            return try Response(status: .created, body: .init(data: JSONEncoder().encode(favorite)))
        }
    }

    // DELETE /api/users/:uid/favorites/:recipeId (endpoint explícito si lo querés)
    func delete(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid"),
              let recipeId = req.parameters.get("recipeId") else {
            return Response(status: .badRequest, body: .init(string: "Falta UID o recipeId"))
        }

        try await getCollection().deleteOne(where: "user_id" == uid && "recipe_id" == recipeId)
        return Response(status: .noContent)
    }
}
