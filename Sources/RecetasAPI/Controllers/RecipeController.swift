import Vapor
import MongoKitten

struct RecipeController {
    /// GET /api/recipes
    func index(req: Request) async throws -> [Recipe] {
        let collection = mongoDB["recipes"]
        return try await collection.find().decode(Recipe.self).drain()
    }

    /// POST /api/recipes
    func create(req: Request) async throws -> Recipe {
        var recipe = try req.content.decode(Recipe.self)

        // Si no tiene _id, generamos uno aquí para poder devolver el objeto completo
        if recipe._id == nil {
            recipe._id = ObjectId()
        }

        let collection = mongoDB["recipes"]
        try await collection.insertEncoded(recipe) // usa Codable directamente
        return recipe
    }

    /// GET /api/recipes/:id
    func show(req: Request) async throws -> Recipe {
        guard let idString = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing id")
        }
        guard let oid = ObjectId(idString) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }

        let collection = mongoDB["recipes"]
        guard let doc = try await collection.findOne("_id" == oid) else {
            throw Abort(.notFound)
        }
        return try BSONDecoder().decode(Recipe.self, from: doc)
    }

    /// PUT /api/recipes/:id
    func update(req: Request) async throws -> Recipe {
        guard let idString = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing id")
        }
        guard let oid = ObjectId(idString) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }

        var updated = try req.content.decode(Recipe.self)
        updated._id = oid // garantizamos que el _id sea el del path

        let collection = mongoDB["recipes"]
        // updateEncoded hace el encode por vos y reemplaza el documento
        try await collection.updateEncoded(where: "_id" == oid, to: updated)

        return updated
    }

    /// DELETE /api/recipes/:id
    func delete(req: Request) async throws -> HTTPStatus {
        guard let idString = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "Missing id")
        }
        guard let oid = ObjectId(idString) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }

        let collection = mongoDB["recipes"]
        try await collection.deleteOne(where: "_id" == oid)
        return .noContent
    }
}
