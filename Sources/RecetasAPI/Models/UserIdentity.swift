//
//  UserIdentity.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 11/09/2025.
//

import Vapor

struct UserIdentity: Authenticatable {
    let uid: String
    let email: String
}
