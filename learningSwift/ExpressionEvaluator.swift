import Foundation

/// A simple mathematical expression evaluator that supports +, -, *, /, and parentheses
class ExpressionEvaluator {
    
    // MARK: - Public Interface
    
    /// Evaluates a mathematical expression string and returns the result
    /// - Parameter expression: A string containing a valid mathematical expression
    /// - Returns: The result of evaluating the expression
    /// - Throws: `ExpressionError` if the expression is invalid
    static func evaluate(_ expression: String) throws -> Double {
        let scanner = Scanner(expression: expression)
        let result = try parseExpression(scanner)
        
        // Make sure we consumed the entire expression
        if scanner.currentIndex < scanner.expression.endIndex {
            throw ExpressionError.invalidExpression("Unexpected token at position \(scanner.expression.distance(from: scanner.expression.startIndex, to: scanner.currentIndex))")
        }
        
        return result
    }
    
    // MARK: - Recursive Descent Parser
    
    // Expression = Term [+|- Term]*
    private static func parseExpression(_ scanner: Scanner) throws -> Double {
        var result = try parseTerm(scanner)
        
        while true {
            scanner.skipWhitespace()
            
            if scanner.isAtEnd() {
                return result
            }
            
            let currentChar = scanner.peek()
            if currentChar == "+" {
                scanner.advance()
                let term = try parseTerm(scanner)
                result += term
            } else if currentChar == "-" {
                scanner.advance()
                let term = try parseTerm(scanner)
                result -= term
            } else {
                return result
            }
        }
    }
    
    // Term = Factor [*|/ Factor]*
    private static func parseTerm(_ scanner: Scanner) throws -> Double {
        var result = try parseFactor(scanner)
        
        while true {
            scanner.skipWhitespace()
            
            if scanner.isAtEnd() {
                return result
            }
            
            let currentChar = scanner.peek()
            if currentChar == "*" {
                scanner.advance()
                let factor = try parseFactor(scanner)
                result *= factor
            } else if currentChar == "/" {
                scanner.advance()
                let factor = try parseFactor(scanner)
                if factor == 0 {
                    throw ExpressionError.divisionByZero
                }
                result /= factor
            } else {
                return result
            }
        }
    }
    
    // Factor = Number | "(" Expression ")" | [-|+] Factor
    private static func parseFactor(_ scanner: Scanner) throws -> Double {
        scanner.skipWhitespace()
        
        if scanner.isAtEnd() {
            throw ExpressionError.unexpectedEndOfExpression
        }
        
        let currentChar = scanner.peek()
        
        // Handle unary operators
        if currentChar == "-" {
            scanner.advance()
            let factor = try parseFactor(scanner)
            return -factor
        } else if currentChar == "+" {
            scanner.advance()
            return try parseFactor(scanner)
        }
        
        // Handle parentheses
        if currentChar == "(" {
            scanner.advance()
            let result = try parseExpression(scanner)
            
            scanner.skipWhitespace()
            if scanner.isAtEnd() || scanner.peek() != ")" {
                throw ExpressionError.mismatchedParentheses
            }
            
            scanner.advance() // Consume the closing parenthesis
            return result
        }
        
        // Handle numbers
        return try parseNumber(scanner)
    }
    
    // Parse a numeric value
    private static func parseNumber(_ scanner: Scanner) throws -> Double {
        scanner.skipWhitespace()
        
        if scanner.isAtEnd() {
            throw ExpressionError.unexpectedEndOfExpression
        }
        
        let start = scanner.currentIndex
        
        // Check if it's a digit or decimal point
        if !scanner.peek().isNumber && scanner.peek() != "." {
            throw ExpressionError.expectedNumber("at position \(start)")
        }
        
        // Consume digits before decimal point
        while !scanner.isAtEnd() && scanner.peek().isNumber {
            scanner.advance()
        }
        
        // Handle decimal point
        if !scanner.isAtEnd() && scanner.peek() == "." {
            scanner.advance()
            
            // Consume digits after decimal point
            while !scanner.isAtEnd() && scanner.peek().isNumber {
                scanner.advance()
            }
        }
        
        let end = scanner.currentIndex
        let numberString = scanner.expression[start..<end]
        
        guard let number = Double(numberString) else {
            throw ExpressionError.invalidNumber("'\(numberString)' is not a valid number")
        }
        
        return number
    }
    
    // MARK: - Helper Classes
    
    /// Simple scanner to help parse the expression
    private class Scanner {
        let expression: String
        var currentIndex: String.Index
        
        init(expression: String) {
            self.expression = expression
            self.currentIndex = expression.startIndex
        }
        
        func isAtEnd() -> Bool {
            return currentIndex >= expression.endIndex
        }
        
        func peek() -> Character {
            guard !isAtEnd() else {
                return "\0" // Null character for end of input
            }
            return expression[currentIndex]
        }
        
        func advance() {
            if !isAtEnd() {
                currentIndex = expression.index(after: currentIndex)
            }
        }
        
        func skipWhitespace() {
            while !isAtEnd() && peek().isWhitespace {
                advance()
            }
        }

    }
    
    // MARK: - Error Handling
    
    /// Errors that can occur during expression evaluation
    enum ExpressionError: Error, LocalizedError {
        case invalidExpression(String)
        case unexpectedEndOfExpression
        case mismatchedParentheses
        case divisionByZero
        case expectedNumber(String)
        case invalidNumber(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidExpression(let reason):
                return "Invalid expression: \(reason)"
            case .unexpectedEndOfExpression:
                return "Unexpected end of expression"
            case .mismatchedParentheses:
                return "Mismatched parentheses"
            case .divisionByZero:
                return "Division by zero"
            case .expectedNumber(let position):
                return "Expected number \(position)"
            case .invalidNumber(let message):
                return "Invalid number: \(message)"
            }
        }
    }
}

// MARK: - Extension for String Index Subscript
private extension String {
    subscript(range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

// MARK: - Convenience Functions

/// Evaluates a mathematical expression and returns the result.
/// This is a convenience function that handles errors by returning nil.
/// - Parameter expression: A string containing a valid mathematical expression
/// - Returns: The result of evaluating the expression, or nil if an error occurred
func evaluate(_ expression: String) -> Double? {
    do {
        return try ExpressionEvaluator.evaluate(expression)
    } catch {
        print("Error evaluating expression: \(error.localizedDescription)")
        return nil
    }
}

/// Evaluates a mathematical expression and returns the result.
/// This is a convenience function that handles errors by returning a default value.
/// - Parameters:
///   - expression: A string containing a valid mathematical expression
///   - defaultValue: The value to return if an error occurs
/// - Returns: The result of evaluating the expression, or the default value if an error occurred
func evaluate(_ expression: String, defaultValue: Double) -> Double {
    do {
        return try ExpressionEvaluator.evaluate(expression)
    } catch {
        print("Error evaluating expression: \(error.localizedDescription)")
        return defaultValue
    }
} 
