//
//  File.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 07/11/2025.
//

import Vapor
import MongoKitten

struct Favorite: Codable, Content {
    var _id: ObjectId?
    var user_id: String
    var recipe_id: String
}

struct FavoriteRequest: Content {
    let recipe_id: String
}
