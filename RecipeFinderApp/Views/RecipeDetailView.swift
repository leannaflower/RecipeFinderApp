//
//  RecipeDetailView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import SwiftUI
import UserNotifications

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var pantryManager: PantryManager // check what's in the pantry
    @EnvironmentObject var notificationMgr: NotificationManager // schedule reminders
    
    
    @State private var ingredients: [Ingredient] = []
    @State private var isLoading = true
    @State private var showCustomActionSheet: Bool = false
    @State private var alertDate = Date()
    @State private var showConfirmation: Bool = false
    
    @AppStorage("showNutrition") private var showNutrition: Bool = true // reads the same key set in SettingsView
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // image and title
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: recipe.image))
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        
                        LinearGradient(
                            colors: [Color.black.opacity(0.5), Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 80)
                        .cornerRadius(15)
                        
                        Text(recipe.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding([.leading, .bottom], 15)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        
                        // schedule reminder button
                        Button(action: {
                            showCustomActionSheet = true
                        }) {
                            HStack {
                                Image(systemName: "bell")
                                Text("Set Reminder for Cooking")
                            }
                            .font(.body)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        Spacer()
                    }
                    
                    // reminder confirmation pop-up
                    if showConfirmation {
                        Text("Reminder Scheduled!")
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .transition(.scale)
                            .zIndex(1)
                    }
                    
                    
                    
                    // nutrition section
                    if showNutrition, let nutrition = recipe.nutrition {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Nutritional Facts")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ForEach(nutrition.nutrients.prefix(5), id: \.name) { nutrient in
                                NutrientRow(nutrient: nutrient)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            // Ingredients List
            if isLoading {
                ProgressView("Loading ingredients...")
                    .padding()
            } else if ingredients.isEmpty {
                Text("Ingredients not available.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    Section(header: Text("Ingredients").font(.headline)) {
                        ForEach(ingredients, id: \.name) { ingredient in
                            HStack {
                                Text(ingredient.name.capitalized)
                                    .font(.body)
                                    .foregroundColor(pantryManager.isInPantry(ingredient.name) ? .green : .primary)
                                
                                if pantryManager.isInPantry(ingredient.name) {
                                    Text("In Pantry")
                                        .foregroundColor(.green)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    pantryManager.addToCart(ingredient.name)
                                } label: {
                                    Label("Add to Cart", systemImage: "cart.badge.plus")
                                }
                                .tint(.blue)
                                
                                Button {
                                    pantryManager.addToPantry(ingredient.name)
                                } label: {
                                    Label("Add to Pantry", systemImage: "plus.circle")
                                }
                                .tint(.green)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear {
            fetchIngredients(recipeId: recipe.id)
        }
        .sheet(isPresented: $showCustomActionSheet) {
            CustomActionSheet(alertDate: $alertDate) {
                notificationMgr.scheduleNotification(date: alertDate)
                withAnimation {
                    showConfirmation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showConfirmation = false
                    }
                }
                showCustomActionSheet = false
            }
        }
    }
    
    func fetchIngredients(recipeId: Int) {
        let apiKey = "5ca5612f076f4760956a7e9eb02754d3"
        let urlString = "https://api.spoonacular.com/recipes/\(recipeId)/ingredientWidget.json?apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(IngredientResponse.self, from: data)
                    DispatchQueue.main.async {
                        withAnimation {
                            self.ingredients = decodedResponse.ingredients
                            self.isLoading = false
                        }
                    }
                } catch {
                    print("Error decoding ingredients: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

// Custom action sheet; the date picker modal
struct CustomActionSheet: View {
    @Binding var alertDate: Date
    var onSubmit: () -> Void
    
    var body: some View {
        VStack {
            Text("Set Reminder")
                .font(.headline)
                .padding()
            
            DatePicker("Reminder Time", selection: $alertDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            Button(action: onSubmit) {
                Text("Submit Reminder")
                    .font(.body)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Nutrient Row for clean layout
struct NutrientRow: View {
    let nutrient: Nutrient
    
    var body: some View {
        HStack {
            Text(nutrient.name)
                .font(.body)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(String(format: "%.1f", nutrient.amount)) \(nutrient.unit)")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let sampleRecipe = Recipe(
        id: 1,
        title: "Spaghetti Carbonara",
        image: "https://via.placeholder.com/150",
        nutrition: Nutrition(
            nutrients: [
                Nutrient(name: "Calories", amount: 500, unit: "kcal"),
                Nutrient(name: "Protein", amount: 20, unit: "g")
            ]
        ),
        ingredients: [
            Ingredient(name: "Spaghetti", amount: 200, unit: "grams"),
            Ingredient(name: "Bacon", amount: 100, unit: "grams"),
            Ingredient(name: "Egg", amount: 2, unit: "pieces")
        ]
    )
    return RecipeDetailView(recipe: sampleRecipe)
        .environmentObject(PantryManager())
        .environmentObject(NotificationManager())
}
