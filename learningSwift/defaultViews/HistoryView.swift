//
//  HistoryView.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 24.03.2025.
//

import SwiftUI

struct HistoryView: View {
    let gameType: GameType
    @State private var selectedDifficulty = 1
    
    var body: some View {
        VStack {
            // Header with game type and back button
            HStack {
                
                Text("\(gameType.rawValue) History")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            // Difficulty selector
            Picker("Difficulty", selection: $selectedDifficulty) {
                Text("Easy").tag(1)
                Text("Medium").tag(2)
                Text("Hard").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Best performance section
            VStack(spacing: 10) {
                Text("Best Performance")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Best Score")
                            .font(.subheadline)
                        Text("\(GameDatabase.shared.getBestScore(gameType: gameType, difficulty: selectedDifficulty))/10")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    VStack {
                        Text("Best Time")
                            .font(.subheadline)
                        let bestTime = GameDatabase.shared.getBestTime(gameType: gameType, difficulty: selectedDifficulty)
                        Text(bestTime > 0 ? "\(bestTime)s" : "-")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            
            // History list
            List {
                ForEach(GameDatabase.shared.getAttempts(gameType: gameType, difficulty: selectedDifficulty), id: \.date) { attempt in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Score: \(attempt.score)/10")
                                .fontWeight(.semibold)
                            Text("Time: \(attempt.time) seconds")
                        }
                        
                        Spacer()
                        
                        Text(formattedDate(attempt.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(gameType: .operationsMix)
    }
} 
