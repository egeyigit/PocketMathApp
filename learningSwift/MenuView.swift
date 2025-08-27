//
//  ContentView.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 23.02.2025.
//

import SwiftUI
import SwiftMath

struct MenuView: View {
    
    enum Page {
        case level1, level2, level3
    }
    
    @State private var selectedPage: Page? = nil

    var body: some View {
        NavigationStack {
            VStack {
                if selectedPage == nil {
                    List {
                        Button("4 operations mix") {
                            selectedPage = .level1
                        }
                        Button("only add and subtract") {
                            selectedPage = .level2
                        }
                        Button("only multiply and divide") {
                            selectedPage = .level3
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // This section controls the detail view based on selection
                    pageView(for: selectedPage!)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the content takes up available space
                }
            }
        }
    }
    
    // Function to return the correct view based on the selected page
    @ViewBuilder
    private func pageView(for page: Page) -> some View {
        switch page {
        case .level1:
            Generator1() // Your Generator1 content for level 1
        case .level2:
            Generator1() // Your Generator1 content for level 2
        case .level3:
            Generator1() // Your Generator1 content for level 3
        }
    }
}

#Preview {
    MenuView()
}
