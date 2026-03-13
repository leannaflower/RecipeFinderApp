//
//  RecipeCard.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 3/12/26.
//

import SwiftUI

// Recipe Card View
// pure presentational subview for a recipe
struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: recipe.image))
                .frame(width: 60, height: 60)
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("Tap to see details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 2)
        )
        .padding(.vertical, 5)
    }
}

#Preview {
    RecipeCard(
        recipe: Recipe(
            id: 1,
            title: "Creamy Tomato Pasta",
            image: "https://spoonacular.com/recipeImages/716429-312x231.jpg",
            nutrition: nil,
            ingredients: nil
        )
    )
}
