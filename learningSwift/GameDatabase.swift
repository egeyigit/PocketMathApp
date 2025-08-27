//
//  GameDatabase.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 24.03.2025.
//

import Foundation

struct GameAttempt: Codable {
    let score: Int // out of 10
    let time: Int // in seconds
    let date: Date
    
    init(score: Int, time: Int) {
        self.score = score
        self.time = time
        self.date = Date()
    }
}

enum GameType: String, CaseIterable, Codable {
    case operationsMix = "4 Operations Mix"
    case additionSubtraction = "Addition & Subtraction"
    case multiplicationDivision = "Multiplication & Division"
    case fractions = "Fractions"
    case polynomial = "Polynomial Factoring"
    case equations = "Linear Equations"
}

class GameDatabase {
    static let shared = GameDatabase()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private func attemptsKey(gameType: GameType, difficulty: Int) -> String {
        return "attempts_\(gameType.rawValue)_difficulty_\(difficulty)"
    }
    
    private func bestScoreKey(gameType: GameType, difficulty: Int) -> String {
        return "bestScore_\(gameType.rawValue)_difficulty_\(difficulty)"
    }
    
    private func bestTimeKey(gameType: GameType, difficulty: Int) -> String {
        return "bestTime_\(gameType.rawValue)_difficulty_\(difficulty)"
    }
    
    // MARK: - Save Methods
    
    /// Save a new game attempt
    func saveAttempt(gameType: GameType, difficulty: Int, score: Int, time: Int) {
        let attempt = GameAttempt(score: score, time: time)
        
        // Save to attempts history
        var attempts = getAttempts(gameType: gameType, difficulty: difficulty)
        attempts.append(attempt)
        
        if let encodedData = try? JSONEncoder().encode(attempts) {
            defaults.set(encodedData, forKey: attemptsKey(gameType: gameType, difficulty: difficulty))
        }
        
        // Update best score if needed
        let bestScore = getBestScore(gameType: gameType, difficulty: difficulty)
        if score > bestScore {
            defaults.set(score, forKey: bestScoreKey(gameType: gameType, difficulty: difficulty))
        }
        
        // Update best time if needed (only if score is perfect)
        if score == 10 {
            let bestTime = getBestTime(gameType: gameType, difficulty: difficulty)
            if bestTime == 0 || time < bestTime {
                defaults.set(time, forKey: bestTimeKey(gameType: gameType, difficulty: difficulty))
            }
        }
    }
    
    // MARK: - Retrieve Methods
    
    /// Get all attempts for a specific game type and difficulty
    func getAttempts(gameType: GameType, difficulty: Int) -> [GameAttempt] {
        if let data = defaults.data(forKey: attemptsKey(gameType: gameType, difficulty: difficulty)),
           let attempts = try? JSONDecoder().decode([GameAttempt].self, from: data) {
            return attempts
        }
        return []
    }
    
    /// Get best score for a specific game type and difficulty
    func getBestScore(gameType: GameType, difficulty: Int) -> Int {
        return defaults.integer(forKey: bestScoreKey(gameType: gameType, difficulty: difficulty))
    }
    
    /// Get best time for a specific game type and difficulty (only for perfect scores)
    func getBestTime(gameType: GameType, difficulty: Int) -> Int {
        return defaults.integer(forKey: bestTimeKey(gameType: gameType, difficulty: difficulty))
    }
    
    /// Get all best scores for a game type across all difficulties
    func getAllBestScores(gameType: GameType) -> [Int] {
        return [
            getBestScore(gameType: gameType, difficulty: 1),
            getBestScore(gameType: gameType, difficulty: 2),
            getBestScore(gameType: gameType, difficulty: 3)
        ]
    }
    
    /// Get all best times for a game type across all difficulties
    func getAllBestTimes(gameType: GameType) -> [Int] {
        return [
            getBestTime(gameType: gameType, difficulty: 1),
            getBestTime(gameType: gameType, difficulty: 2),
            getBestTime(gameType: gameType, difficulty: 3)
        ]
    }
    
    // MARK: - Utility Methods
    
    /// Clear all data for testing purposes
    func clearAllData() {
        for gameType in GameType.allCases {
            for difficulty in 1...3 {
                defaults.removeObject(forKey: attemptsKey(gameType: gameType, difficulty: difficulty))
                defaults.removeObject(forKey: bestScoreKey(gameType: gameType, difficulty: difficulty))
                defaults.removeObject(forKey: bestTimeKey(gameType: gameType, difficulty: difficulty))
            }
        }
    }
} 