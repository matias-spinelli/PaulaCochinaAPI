//
//  routes.swift
//  PaulaCochinaAPI
//
//  Created by Matías Spinelli on 07/11/2025.
//

import Vapor

func routes(_ app: Application) throws {
    // 🔹 Auth (público)
    let auth = app.grouped("api", "auth")
    let userController = UserController()
    auth.post("signup", use: userController.signup)
    auth.post("login", use: userController.login)

    // 🔹 Recipes (requieren token)
    let recipes = app.grouped("api", "recipes").grouped(AuthMiddleware())
    let controller = RecipeController()

    recipes.get(use: controller.index)       // GET /api/recipes
    recipes.post(use: controller.create)     // POST /api/recipes
    recipes.group(":id") { r in
        r.get(use: controller.show)          // GET /api/recipes/:id
        r.put(use: controller.update)        // PUT /api/recipes/:id
        r.delete(use: controller.delete)     // DELETE /api/recipes/:id
    }

    // 🔹 Users scoped routes (requieren token)
    let users = app.grouped("api", "users").grouped(AuthMiddleware())
    let favoritesController = FavoritesController()
    let shoppingController = ShoppingListController()

    // Favoritos
    users.group(":uid", "favorites") { group in
        group.get(use: favoritesController.index)
        group.post(use: favoritesController.toggle)
        group.delete(":recipeId", use: favoritesController.delete)
    }

    // Lista de compras
    users.group(":uid", "shopping-list") { group in
        group.get(use: shoppingController.index)
        group.post(use: shoppingController.create)
        group.delete(use: shoppingController.clear)      // borra todos
        group.delete(":name", use: shoppingController.delete) // borra uno
    }
}
