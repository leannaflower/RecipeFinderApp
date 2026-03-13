//
//  SearchRecipeView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import SwiftUI

struct SearchRecipeView: View {
    @StateObject private var recipeManager = RecipeAPI()
    @EnvironmentObject var savedRecipesManager: SavedRecipesManager
    
    @State private var query: String = ""
    @State private var isLoading: Bool = false
    @State private var showActionSheet: Bool = false
    @State private var selectedTab: Int = 0  // 0 = Search, 1 = Saved
    
    @AppStorage("dietPreference") private var dietPreference: String = "None"
    @AppStorage("sortBy") private var sortBy: String = ""

    var currentFiltersText: String {
        var filters: [String] = []
        
        if dietPreference != "None" {
            filters.append("Diet: \(dietPreference)")
        }
        
        if !sortBy.isEmpty {
            filters.append("Sort: \(sortBy)")
        }
        
        return filters.isEmpty ? "No Filters" : filters.joined(separator: " • ")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Search").tag(0)
                        Text("Saved").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if selectedTab == 0 {
                        HStack(spacing: 10) {
                            // Search Field
                            TextField("Search for recipes...", text: $query, onCommit: {
                                Task {
                                    await fetchRecipes()
                                }
                            })
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            
                            Button(action: {
                                Task {
                                    await fetchRecipes()
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.accentColor) 
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        HStack {
                            // display filters
                            VStack {
                                Text("Current Filters:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(currentFiltersText)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            //action sheet
                            Button(action: {
                                showActionSheet.toggle()
                            }) {
                                
                                Image(systemName: "slider.horizontal.3")
                                    .padding()
                                    .frame(width: 44, height: 44)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }

                        // loading, empty, or results
                        if isLoading {
                            Spacer()
                            ProgressView("Loading recipes...")
                                .padding()
                                .scaleEffect(1.5)
                            Spacer()
                        } else if recipeManager.recipes.isEmpty {
                            Spacer()
                            Text("Hmmm...Try searching for something new!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        } else {
                            List(recipeManager.recipes, id: \.id) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCard(recipe: recipe)
                                }
                                .listRowBackground(Color.clear)
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                            .transition(.opacity)
                        }
                    } else {
                        // saved recipes list
                        if savedRecipesManager.savedRecipes.isEmpty {
                            Spacer()
                            Text("No saved recipes yet!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
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
                }
                .navigationTitle("Recipe Finder")
            }
            .confirmationDialog("Filter & Sort Recipes", isPresented: $showActionSheet, titleVisibility: .visible) {
                // sorting
                Button("Sort by Popularity") {
                    sortBy = "popularity"
                    Task {
                        await fetchRecipes()
                    }
                }
                Button("Sort by Healthiness") {
                    sortBy = "healthiness"
                    Task {
                        await fetchRecipes()
                    }
                }
                Button("No Sort") {
                    sortBy = ""
                    Task {
                        await fetchRecipes()
                    }
                }
                
                // diet preferences
                Button("Set Diet: Vegetarian") {
                    dietPreference = "vegetarian"
                    Task {
                        await fetchRecipes()
                    }
                }
                Button("Set Diet: Vegan") {
                    dietPreference = "vegan"
                    Task {
                        await fetchRecipes()
                    }
                }
                Button("Set Diet: None") {
                    dietPreference = "None"
                    Task {
                        await fetchRecipes()
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    func fetchRecipes() async {
        withAnimation {
            isLoading = true
        }
        
        defer {
            withAnimation {
                isLoading = false
            }
        }
        
        do {
            recipeManager.recipes = try await recipeManager.fetchRecipes(query: query, dietPreference: dietPreference, sortBy: sortBy)
        } catch {
            print("Failed to fetch recipes: \(error)")
            recipeManager.recipes = []
        }
    }
}

#Preview {
    SearchRecipeView()
        .environmentObject(SavedRecipesManager())
}
