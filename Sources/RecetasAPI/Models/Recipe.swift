import Vapor
import MongoKitten

struct Ingredient: Codable, Content {
    var _id: ObjectId?
    var amount: String
    var name: String
}

struct Recipe: Codable, Content {
    var _id: ObjectId?
    var name: String
    var description: String
    var ingredients: [Ingredient]
    var imagePath: String
    var userEmail: String
    var __v: Int?
}
