//
//  ShoppingCartView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import SwiftUI

struct ShoppingCartView: View {
    @EnvironmentObject var pantryManager: PantryManager
    @State private var ingredientName: String = ""

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            NavigationView {
                VStack {
                    VStack {
                        TextField("Enter ingredient name to add...", text: $ingredientName)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        HStack {
                            Button(action: {
                                if !ingredientName.isEmpty {
                                    pantryManager.addToPantry(ingredientName)
                                    ingredientName = ""
                                }
                            }) {
                                Label("Add to Pantry", systemImage: "plus.circle")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .padding(.horizontal)
                            .disabled(ingredientName.isEmpty)

                            Button(action: {
                                if !ingredientName.isEmpty {
                                    pantryManager.addToCart(ingredientName)
                                    ingredientName = ""
                                }
                            }) {
                                Label("Add to Cart", systemImage: "cart.badge.plus")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .padding(.horizontal)
                            .disabled(ingredientName.isEmpty)
                        }
                    }
                    .padding(.bottom)

                    List {
                        Section(header: Text("Pantry")) {
                            ForEach(pantryManager.pantry, id: \.self) { item in
                                HStack {
                                    Text(item.capitalized)
                                    Spacer()
                                    Button(action: {
                                        pantryManager.removeFromPantry(item)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }

                        Section(header: Text("Shopping Cart")) {
                            ForEach(pantryManager.shoppingCart, id: \.self) { item in
                                HStack {
                                    Text(item.capitalized)
                                    Spacer()
                                    Button(action: {
                                        pantryManager.removeFromCart(item)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationTitle("Cart & Pantry")
            }
        }
    }
}


#Preview() {
    let samplePantryManager = PantryManager()
    samplePantryManager.pantry = ["Spaghetti", "Tomato Sauce", "Parmesan"]
    samplePantryManager.shoppingCart = ["Olive Oil", "Garlic"]

    return ShoppingCartView()
        .environmentObject(samplePantryManager)
}
