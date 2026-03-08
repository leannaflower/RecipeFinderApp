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
        /*
         TabView { // the tabs
         |  search view
         |  shopping cart view
         |  settings view
         }
         */
        TabView {
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
            
            AppInfoView()
                .tabItem {
                    Label("App Info", systemImage: "info.circle")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
