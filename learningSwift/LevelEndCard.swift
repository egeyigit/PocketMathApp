//
//  LevelEndCardf.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 2.03.2025.
//

import Foundation
import SwiftUI

struct LevelEndCardold: View {
    @Binding var score: Int
    @Binding var showCard: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Results")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxHeight: .infinity)

                
                Text("Your score: \(score)")
                    .font(.title)
                    .padding()
                    .frame(maxHeight: .infinity)

                
                GeometryReader { geometry2 in
                    VStack {
                        Spacer() // This pushes the buttons to the bottom of the screen
                        
                        HStack {
                            Button(action: {
                                // Close the card
                                withAnimation {
                                    showCard = false
                                }
                            }) {
                                Text("Menu")
                                    .font(.title2)
                                    
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(width: .infinity) // Half width and height
                            }
                            .padding(.top)
                            
                            Button(action: {
                                // Close the card
                                withAnimation {
                                    showCard = false
                                }
                            }) {
                                Label("", systemImage: "repeat")
                                    .font(.system(size: 30, weight: .bold)) // Makes the arrow thicker
                                    .foregroundColor(.white) // Makes the arrow white
                                     // Adds padding to increase button size
                                    .background(Color.blue) // Change button background color
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.6), radius: 10, x: 5, y: 5)
                                    .frame(width: .infinity) // Half width and height
                            }
                            .padding(.top)
                        }
                        .frame(maxWidth: .infinity) // Ensure the HStack fills the width of the parent container
                        .padding(.bottom, geometry2.size.height * 0.05) // Optional, gives some space from the bottom
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures the VStack takes up all available space
                }
            }
            .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.4)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal)
            .padding(.top, 200)// Position card from top
            .opacity(showCard ? 1 : 0)  // Make the card invisible when showCard is false
            .animation(.easeInOut, value: showCard) // Smooth transition when visibility changes
        }
        .edgesIgnoringSafeArea(.all)
    }
}
