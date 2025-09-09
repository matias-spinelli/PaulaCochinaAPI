import Vapor
import Fluent

final class Recipe: Model, Content {
    static let schema = "recipes"

    @ID(key: .id) var id: UUID?
    @Field(key: "title") var title: String
    @Field(key: "description") var description: String
    @Field(key: "isFavorite") var isFavorite: Bool

    init() {}
    init(title: String, description: String, isFavorite: Bool = false) {
        self.title = title
        self.description = description
        self.isFavorite = isFavorite
    }
}

struct CreateRecipe: Migration {
    func prepare(on db: Database) -> EventLoopFuture<Void> {
        db.schema("recipes")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("isFavorite", .bool, .required, .sql(.default(false)))
            .create()
    }

    func revert(on db: Database) -> EventLoopFuture<Void> {
        db.schema("recipes").delete()
    }
}
