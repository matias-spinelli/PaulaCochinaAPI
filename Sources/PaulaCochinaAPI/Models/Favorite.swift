//
//  File.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 07/11/2025.
//

import Vapor
import MongoKitten

struct Favorite: Codable {
    var _id: ObjectId?
    var user_id: String
    var recipe_id: String
    var recipe_name: String
    var imagePath: String
}
