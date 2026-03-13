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

struct RandomRecipeResponse: Codable {
    let recipes: [Recipe]
}

// Wraps the ingredient endpoint response — extracts the "ingredients" array
struct IngredientResponse: Codable {
    let ingredients: [Ingredient]
}

//
class RecipeAPI: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var randomRecipes: [Recipe] = []
    @Published var popularRecipes: [Recipe] = []
    
    @MainActor
    func fetchRecipes(query: String, dietPreference: String, sortBy: String) async throws -> [Recipe] {
        let apiKey = Secrets.apiKey
        let numberOfResults = 30
        let sortFilter = sortBy.lowercased()
        let dietFilter = dietPreference != "None" ? "&diet=\(dietPreference)" : ""
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?query=\(query)&number=\(numberOfResults)\(dietFilter)&sort=\(sortFilter)&apiKey=\(apiKey)&addRecipeNutrition=true"
        guard let url = URL(string: urlString) else {
            throw RCErrors.InvalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RCErrors.InvalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
            return decodedResponse.results
        } catch {
            throw RCErrors.InvalidData
        }
    }

    func fetchRandomRecipes() async throws -> [Recipe] {
        let apiKey = Secrets.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString = "https://api.spoonacular.com/recipes/random?number=1&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw RCErrors.InvalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RCErrors.InvalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Status code:", httpResponse.statusCode)
            print("Response body:", String(data: data, encoding: .utf8) ?? "No body")
            throw RCErrors.InvalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(RandomRecipeResponse.self, from: data)
            return decodedResponse.recipes
        } catch {
            print("Decoding error:", error)
            print("Raw JSON:", String(data: data, encoding: .utf8) ?? "No body")
            throw RCErrors.InvalidData
        }
    }
    
    func fetchPopularRecipes() async throws -> [Recipe] {
        let apiKey = Secrets.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?query=meal&number=10&sort=popularity&apiKey=\(apiKey)&addRecipeNutrition=true"
        
        guard let url = URL(string: urlString) else {
            throw RCErrors.InvalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RCErrors.InvalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
            return decodedResponse.results
        } catch {
            throw RCErrors.InvalidData
        }
    }
}

enum RCErrors: Error {
    case InvalidURL
    case InvalidResponse
    case InvalidData
}
