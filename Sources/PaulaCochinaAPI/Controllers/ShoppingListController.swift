//
//  ShoppingListController.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 07/11/2025.
//

import Vapor
import MongoKitten

struct ShoppingListController {
    private func getCollection() -> MongoCollection {
        return mongoDB["shopping_list"]
    }

    // GET /api/users/:uid/shopping-list
    func index(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return Response(status: .badRequest, body: .init(string: "Falta el UID"))
        }

        let docs = try await getCollection().find("user_id" == uid).drain()
        let items = try docs.map { try BSONDecoder().decode(ShoppingItem.self, from: $0) }
        return try Response(status: .ok, body: .init(data: JSONEncoder().encode(items)))
    }

    // POST /api/users/:uid/shopping-list
    func create(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return Response(status: .badRequest, body: .init(string: "Falta el UID"))
        }

        let newItem = try req.content.decode(ShoppingItem.self)
        var item = newItem
        item.user_id = uid

        // Buscar si ya existe ese ingrediente
        if let existingDoc = try await getCollection().findOne("user_id" == uid && "name" == item.name) {
            var existing = try BSONDecoder().decode(ShoppingItem.self, from: existingDoc)
            existing.amount += item.amount
            try await getCollection().updateOne(
                where: "_id" == existing._id!,
                to: ["$set": ["amount": existing.amount]]
            )
            return try Response(status: .ok, body: .init(data: JSONEncoder().encode(existing)))
        } else {
            try await getCollection().insertEncoded(item)
            return try Response(status: .created, body: .init(data: JSONEncoder().encode(item)))
        }
    }

    // DELETE /api/users/:uid/shopping-list/:name
    func delete(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid"),
              let name = req.parameters.get("name") else {
            return Response(status: .badRequest, body: .init(string: "Falta UID o nombre"))
        }

        try await getCollection().deleteOne(where: "user_id" == uid && "name" == name)
        return Response(status: .noContent)
    }

    // DELETE /api/users/:uid/shopping-list
    func clear(req: Request) async throws -> Response {
        guard let uid = req.parameters.get("uid") else {
            return Response(status: .badRequest, body: .init(string: "Falta el UID"))
        }

        try await getCollection().deleteAll(where: "user_id" == uid)
        return Response(status: .noContent)
    }
}
