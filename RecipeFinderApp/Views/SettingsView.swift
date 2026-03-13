//
//  SettingsView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/2/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dietPreference") var dietPreference: String = "None"
//    @AppStorage("maxCookingTime") var maxCookingTime: Int = 0
    @AppStorage("sortBy") var sortBy: String = "Relevance"
    @AppStorage("showNutrition") var showNutrition: Bool = true
    
    @State private var showResetWarning = false
    @State private var animateWarning = false
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Dietary Preferences").font(.headline)) {
                    Picker("Diet Preference", selection: $dietPreference) { // when the user picks an option, dietPreference updates automatically
                        Text("None").tag("None")
                        Text("Vegetarian").tag("Vegetarian")
                        Text("Vegan").tag("Vegan")
                        Text("Gluten-Free").tag("Gluten-Free")
                        Text("Keto").tag("Keto")
                    }
                }
                
                Section(header: Text("Sorting Options").font(.headline)) {
                    Picker("Sort By", selection: $sortBy) {
                        Text("No Sort").tag("")
                        Text("Popularity").tag("popularity")
                        Text("Healthiness").tag("healthiness")
                        Text("Time").tag("time")
                    }

                }
                
                Section(header: Text("Display Options").font(.headline)) {
                    Toggle("Show Nutritional Info", isOn: $showNutrition)
                }
                    
                Section {
                    Button(action: {
                        withAnimation {
                            showResetWarning.toggle()
                            animateWarning = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Reset to Default")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
                }
                
                // app info
                Section(header: Text("About").font(.headline)) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text(Bundle.main.displayName ?? "")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.version ?? "")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.build ?? "")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Copyright")
                        Spacer()
                        Text(Bundle.main.copyright ?? "")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            
            if showResetWarning {
                VStack(spacing: 20) {
                    Text("Reset Settings?")
                        .font(.headline)
                    
                    Text("This will reset all settings to their default values. Are you sure?")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    HStack {
                        // cancel button
                        Button(action: {
                            withAnimation {
                                showResetWarning = false
                            }
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        
                        // confirm action
                        Button(action: {
                            resetToDefault()
                            withAnimation {
                                showResetWarning = false
                            }
                        }) {
                            Text("Confirm")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 10)
                )
                .frame(maxWidth: 300)
            }
        }
        .navigationTitle("Settings")
    }
    
    func resetToDefault() {
        dietPreference = "None"
//        maxCookingTime = 0
        sortBy = "Relevance"
        showNutrition = true
    }
}

#Preview {
    SettingsView()
}
