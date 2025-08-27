//
//  pausemenu.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 2.03.2025.
//

import Foundation
import SwiftUI

struct pausemenu: View {
    @Binding var score: Int
    @Binding var paused: Bool
    @State private var navigateToMenu: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Overlay that covers the entire screen
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(paused ? 1 : 0)
                
                VStack(spacing: 0) {
                    // Top section with title and score
                    VStack {
                        Text("Level Paused")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text("Your score: \(score)")
                            .font(.title)
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    
                    // Bottom section with buttons
                    VStack(spacing: 0) {
                        // Quit button - takes up the full width
                        Button(action: {
                            paused = false
                            navigateToMenu = true
                        }) {
                            Text("Quit")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.red)
                        }
                        
                        // Continue button - takes up the full width
                        Button(action: {
                            withAnimation {
                                paused = false
                            }
                        }) {
                            Text("Continue")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                    
                    NavigationLink(
                        destination: MenuView(),
                        isActive: $navigateToMenu,
                        label: {
                            EmptyView()
                        })
                }
                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.4)
                .shadow(radius: 10)
                .opacity(paused ? 1 : 0)
                .animation(.easeInOut, value: paused)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Extension to allow for specific corner rounding
