//
//  trashcode.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 1.03.2025.
//

class MathExpressionGenerator {
    
    // Available operations
    let operations = ["+", "-", "*", "/"]
    let variables = ["x", "y", "z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]
    
    // Generate a random expression
    func generateExpression(depth: Int = 3, multiOperandDepth: Int = 1, unallowedOps: [String]? = nil) -> Any {
        let allowedOps = unallowedOps != nil ? operations.filter { !unallowedOps!.contains($0) } : operations
        
        func generateTerm(currentDepth: Int) -> Any {
            // Base case - return a number at max depth
            if currentDepth >= depth {
                return Int.random(in: 1...100)
            }
            
            // Choose a random operation
            let operation = allowedOps.randomElement() ?? "+"
            
            // For operations +, -, * at specified multi-operand depth,
            // generate multiple operands (2-6)
            if currentDepth == depth - multiOperandDepth && ["+", "-", "*"].contains(operation) {
                let operandCount = Int.random(in: 2...6)
                var result: [Any] = [operation]
                
                // Generate multiple operands
                for _ in 0..<operandCount {
                    result.append(Int.random(in: 1...100))
                }
                
                return result
            }
            
            // Standard binary operation for other depths
            if operation == "/" {
                return [operation, generateTerm(currentDepth: currentDepth + 1), generateTerm(currentDepth: currentDepth + 1)]
            } else {
                return [operation, generateTerm(currentDepth: currentDepth + 1), generateTerm(currentDepth: currentDepth + 1)]
            }
        }
        
        // Start generation from depth 0
        return generateTerm(currentDepth: 0)
    }
    
    // Convert expression to LaTeX
    func convertToLatex(expr: Any) -> String {
        if let number = expr as? Int {
            return "\(number)"
        }
        
        guard let expressionArray = expr as? [Any], expressionArray.count >= 2,
              let operation = expressionArray[0] as? String else {
            return "\\text{Error: Invalid expression}"
        }
        
        let operands = Array(expressionArray.dropFirst())
        
        switch operation {
        case "+":
            // Handle addition
            return operands.map { convertToLatex(expr: $0) }.joined(separator: " + ")
            
        case "-":
            // Handle subtraction
            if operands.count == 2 {
                return "\(convertToLatex(expr: operands[0])) - \(convertToLatex(expr: operands[1]))"
            } else {
                let first = convertToLatex(expr: operands[0])
                let rest = operands.dropFirst().map { convertToLatex(expr: $0) }.joined(separator: " - ")
                return "\(first) - \(rest)"
            }
            
        case "*":
            // Handle multiplication with special formatting
            var latexParts: [String] = []
            
            for (index, operand) in operands.enumerated() {
                let latex = convertToLatex(expr: operand)
                
                // Format based on operand type
                if latex.contains("\\frac") {
                    // No parentheses for fractions
                    latexParts.append(latex)
                } else if (((operand as? Int) != nil) ||
                           (latex.allSatisfy { $0.isNumber } || (latex.hasPrefix("-") && String(latex.dropFirst()).allSatisfy { $0.isNumber }))) != nil {
                    // For numbers, add parentheses except for the first number
                    if index > 0 {
                        latexParts.append("(\(latex))")
                    } else {
                        latexParts.append(latex)
                    }
                } else {
                    // For complex expressions, add parentheses
                    latexParts.append("(\(latex))")
                }
            }
            
            return latexParts.joined()
            
        case "/":
            // Handle division using frac
            if operands.count == 2 {
                let numerator = convertToLatex(expr: operands[0])
                let denominator = convertToLatex(expr: operands[1])
                return "\\frac{\(numerator)}{\(denominator)}"
            } else {
                return "\\text{Error: Division requires 2 operands}"
            }
            
        default:
            return "\\text{Error: Unknown operator}"
        }
    }
    
    // Evaluate the expression to get the numerical result
    func evaluateExpression(expr: Any) -> Double {
        if let number = expr as? Int {
            return Double(number)
        }
        
        guard let expressionArray = expr as? [Any], expressionArray.count >= 2,
              let operation = expressionArray[0] as? String else {
            return Double.nan
        }
        
        let operands = Array(expressionArray.dropFirst())
        let operandValues = operands.map { evaluateExpression(expr: $0) }
        
        switch operation {
        case "+":
            return operandValues.reduce(0, +)
            
        case "-":
            if operandValues.isEmpty { return 0 }
            let first = operandValues[0]
            let rest = operandValues.dropFirst().reduce(0, +)
            return first - rest
            
        case "*":
            return operandValues.reduce(1, *)
            
        case "/":
            if operandValues.count != 2 {
                return Double.nan
            }
            if operandValues[1] == 0 {
                return Double.infinity
            }
            return operandValues[0] / operandValues[1]
            
        default:
            return Double.nan
        }
    }
}



