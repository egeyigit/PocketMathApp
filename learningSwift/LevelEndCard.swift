//
//  LevelEndCardf.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 2.03.2025.
//

import Foundation
import SwiftUI

struct LevelEndCard: View {
    @Binding var score: Int
    @Binding var showCard: Bool
    @Binding var viewID: UUID
    var onPlayAgain: () -> Void
    
    @State private var navigateToMenu: Bool = false
    
    var gameType: GameType
    var difficulty: Int
    var timeElapsed: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Overlay that covers the entire screen
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(showCard ? 1 : 0)
                
                VStack(spacing: 0) {
                    // Top section with title and score
                    VStack {
                        Text("Results")
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
                        // Menu button - takes up the full width
                        Button(action: {
                            showCard = false
                            navigateToMenu = true
                        }) {
                            Text("Menu")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.green)
                        }
                        
                        // Play Again button - takes up the full width
                        Button(action: {
                            onPlayAgain()
                            withAnimation {
                                showCard = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "repeat")
                                Text("Play Again")
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(Color.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                }
                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.4)
                .shadow(radius: 10)
                .opacity(showCard ? 1 : 0)
                .animation(.easeInOut, value: showCard)
            }
            
            // Modern navigation handling (replacing the deprecated method)
            .navigationDestination(isPresented: $navigateToMenu) {
                MenuView()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Save the attempt when the card appears
            GameDatabase.shared.saveAttempt(
                gameType: gameType,
                difficulty: difficulty,
                score: score,
                time: timeElapsed
            )
        }
    }
}

// Extension to allow for specific corner rounding

