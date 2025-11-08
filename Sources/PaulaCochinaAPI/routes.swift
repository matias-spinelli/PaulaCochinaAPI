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

    // Favoritos
    let favoritesController = FavoritesController()
    users.group(":uid", "favorites") { group in
        group.get(use: favoritesController.index)     // GET /api/users/:uid/favorites
        group.post(use: favoritesController.toggle)   // POST /api/users/:uid/favorites  (body: { recipe_id })
        group.delete(":recipeId", use: favoritesController.delete) // DELETE /api/users/:uid/favorites/:recipeId
    }

    // Lista de compras
    let shoppingListController = ShoppingListController()
    users.group(":uid") { user in
        user.group("shopping-list") { list in
            list.get(use: shoppingListController.index)
            list.post(use: shoppingListController.create)
            list.put(":ingredientId", use: shoppingListController.update)
            list.delete(":ingredientId", use: shoppingListController.delete)
            list.delete(use: shoppingListController.clear)
        }
    }

}
