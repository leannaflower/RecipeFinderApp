//
//  ApiManager.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import Foundation
import SwiftUI

// Nutrition data model
struct Nutrition: Codable {
    let nutrients: [Nutrient]   // list of Nutrient objects
}

struct Nutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
}

// Ingredient data model
struct Ingredient: Codable, Identifiable {
    let id: UUID
    let name: String
    let amount: Double
    let unit: String
    
    init(name: String, amount: Double, unit: String) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.unit = unit
    }
    
    init(from decoder: any Decoder) throws {    // The API returns ingredient amounts in a nested JSON structure, not a flat one
        /* example:
        Instead of "amount": 200, it comes back looking like:
             "amount": {
               "metric": {
                 "value": 200,
                 "unit": "grams"
               }
             }
         */
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)

        let amountContainer = try container.nestedContainer(keyedBy: AmountKeys.self, forKey: .amount)
        let metricContainer = try amountContainer.nestedContainer(keyedBy: MetricKeys.self, forKey: .metric)
        amount = try metricContainer.decode(Double.self, forKey: .value)
        unit = try metricContainer.decode(String.self, forKey: .unit)
        self.id = UUID()
    }
    
    private enum AmountKeys: String, CodingKey {
        case metric
    }
    
    private enum MetricKeys: String, CodingKey {
        case value
        case unit
    }
    
    private enum CodingKeys: String, CodingKey {    // map the Swift property names to the JSON key names
        case name
        case amount
    }
}

struct Recipe: Codable {
    let id: Int
    let title: String
    let image: String
    let nutrition: Nutrition?
    let ingredients: [Ingredient]?
}

// Wrapper structs to match the API's top-level JSON structure.
// The API wraps its arrays in an object, so we decode into these first,
// then pull out the array we actually need.

// Wraps the recipe endpoint response — extracts the "recipe" array
struct RecipeResponse: Codable {
    let results: [Recipe]
}

// Wraps the ingredient endpoint response — extracts the "ingredients" array
struct IngredientResponse: Codable {
    let ingredients: [Ingredient]
}

//
class RecipeAPI: ObservableObject {
    @Published var recipes: [Recipe] = []
    @AppStorage("maxCookingTime") private var maxCookingTime: Int = 30
    @AppStorage("sortBy") private var sortBy: String = "Relevance"
    
    // Build URL → Fire async request → Decode JSON response → Jump to main thread → Update the published variable → UI re-renders automatically
    func fetchRecipes(query: String, dietPreference: String) {
        let apiKey = "5ca5612f076f4760956a7e9eb02754d3"
        let dietFilter = dietPreference != "None" ? "&diet=\(dietPreference)" : ""
        let timeFilter = maxCookingTime > 0 ? "&maxReadyTime=\(maxCookingTime)" : ""
        let sortFilter = "&sort=\(sortBy.lowercased())"
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?query=\(query)\(dietFilter)\(timeFilter)\(sortFilter)&apiKey=\(apiKey)&addRecipeNutrition=true"
        
        guard let url = URL(string: urlString) else {   // tries to create valid URL from the string; if fails, it exits the function early
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {    // unwraps the optional
                do {
                    let decodedResponse = try JSONDecoder().decode(RecipeResponse.self, from: data) // unwraps the raw bytes into the RecipeResponse struct
                    DispatchQueue.main.async {  // schedule a block of code to run on the main thread asynchronously; update UI elements after completing a background task
                        self.recipes = decodedResponse.results
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}
