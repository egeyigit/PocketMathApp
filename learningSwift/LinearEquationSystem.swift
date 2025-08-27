//
//  LinearEquationSystem.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 28.03.2025.
//

import Foundation

struct LinearEquationSystem: GenerationSystem {
    // System settings
    let variableCount: Int // 1, 2, or 3
    
    // Helper function to generate a complex expression
    private func generateExpression(solution: Double, maxCoefficient: Int, maxConstant: Int) -> String {
        let formatType = Int.random(in: 0...2)
        
        switch formatType {
        case 0: // Format: a(x+b) + c
            let a = Int.random(in: 1...maxCoefficient)
            let c = Int.random(in: 1...maxConstant/2)
            let targetNumber = Int.random(in: maxConstant/2...maxConstant)
            let b = Int((Double(targetNumber - c) / Double(a)) - solution)
            return "\(a)(x\(b >= 0 ? "+" : "")\(b)) \(c >= 0 ? "+" : "")\(c)"
            
        case 1: // Format: a(x+b) - c
            let a = Int.random(in: 1...maxCoefficient)
            let c = Int.random(in: 1...maxConstant/2)
            let targetNumber = Int.random(in: maxConstant/2...maxConstant)
            let b = Int((Double(targetNumber + c) / Double(a)) - solution)
            return "\(a)(x\(b >= 0 ? "+" : "")\(b)) - \(c)"
            
        case 2: // Format: (ax-b)/c + d
            let a = Int.random(in: 1...maxCoefficient)
            let c = Int.random(in: 2...maxCoefficient)
            let d = Int.random(in: 1...maxConstant/3)
            let targetNumber = Int.random(in: maxConstant/2...maxConstant)
            let targetMinusD = targetNumber - d
            let cMultiplied = Double(c) * Double(targetMinusD)
            let aSolution = Double(a) * solution
            let b = Int(aSolution - cMultiplied)
            return "\\frac{" + "\(a)x - \(b)" + "}{" + "\(c)" + "} \(d >= 0 ? "+" : "")\(d)"
            
        default:
            return "x"
        }
    }
    
    private func generateOneVariableEquation(level: Int) -> (latex: String, solution: [String: Any]) {
        let maxCoefficient = min(5 + level * 2, 12)
        let maxConstant = min(20 + level * 5, 50)
        
        // Generate a solution first
        let solution = Double(Int.random(in: 1...(5 * level)))
        
        // Generate complex expressions for both sides
        let leftSide = generateExpression(solution: solution, 
                                        maxCoefficient: maxCoefficient, 
                                        maxConstant: maxConstant)
        
        let rightSide = generateExpression(solution: solution, 
                                         maxCoefficient: maxCoefficient, 
                                         maxConstant: maxConstant)
        
        let equationString = "\(leftSide) = \(rightSide)"
        
        return (latex: equationString, solution: ["x": solution])
    }
    
    // Helper function for two-variable expressions
    private func generateTwoVarExpression(x: Double, y: Double, maxCoefficient: Int) -> (expression: String, result: Double) {
        let a = Int.random(in: 1...maxCoefficient)
        let b = Int.random(in: -maxCoefficient...maxCoefficient)
        let c = Int.random(in: -maxCoefficient...maxCoefficient)
        
        let result = Double(a) * x + Double(b) * y + Double(c)
        let expression = "\(a)x \(b >= 0 ? "+" : "")\(b)y \(c >= 0 ? "+" : "")\(c)"
        
        return (expression, result)
    }
    
    private func generateTwoVariableSystem(level: Int) -> (latex: String, solution: [String: Any]) {
        let maxCoefficient = min(5 + level * 2, 8)
        
        let xSolution = Double(Int.random(in: 1...(3 * level)))
        let ySolution = Double(Int.random(in: 1...(3 * level)))
        
        print(xSolution,ySolution)
        
        // Generate two equations with complex expressions on both sides
        let (leftExp1, leftResult1) = generateTwoVarExpression(x: xSolution, y: ySolution, maxCoefficient: maxCoefficient)
        let (rightExp1, rightResult1) = generateTwoVarExpression(x: xSolution, y: ySolution, maxCoefficient: maxCoefficient)
        
      
        
        print("exps::")
        print(leftExp1, leftResult1)
        
        
        let equation1 = "\(leftExp1) = \(leftResult1)"
        let equation2 = "\(rightExp1) = \(rightResult1)"
        
        print("equations:")
        print(equation1, equation2)
        
        
        
        // Return equations as array
        let equations = [equation1, equation2]
        let latexSystem = equations.joined(separator: "\\\\")  // Join for compatibility
        
        return (latex: latexSystem, solution: ["x": xSolution, "y": ySolution, "equations": equations])
    }
    
