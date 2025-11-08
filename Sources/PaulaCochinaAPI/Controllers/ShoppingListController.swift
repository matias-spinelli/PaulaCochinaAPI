//
//  ShoppingListController.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 07/11/2025.
//

import Vapor
import MongoKitten

// MARK: - Helper para permitir distintos tipos en JSON
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}

// MARK: - Controller
struct ShoppingListController {
    private func getCollection() -> MongoCollection {
        return mongoDB["shopping_list"]
    }

    private func getRecipesCollection() -> MongoCollection {
        return mongoDB["recipes"]
    }

    // MARK: - Helpers

    private func makeJSONResponse(_ status: HTTPResponseStatus, _ data: Encodable) throws -> Response {
        let encoded = try JSONEncoder().encode(data)
        return Response(status: status, body: .init(data: encoded))
    }

    private func makeMessage(_ message: String) -> [String: String] {
        return ["message": message]
    }

    // MARK: - GET /api/users/:uid/shopping-list
    func index(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return try makeJSONResponse(.badRequest, makeMessage("Falta el UID"))
        }

        let docs = try await getCollection().find("user_id" == uid).drain()
        let items = try docs.map { try BSONDecoder().decode(ShoppingItem.self, from: $0) }
        return try makeJSONResponse(.ok, items)
    }

    // MARK: - POST /api/users/:uid/shopping-list
    func create(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return try makeJSONResponse(.badRequest, makeMessage("Falta el UID"))
        }

        let body = try req.content.decode(ShoppingItemRequest.self)

        // 🔹 Caso 1: vino recipe_id → agregar todos los ingredientes de la receta
        if let recipeId = body.recipe_id, let oid = ObjectId(recipeId) {
            guard let recipeDoc = try await getRecipesCollection().findOne("_id" == oid) else {
                return try makeJSONResponse(.notFound, makeMessage("Receta no encontrada"))
            }

            let recipe = try BSONDecoder().decode(Recipe.self, from: recipeDoc)

            var addedCount = 0
            for ingredient in recipe.ingredients {
                if let existingDoc = try await getCollection().findOne("user_id" == uid && "name" == ingredient.name) {
                    var existing = try BSONDecoder().decode(ShoppingItem.self, from: existingDoc)
                    existing.amount += ingredient.amount
                    if let existingOid = existing._id {
                        try await getCollection().updateOne(
                            where: "_id" == existingOid,
                            to: ["$set": ["amount": existing.amount]]
                        )
                    } else {
                        try await getCollection().updateOne(
                            where: "user_id" == uid && "name" == ingredient.name,
                            to: ["$set": ["amount": existing.amount]]
                        )
                    }
                } else {
                    let newItem = ShoppingItem(
                        _id: ObjectId(),
                        user_id: uid,
                        name: ingredient.name,
                        amount: ingredient.amount
                    )
                    try await getCollection().insertEncoded(newItem)
                    addedCount += 1
                }
            }

            return try makeJSONResponse(.created, [
                "message": AnyEncodable("Ingredientes agregados/mergeados desde la receta"),
                "addedNewItems": AnyEncodable(addedCount),
                "totalIngredientsInRecipe": AnyEncodable(recipe.ingredients.count)
            ])
        }

        // 🔹 Caso 2: agregar manualmente un ingrediente
        guard let name = body.name, let amount = body.amount else {
            return try makeJSONResponse(.badRequest, makeMessage("Faltan 'name' o 'amount'"))
        }

        if let existingDoc = try await getCollection().findOne("user_id" == uid && "name" == name) {
            var existing = try BSONDecoder().decode(ShoppingItem.self, from: existingDoc)
            existing.amount += amount
            if let oid = existing._id {
                try await getCollection().updateOne(
                    where: "_id" == oid,
                    to: ["$set": ["amount": existing.amount]]
                )
            } else {
                try await getCollection().updateOne(
                    where: "user_id" == uid && "name" == name,
                    to: ["$set": ["amount": existing.amount]]
                )
            }
            return try makeJSONResponse(.ok, [
                "message": AnyEncodable("Ingrediente existente actualizado (merge)"),
                "name": AnyEncodable(existing.name),
                "newAmount": AnyEncodable(existing.amount)
            ])
        } else {
            let item = ShoppingItem(
                _id: ObjectId(),
                user_id: uid,
                name: name,
                amount: amount
            )
            try await getCollection().insertEncoded(item)
            return try makeJSONResponse(.created, [
                "message": AnyEncodable("Ingrediente agregado manualmente"),
                "item": AnyEncodable(item.name)
            ])
        }
    }

    // MARK: - PUT /api/users/:uid/shopping-list/:name
    func update(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid"),
              let name = req.parameters.get("name") else {
            return try makeJSONResponse(.badRequest, makeMessage("Falta UID o nombre"))
        }

        struct UpdateRequest: Content { let amount: Double }
        let body = try req.content.decode(UpdateRequest.self)

        guard let existingDoc = try await getCollection().findOne("user_id" == uid && "name" == name) else {
            return try makeJSONResponse(.notFound, makeMessage("Ingrediente no encontrado"))
        }

        let existing = try BSONDecoder().decode(ShoppingItem.self, from: existingDoc)
        if let oid = existing._id {
            try await getCollection().updateOne(
                where: "_id" == oid,
                to: ["$set": ["amount": body.amount]]
            )
        } else {
            try await getCollection().updateOne(
                where: "user_id" == uid && "name" == name,
                to: ["$set": ["amount": body.amount]]
            )
        }

        return try makeJSONResponse(.ok, makeMessage("Cantidad actualizada"))
    }

    // MARK: - DELETE /api/users/:uid/shopping-list/:name
    func delete(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid"),
              let name = req.parameters.get("name") else {
            return try makeJSONResponse(.badRequest, makeMessage("Falta UID o nombre"))
        }

        guard let existingDoc = try await getCollection().findOne("user_id" == uid && "name" == name) else {
            return try makeJSONResponse(.notFound, makeMessage("Ingrediente no encontrado"))
        }

        let existing = try BSONDecoder().decode(ShoppingItem.self, from: existingDoc)
        if let oid = existing._id {
            _ = try await getCollection().deleteOne(where: "_id" == oid)
        } else {
            _ = try await getCollection().deleteOne(where: "user_id" == uid && "name" == name)
        }

        return try makeJSONResponse(.ok, makeMessage("Ingrediente eliminado"))
    }

    // MARK: - DELETE /api/users/:uid/shopping-list
    func clear(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return try makeJSONResponse(.badRequest, makeMessage("Falta el UID"))
        }

        try await getCollection().deleteAll(where: "user_id" == uid)
        return try makeJSONResponse(.ok, makeMessage("Lista de compras vaciada"))
    }
}
