//
//  HomeView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 3/12/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var recipeManager = RecipeAPI()
    @EnvironmentObject var savedRecipesManager: SavedRecipesManager
    
    let quickActions: [QuickAction] = [
        QuickAction(title: "Vegan", icon: "leaf", query: "", dietPreference: "Vegan", sortBy: ""),
        QuickAction(title: "Vegetarian", icon: "carrot", query: "", dietPreference: "Vegetarian", sortBy: ""),
        QuickAction(title: "Quick Meals", icon: "clock", query: "quick", dietPreference: "None", sortBy: "time"),
        QuickAction(title: "Dessert", icon: "birthday.cake", query: "dessert", dietPreference: "None", sortBy: "popularity")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // random recipe
                    HStack {
                        Text("Random Recipe")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Button {
                            Task {
                                await loadRandomRecipes()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(recipeManager.randomRecipes, id: \.id) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCard(recipe: recipe)
                                .frame(width: 300)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                    
                    // popular recipes
                    Text("Popular Recipes")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(recipeManager.popularRecipes, id: \.id) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCard(recipe: recipe)
                                        .frame(width: 300)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // quick actions
                    Text("Quick Actions")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(quickActions) { action in
                                Button {
                                    
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: action.icon)
                                            .font(.title2)
                                        Text(action.title)
                                            .font(.subheadline)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: 100, height: 90)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .task {
                await loadHomeData()
            }
        }
    }
    
    func loadRandomRecipes() async {
        do {
            recipeManager.randomRecipes = try await recipeManager.fetchRandomRecipes()
        } catch {
            print("Failed to load random recipes: \(error)")
        }
    }
    
    func loadPopularRecipes() async {
        do {
            recipeManager.popularRecipes = try await recipeManager.fetchPopularRecipes()
        } catch {
            print("Failed to load popular recipes: \(error)")
        }
    }
    
    func loadHomeData() async {
        await loadRandomRecipes()
        await loadPopularRecipes()
    }
}

// struct for the quick actions
struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let query: String
    let dietPreference: String
    let sortBy: String
}

#Preview {
    HomeView()
        .environmentObject(SavedRecipesManager())
}
