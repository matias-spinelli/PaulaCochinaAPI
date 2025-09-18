import Vapor

func routes(_ app: Application) throws {
    // Auth (público)
    let auth = app.grouped("api", "auth")
    let userController = UserController()
    auth.post("signup", use: userController.signup)
    auth.post("login", use: userController.login)

    // Recipes (requieren token)
    let recipes = app.grouped("api", "recipes").grouped(AuthMiddleware())
    let controller = RecipeController()

    recipes.get(use: controller.index)      // GET /api/recipes
    recipes.post(use: controller.create)    // POST /api/recipes
    recipes.group(":id") { r in
        r.get(use: controller.show)         // GET /api/recipes/:id
        r.put(use: controller.update)       // PUT /api/recipes/:id
        r.delete(use: controller.delete)    // DELETE /api/recipes/:id
    }
}
