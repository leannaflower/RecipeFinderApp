//
//  APIKEY.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 3/12/26.
//

import Foundation

final class Secrets {
    static var apiKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["API_KEY"] as? String
        else {
            fatalError("Missing API_KEY in Secrets.plist")
        }
        return key
    }
}
