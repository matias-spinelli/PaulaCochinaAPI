import Vapor

func routes(_ app: Application) throws {
    let recipes = app.grouped("api", "recipes")
    let controller = RecipeController()
    recipes.get(use: controller.index)
    recipes.post(use: controller.create)
    recipes.group(":id") { r in
        r.get(use: controller.show)
        r.put(use: controller.update)
        r.delete(use: controller.delete)
    }
}
