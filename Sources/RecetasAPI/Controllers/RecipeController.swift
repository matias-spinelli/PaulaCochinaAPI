import Vapor
import Fluent

struct RecipeController {
    func index(req: Request) throws -> EventLoopFuture<[Recipe]> {
        Recipe.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Recipe> {
        let recipe = try req.content.decode(Recipe.self)
        return recipe.save(on: req.db).map { recipe }
    }

    func show(req: Request) throws -> EventLoopFuture<Recipe> {
        Recipe.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<Recipe> {
        let input = try req.content.decode(Recipe.self)
        return Recipe.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { recipe in
                recipe.title = input.title
                recipe.description = input.description
                recipe.isFavorite = input.isFavorite
                return recipe.save(on: req.db).map { recipe }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Recipe.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .noContent)
    }
}
