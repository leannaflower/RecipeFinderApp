//
//  AppInfoView.swift
//  RecipeFinderApp
//
//  Created by Leanna Fowler on 12/2/24.
//

import SwiftUI

struct AppInfoView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("appiconimg-60x60")
                .resizable()
                .frame(width: 60, height: 60, alignment: .center)
            Text(Bundle.main.displayName ?? "")
                .font(.largeTitle)
                .fontWeight(.medium)
            Text(Bundle.main.version ?? "")
                .font(.title)
                .fontWeight(.medium)
            Text(Bundle.main.build ?? "")
                .font(.caption)
            
            Spacer()
            
            Text(Bundle.main.copyright ?? "")
                .font(.caption2)
        }
        .padding()
    }
}

#Preview {
    AppInfoView()
}
