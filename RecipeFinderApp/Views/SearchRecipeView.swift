//
//  SearchRecipeView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import SwiftUI

struct SearchRecipeView: View {
    @StateObject private var api = RecipeAPI()
    
    @State private var query: String = ""
    @State private var isLoading: Bool = false
    @State private var showActionSheet: Bool = false
    
    @AppStorage("dietPreference") private var dietPreference: String = "None"
    @AppStorage("sortBy") private var sortBy: String = "Relevance"
    @AppStorage("maxCookingTime") private var maxCookingTime: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        // Search Field
                        TextField("Search for recipes...", text: $query, onCommit: {
                            fetchRecipes()
                        })
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        
                        Button(action: {
                            fetchRecipes()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    //action sheet
                    Button(action: {
                        showActionSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Filter & Sort Options")
                                .font(.body)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // loading, empty, or results
                    if isLoading {
                        Spacer()
                        ProgressView("Loading recipes...")
                            .padding()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if api.recipes.isEmpty {
                        Spacer()
                        Text("Hmmm...Try searching for something new!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        List(api.recipes, id: \.id) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeCard(recipe: recipe)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                        .transition(.opacity)
                    }
                }
                .navigationTitle("Recipe Finder")
            }
            .confirmationDialog("Filter & Sort Recipes", isPresented: $showActionSheet, titleVisibility: .visible) {
                // sorting
                Button("Sort by Relevance") { sortBy = "Relevance" }
                Button("Sort by Popularity") { sortBy = "Popularity" }
                Button("Sort by Healthiness") { sortBy = "Healthiness" }
                
                // diet preferences
                Button("Set Diet: Vegetarian") { dietPreference = "Vegetarian" }
                Button("Set Diet: Vegan") { dietPreference = "Vegan" }
                Button("Set Diet: None") { dietPreference = "None" }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    func fetchRecipes() {
        withAnimation {
            isLoading = true
        }
        
        api.fetchRecipes(query: query, dietPreference: dietPreference)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isLoading = false
            }
        }
    }
}

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
    SearchRecipeView()
}
