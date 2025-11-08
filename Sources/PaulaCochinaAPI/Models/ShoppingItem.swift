//
//  ShoppingItem.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 07/11/2025.
//

import Vapor
import MongoKitten

struct ShoppingItem: Codable {
    var _id: ObjectId?
    var user_id: String
    var name: String
    var amount: Double
}
