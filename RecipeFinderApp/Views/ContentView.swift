//
//  ContentView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pantryManager = PantryManager()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            SearchRecipeView()
                .environmentObject(pantryManager)
                .tabItem {
                    Label("Recipes", systemImage: "magnifyingglass")
                }
            

            
            ShoppingCartView()
                .environmentObject(pantryManager)
                .tabItem {
                    Label("Cart & Pantry", systemImage: "cart")
                }
            
            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }
            
//            AppInfoView()
//                .tabItem {
//                    Label("App Info", systemImage: "info.circle")
//                }
//            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SavedRecipesManager())
        .environmentObject(PantryManager())
}
