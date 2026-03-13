//
//  SavedRecipesView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 3/8/26.
//

import SwiftUI

struct SavedRecipesView: View {
    @EnvironmentObject var savedRecipesManager: SavedRecipesManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                if savedRecipesManager.savedRecipes.isEmpty {
                    Text("No saved recipes yet!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    List(savedRecipesManager.savedRecipes, id: \.id) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCard(recipe: recipe)
                        }
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                savedRecipesManager.removeRecipe(recipe)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Saved Recipes")
        }
    }
}

#Preview {
    let manager = SavedRecipesManager()
    manager.saveRecipe(Recipe(
        id: 1,
        title: "Spaghetti Carbonara",
        image: "https://via.placeholder.com/150",
        nutrition: nil,
        ingredients: nil
    ))
    manager.saveRecipe(Recipe(
        id: 2,
        title: "Chicken Tikka Masala",
        image: "https://via.placeholder.com/150",
        nutrition: nil,
        ingredients: nil
    ))
    return SavedRecipesView()
        .environmentObject(manager)
}
