//
//  Recipe.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 29/08/2025.
//

import Vapor
import MongoKitten

struct Recipe: Codable, Content {
    var _id: ObjectId?
    var name: String
    var description: String
    var ingredients: [Ingredient]
    var imagePath: String
    var __v: Int?
}