    // Helper function for three-variable expressions
    private func generateThreeVarExpression(x: Double, y: Double, z: Double, maxCoefficient: Int) -> (expression: String, result: Double) {
        let a = Int.random(in: 1...maxCoefficient)
        let b = Int.random(in: -maxCoefficient...maxCoefficient)
        let c = Int.random(in: -maxCoefficient...maxCoefficient)
        let d = Int.random(in: -maxCoefficient...maxCoefficient)
        
        let result = Double(a) * x + Double(b) * y + Double(c) * z + Double(d)
        let expression = "\(a)x \(b >= 0 ? "+" : "")\(b)y \(c >= 0 ? "+" : "")\(c)z \(d >= 0 ? "+" : "")\(d)"
        
        return (expression, result)
    }
    
    private func generateThreeVariableSystem(level: Int) -> (latex: String, solution: [String: Any]) {
        let maxCoefficient = min(3 + level, 6)
        
        let xSolution = Double(Int.random(in: 1...(2 * level)))
        let ySolution = Double(Int.random(in: 1...(2 * level)))
        let zSolution = Double(Int.random(in: 1...(2 * level)))
        
        // Generate three equations with complex expressions on both sides
        let (leftExp1, leftResult1) = generateThreeVarExpression(x: xSolution, y: ySolution, z: zSolution, maxCoefficient: maxCoefficient)
        let (rightExp1, rightResult1) = generateThreeVarExpression(x: xSolution, y: ySolution, z: zSolution, maxCoefficient: maxCoefficient)
        
        let (leftExp2, leftResult2) = generateThreeVarExpression(x: xSolution, y: ySolution, z: zSolution, maxCoefficient: maxCoefficient)
        let (rightExp2, rightResult2) = generateThreeVarExpression(x: xSolution, y: ySolution, z: zSolution, maxCoefficient: maxCoefficient)
        
        let (leftExp3, leftResult3) = generateThreeVarExpression(x: xSolution, y: ySolution, z: zSolution, maxCoefficient: maxCoefficient)
        let (rightExp3, rightResult3) = generateThreeVarExpression(x: xSolution, y: ySolution, z: zSolution, maxCoefficient: maxCoefficient)
        
        let equation1 = "\(leftExp1) = \(rightExp1)"
        let equation2 = "\(leftExp2) = \(rightExp2)"
        let equation3 = "\(leftExp3) = \(rightExp3)"
        
        // Return equations as array
        let equations = [equation1, equation2, equation3]
        let latexSystem = equations.joined(separator: "\\\\")  // Join for compatibility
        
        return (latex: latexSystem, solution: ["x": xSolution, "y": ySolution, "z": zSolution, "equations": equations])
    }
    
    // Required protocol methods
    func generateProblem(level: Int) -> (latex: String, solution: [String: Any]) {
        switch variableCount {
        case 1:
            return generateOneVariableEquation(level: level)
        case 2:
            return generateTwoVariableSystem(level: level)
        case 3:
            return generateThreeVariableSystem(level: level)
        default:
            return generateOneVariableEquation(level: level)
        }
    }
    
    func checkAnswer(userInputs: [String: String], solution: [String: Any]) -> Bool {
        // Only validate declared input variables (e.g., x, y, z). Ignore metadata like "equations".
        let variablesToCheck = getInputVariables()
        let epsilon = 0.001
        
        for variable in variablesToCheck {
            guard let expectedValue = solution[variable] as? Double else { return false }
            guard let rawInput = userInputs[variable], !rawInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            
            // Allow comma as decimal separator as well
            let normalized = rawInput.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
            guard let inputValue = Double(normalized) else { return false }
            if abs(inputValue - expectedValue) > epsilon { return false }
        }
        
        return true
    }
    
    func getInputVariables() -> [String] {
        switch variableCount {
        case 1:
            return ["x"]
        case 2:
            return ["x", "y"]
        case 3:
            return ["x", "y", "z"]
        default:
            return ["x"]
        }
    }
    
    func formatSolution(solution: [String: Any]) -> String? {
        var formattedSolution = ""
        let sortedKeys = solution.keys.sorted()
        
        for key in sortedKeys {
            if let value = solution[key] as? Double {
                formattedSolution += "\(key) = \(String(format: "%.2f", value))\n"
            }
        }
        
        return formattedSolution
    }
}
