//
//  PantryManager.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import Foundation

class PantryManager: ObservableObject {
    @Published var pantry: [String] = []
    @Published var shoppingCart: [String] = []
    
    // addToPantry function
    func addToPantry(_ ingredient: String) {
        if (!isInPantry(ingredient)) {
            pantry.append(ingredient)
        }
    }
    
    // addToCart function
    func addToCart(_ ingredient: String) {
        if(!isInCart(ingredient)) {
            shoppingCart.append(ingredient)
        }
    }
    
    // removeFromPantry function
    func removeFromPantry(_ ingredient: String) {
        pantry.removeAll { $0 == ingredient }
    }
    
    // removeFromCart function
    func removeFromCart(_ ingredient: String) {
        shoppingCart.removeAll { $0 == ingredient }
    }
    
    // isInPantry function
    func isInPantry(_ ingredient: String) -> Bool {
        pantry.contains(ingredient)
    }
    
    // isInCart function
    func isInCart(_ ingredient: String) -> Bool {
        shoppingCart.contains(ingredient)
    }
}
