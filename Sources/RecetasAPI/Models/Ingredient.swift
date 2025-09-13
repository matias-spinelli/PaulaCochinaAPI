//
//  Ingredient.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 13/09/2025.
//

import Vapor
import MongoKitten

struct Ingredient: Codable, Content {
    var _id: ObjectId?
    var amount: Double
    var name: String
}

