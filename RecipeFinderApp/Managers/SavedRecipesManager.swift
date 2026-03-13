//
//  SavedRecipesManager.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 3/8/26.
//

import Foundation

class SavedRecipesManager: ObservableObject {
    @Published var savedRecipes: [Recipe] = []
    
    func saveRecipe(_ recipe: Recipe) {
        if !savedRecipes.contains(where: { $0.id == recipe.id }) {
            savedRecipes.append(recipe)
        }
    }
    
    func removeRecipe(_ recipe: Recipe) {
        savedRecipes.removeAll { $0.id == recipe.id }
    }
    
    func isSaved(_ recipe: Recipe) -> Bool {
        savedRecipes.contains(where: { $0.id == recipe.id })
    }
}
