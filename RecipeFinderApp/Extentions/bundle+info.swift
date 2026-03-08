//
//  bundle+info.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/1/24.
//

import Foundation

extension Bundle {  // access the Recipe-Finder-Info.plist at runtime
    /*
     CFBundleName — the app's display name ("Recipe Finder")
     CFBundleShortVersionString — the version number ("1.0")
     CFBundleVersion — the build number ("1")
     NSHumanReadableCopyright — the copyright string
     */
    
    // app's display name
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    // app's version
    var version: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    // app's build
    var build: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    // app's copyright string
    var copyright: String? {
        return object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
    }
}
