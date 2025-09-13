//
//  RecipeController.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 11/09/2025.
//

import Vapor
import MongoKitten

struct RecipeController {
    // MARK: - Helpers
    
    private func getCollection() -> MongoCollection {
        return mongoDB["recipes"]
    }
    
    private func getObjectId(from req: Request) throws -> ObjectId {
        guard let idString = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: RecipeError.missingId.rawValue)
        }
        guard let oid = ObjectId(idString) else {
            throw Abort(.badRequest, reason: RecipeError.invalidId.rawValue)
        }
        return oid
    }
    
    private func makeErrorResponse(_ status: HTTPResponseStatus, _ error: String) -> Response {
        let payload = ErrorResponse(error)
        let data = try! JSONEncoder().encode(payload)
        return Response(status: status, body: .init(data: data))
    }
    
    // MARK: - Endpoints
    
    func index(req: Request) async throws -> Response {
        do {
            let recipes = try await getCollection()
                .find()
                .decode(Recipe.self)
                .drain()
            return try Response(status: .ok, body: .init(data: JSONEncoder().encode(recipes)))
        } catch {
            return makeErrorResponse(.internalServerError, "Error obteniendo recetas")
        }
    }

    func create(req: Request) async throws -> Response {
        do {
            var recipe = try req.content.decode(Recipe.self)
            if recipe._id == nil { recipe._id = ObjectId() }
            try await getCollection().insertEncoded(recipe)
            return try Response(status: .created, body: .init(data: JSONEncoder().encode(recipe)))
        } catch {
            return makeErrorResponse(.badRequest, RecipeError.insertFailed.rawValue)
        }
    }

    func show(req: Request) async throws -> Response {
        do {
            let oid = try getObjectId(from: req)
            guard let doc = try await getCollection().findOne("_id" == oid) else {
                return makeErrorResponse(.notFound, RecipeError.notFound.rawValue)
            }
            let recipe = try BSONDecoder().decode(Recipe.self, from: doc)
            return try Response(status: .ok, body: .init(data: JSONEncoder().encode(recipe)))
        } catch let abort as AbortError {
            return makeErrorResponse(abort.status, abort.reason)
        } catch {
            return makeErrorResponse(.internalServerError, "Error mostrando receta")
        }
    }

    func update(req: Request) async throws -> Response {
        do {
            let oid = try getObjectId(from: req)
            var updated = try req.content.decode(Recipe.self)
            updated._id = oid
            try await getCollection().updateEncoded(where: "_id" == oid, to: updated)
            return try Response(status: .ok, body: .init(data: JSONEncoder().encode(updated)))
        } catch {
            return makeErrorResponse(.badRequest, RecipeError.updateFailed.rawValue)
        }
    }

    func delete(req: Request) async throws -> Response {
        do {
            let oid = try getObjectId(from: req)
            try await getCollection().deleteOne(where: "_id" == oid)
            return Response(status: .noContent)
        } catch {
            return makeErrorResponse(.badRequest, RecipeError.deleteFailed.rawValue)
        }
    }
}
