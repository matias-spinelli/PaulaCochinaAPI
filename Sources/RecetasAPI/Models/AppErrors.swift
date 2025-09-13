//
//  AppErrors.swift
//  RecetasAPI
//
//  Created by Matías Spinelli on 12/09/2025.
//

import Vapor

enum UserError: String, Error, Codable {
    case userExists = "Ese usuario ya existe"
    case wrongPassword = "Contraseña incorrecta"
    case passwordTooShort = "El password debe tener mínimo 6 caracteres"
    case userNotFound = "Usuario no encontrado"
}

enum RecipeError: String, Error, Codable {
    case notFound = "Receta no encontrada"
    case invalidId = "El id proporcionado no es válido"
    case missingId = "Falta el parámetro id"
    case insertFailed = "No se pudo crear la receta"
    case updateFailed = "No se pudo actualizar la receta"
    case deleteFailed = "No se pudo eliminar la receta"
}

struct ErrorResponse: Content {
    let error: String
    
    init(_ error: String) {
        self.error = error
    }
    
    init(_ error: UserError) {
        self.error = error.rawValue
    }
    
    init(_ error: RecipeError) {
        self.error = error.rawValue
    }
}
