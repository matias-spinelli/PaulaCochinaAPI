//
//  User.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 11/09/2025.
//

import Vapor
import MongoKitten

struct User: Codable, Content {
    var _id: ObjectId
    var email: String
    var password: String
}


struct SignupRequest: Content {
    let email: String
    let password: String
}

struct LoginRequest: Content {
    let email: String
    let password: String
}

struct TokenResponse: Content {
    let email: String
    let localId: String
    let idToken: String
    let expiresIn: String
}
