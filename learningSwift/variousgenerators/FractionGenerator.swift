import Foundation

/// Structure to represent a fraction with numerator, denominator and sign
struct Fraction {
    var numerator: Int
    var denominator: Int
    var sign: Int // 1 for positive, -1 for negative
    
    var value: Double {
        return Double(sign * numerator) / Double(denominator)
    }
    
    static func gcd(_ a: Int, _ b: Int) -> Int {
        var a = abs(a)
        var b = abs(b)
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }
    
    func simplified() -> Fraction {
        if numerator == 0 {
            return Fraction(numerator: 0, denominator: 1, sign: 1)
        }
        
        // Ensure denominator is always positive
        // If denominator is negative, flip both numerator and sign
        var adjustedNumerator = numerator
        var adjustedSign = sign
        
        if denominator < 0 {
            adjustedNumerator = -adjustedNumerator
            adjustedSign = -adjustedSign
        }
        
        let divisor = Fraction.gcd(abs(adjustedNumerator), abs(denominator))
        return Fraction(
            numerator: abs(adjustedNumerator) / divisor,
            denominator: abs(denominator) / divisor,
            sign: adjustedSign
        )
    }
}

/// Class for generating fraction problems
class FractionGenerator {
    
    /// Generate fractions with two possible methods
    /// - Parameters:
    ///   - level: Difficulty level (1-3)
    ///   - methodCoefficient: Probability (0-1) of using random fraction generation
    /// - Returns: Tuple containing numerator fractions, denominator fractions, and final result
    static func generateFraction(level: Int, methodCoefficient: Double = 0.5) -> (uppers: [Fraction], lowers: [Fraction], result: Double, fractionString: String) {
        // Determine if we should generate a subtraction expression
        let generateSubtraction = Bool.random() && level > 1
        
        if generateSubtraction {
            // Generate a subtraction expression with two fractions
            // For subtraction, we'll generate two fractions and make the second one negative
            
            // Generate the first fraction (minuend)
            let num1 = Int.random(in: 10...50) * 5  // Make it divisible by 5 for simpler fractions
            let den1 = 5
            let frac1 = Fraction(numerator: num1, denominator: den1, sign: 1).simplified()
            
            // Generate the second fraction (subtrahend)
            let num2 = Int.random(in: 5...30) * 4   // Make it divisible by 4 for simpler fractions
            let den2 = 4
            let frac2 = Fraction(numerator: num2, denominator: den2, sign: -1).simplified() // Negative for subtraction
            
            // Calculate the result
            if let result = calculateFinalFraction(uppers: [frac1, frac2], lowers: []) {
                // Create the array of fractions
                let uppers = [frac1, frac2]
                let lowers: [Fraction] = []
                
                return (uppers, lowers, result.value, result.fractionString)
            }
        }
        
        // If not generating subtraction or if subtraction calculation failed, use the original method
        // Determine counts and ranges based on level
        var upCount = 0
        var downCount = 0
        var denominatorRange = (2, 20)
        var numeratorRange = (1, 5)
        
        switch level {
        case 1:
            upCount = Int.random(in: 1...2)
            downCount = Int.random(in: 0...1)
            denominatorRange = (2, 20)
            numeratorRange = (1, 5)
        case 2:
            upCount = Int.random(in: 1...2)
            downCount = Int.random(in: 1...2)
            denominatorRange = (2, 20)
            numeratorRange = (1, 10)
        case 3:
            upCount = Int.random(in: 1...2)
            downCount = Int.random(in: 1...2)
            denominatorRange = (2, 30)
            numeratorRange = (1, 15)
        default:
            upCount = 1
            downCount = 1
        }
        
        // Choose method based on coefficient
        let useRandomMethod = Double.random(in: 0..<1) < methodCoefficient
        
        if useRandomMethod {

            print("this is a")
            // Method 1: Generate random fractions
            var uppers: [Fraction] = []
            var lowers: [Fraction] = []
            
            // Generate numerator fractions
            for _ in 0..<upCount {
                let numerator = Int.random(in: numeratorRange.0...numeratorRange.1)
                let denominator = Int.random(in: denominatorRange.0...denominatorRange.1)
                let sign = Bool.random() ? 1 : -1
                uppers.append(Fraction(numerator: numerator, denominator: denominator, sign: sign))
            }
            
            // Generate denominator fractions
            for _ in 0..<downCount {
                let numerator = Int.random(in: numeratorRange.0...numeratorRange.1)
                let denominator = Int.random(in: denominatorRange.0...denominatorRange.1)
                let sign = Bool.random() ? 1 : -1
                lowers.append(Fraction(numerator: numerator, denominator: denominator, sign: sign))
            }
            
            // Calculate final fraction
            if let result = calculateFinalFraction(uppers: uppers, lowers: lowers) {
                print("random method")
                print(uppers)
                print(lowers)
                print("--------------------------------")
                return (uppers, lowers, result.value, result.fractionString)
            } else {
                // If calculation failed (e.g., division by zero), try again
                return generateFraction(level: level, methodCoefficient: methodCoefficient)
            }
        }
        else {
            // Method 2: Work backwards from a nice final fraction
            let finalNum = Int.random(in: 1...100)
            let finalDen = Int.random(in: 1...100)
            
            // Simplify the fraction
            let gcd = Fraction.gcd(finalNum, finalDen)
            let simplifiedNum = finalNum / gcd
            let simplifiedDen = finalDen / gcd
            let sign = Bool.random() ? 1 : -1
            
            var uppers: [Fraction] = []
            var lowers: [Fraction] = []
            
            // Calculate decimal result
            let decimalResult = Double(simplifiedNum * sign) / Double(simplifiedDen)
            
            // Create fraction string
            let fractionString: String
            if simplifiedDen == 1 {
                fractionString = "\(simplifiedNum * sign)"
            } else {
                let signStr = sign < 0 ? "-" : ""
                fractionString = "\(signStr)\(simplifiedNum)/\(simplifiedDen)"
            }

            // Generate the numerator fractions (uppers)
            if upCount > 0 {
                var values: [Int] = []
                var remaining = simplifiedNum
                
                for i in 0..<(upCount - 1) {
                    if remaining > 1 {
                        let value = Int.random(in: 1..<remaining)
                        values.append(value)
                        remaining -= value
                    } else {
                        values.append(0)
                    }
                }
                
                values.append(remaining)
                values.shuffle()
                
                // Create fractions with these values
                for value in values {
                    if value == 0 {
                        let denominator = Int.random(in: denominatorRange.0...denominatorRange.1)
                        uppers.append(Fraction(numerator: 0, denominator: denominator, sign: 1))
                    } else {
                        let denominator = Int.random(in: denominatorRange.0...denominatorRange.1)
                        let sign = Bool.random() ? 1 : -1
                        
                        if sign == -1 && values.count > 1 {
                            if let idx = values.firstIndex(of: value) {
                                for i in 0..<values.count {
                                    if i != idx {
                                        values[i] += 2 * value
                                        break
                                    }
                                }
                            }
                        }
                        
                        let numerator = value * denominator
                        uppers.append(Fraction(numerator: numerator, denominator: denominator, sign: sign))
                    }
                }
            }
            
            // Generate the denominator fractions (lowers)
            if downCount > 0 {
                var values: [Int] = []
                var remaining = simplifiedDen
                
                for i in 0..<(downCount - 1) {
                    if remaining > 1 {
                        let value = Int.random(in: 1..<remaining)
                        values.append(value)
                        remaining -= value
                    } else {
                        values.append(0)
                    }
                }
                
                values.append(remaining)
                values.shuffle()
                
                for value in values {
                    if value == 0 {
                        let denominator = Int.random(in: denominatorRange.0...denominatorRange.1)
                        lowers.append(Fraction(numerator: 0, denominator: denominator, sign: 1))
                    } else {
                        let denominator = Int.random(in: denominatorRange.0...denominatorRange.1)
                        let sign = Bool.random() ? 1 : -1
                        
                        if sign == -1 && values.count > 1 {
                            if let idx = values.firstIndex(of: value) {
                                for i in 0..<values.count {
                                    if i != idx {
                                        values[i] += 2 * value
                                        break
                                    }
                                }
                            }
                        }
                        
                        let numerator = value * denominator
                        lowers.append(Fraction(numerator: numerator, denominator: denominator, sign: sign))
                    }
                }
            }
            
            print("normal method 11")
       
            
            print("int:", decimalResult)
            print(simplifiedNum)
            print(simplifiedDen)
            print(sign)
            print("Fraction string:", fractionString)
            return (uppers, lowers, Double(simplifiedNum), fractionString)
        }
    }
    
    /// Helper function to find LCM of two numbers
    static func lcm(_ a: Int, _ b: Int) -> Int {
        return abs(a * b) / Fraction.gcd(a, b)
    }
    
    /// Helper function to find LCM of multiple numbers
    static func findLCM(_ numbers: [Int]) -> Int {
        if numbers.isEmpty {
            return 1
        }
        var result = numbers[0]
        for num in numbers.dropFirst() {
            result = lcm(result, num)
        }
        return result
    }
    
    /// Calculate the final fraction result
    static func calculateFinalFraction(uppers: [Fraction], lowers: [Fraction]) -> (value: Double, fractionString: String)? {
        // Special case: If we have multiple fractions in the numerator and no fractions in the denominator,
        // this is an addition/subtraction expression
        if uppers.count > 1 && lowers.isEmpty {
            // Find the common denominator for all fractions
            let denominators = uppers.map { $0.denominator }
            let commonDenominator = findLCM(denominators)
            
            // Convert all fractions to the common denominator and sum their numerators
            var numeratorSum = 0
            for fraction in uppers {
                let factor = commonDenominator / fraction.denominator
                numeratorSum += fraction.sign * fraction.numerator * factor
            }
            
            // Create the result fraction
            let resultSign = numeratorSum >= 0 ? 1 : -1
            let resultFraction = Fraction(
                numerator: abs(numeratorSum),
                denominator: commonDenominator,
                sign: resultSign
            ).simplified()
            
            // Calculate decimal value
            let decimalValue = Double(resultFraction.numerator * resultFraction.sign) / Double(resultFraction.denominator)
            
            // Create fraction string
            let fractionString: String
            if resultFraction.denominator == 1 {
                // If denominator is 1, just show the number
                fractionString = "\(resultFraction.numerator * resultFraction.sign)"
            } else {
                // Show as a fraction
                let signStr = resultFraction.sign < 0 ? "-" : ""
                fractionString = "\(signStr)\(resultFraction.numerator)/\(resultFraction.denominator)"
            }
            
            return (decimalValue, fractionString)
        }
        
        // Process upper fractions (numerator of final fraction)
        let upperNum: Int
        let upperDen: Int
        
        if uppers.isEmpty {
            upperNum = 0
            upperDen = 1
        } else {
            // Find LCM of denominators
            let upperDenominators = uppers.map { $0.denominator }
            let upperLCM = findLCM(upperDenominators)
            
            // Convert all fractions to common denominator and add/subtract
            var upperSum = 0
            for fraction in uppers {
                let factor = upperLCM / fraction.denominator
                upperSum += fraction.sign * fraction.numerator * factor
            }
            
            upperNum = upperSum
            upperDen = upperLCM
        }
        
        // Process lower fractions (denominator of final fraction)
        let lowerNum: Int
        let lowerDen: Int
        
        if lowers.isEmpty {
            lowerNum = 1
            lowerDen = 1
        } else {
            // Find LCM of denominators
            let lowerDenominators = lowers.map { $0.denominator }
            let lowerLCM = findLCM(lowerDenominators)
            
            // Convert all fractions to common denominator and add/subtract
            var lowerSum = 0
            for fraction in lowers {
                let factor = lowerLCM / fraction.denominator
                lowerSum += fraction.sign * fraction.numerator * factor
            }
            
            lowerNum = lowerSum
            lowerDen = lowerLCM
        }
        
        // If denominator is zero, return nil
        if lowerNum == 0 {
            return nil
        }
        
        // For division, we need to handle signs carefully
        // 1. Determine the sign of the numerator (upperNum)
        let numeratorSign = upperNum >= 0 ? 1 : -1
        
        // 2. Determine the sign of the denominator (lowerNum)
        let denominatorSign = lowerNum >= 0 ? 1 : -1
        
        // 3. The final sign is the product of the signs
        let finalSign = numeratorSign * denominatorSign
        
        // 4. Calculate the absolute values for the final fraction
        let absUpperNum = abs(upperNum)
        let absUpperDen = abs(upperDen)
        let absLowerNum = abs(lowerNum)
        let absLowerDen = abs(lowerDen)
        
        // 5. Perform the division with absolute values
        let finalNum = absUpperNum * absLowerDen
        let finalDen = absUpperDen * absLowerNum
        
        // Create and simplify the final fraction with the correct sign
        let simplifiedFraction = Fraction(
            numerator: finalNum,
            denominator: finalDen,
            sign: finalSign
        ).simplified()
        
        // Calculate decimal value
        let decimalValue = Double(simplifiedFraction.numerator * simplifiedFraction.sign) / Double(simplifiedFraction.denominator)
        
        // Create fraction string
        let fractionString: String
        if simplifiedFraction.denominator == 1 {
            // If denominator is 1, just show the number
            fractionString = "\(simplifiedFraction.numerator * simplifiedFraction.sign)"
        } else {
            // Show as a fraction
            let signStr = simplifiedFraction.sign < 0 ? "-" : ""
            fractionString = "\(signStr)\(simplifiedFraction.numerator)/\(simplifiedFraction.denominator)"
        }
        
        return (decimalValue, fractionString)
    }
    
    /// Convert a fraction to LaTeX format
    static func fractionToLaTeX(_ fraction: Fraction) -> String {
        if fraction.denominator == 1 {
            return "\(fraction.sign == 1 ? "" : "-")\(fraction.numerator)"
        } else {
            return "\\frac{\(fraction.sign == 1 ? "" : "-")\(fraction.numerator)}{\(fraction.denominator)}"
        }
    }
    
    /// Convert a fraction expression to LaTeX
    static func expressionToLaTeX(uppers: [Fraction], lowers: [Fraction]) -> String {
        // If we have multiple fractions in the numerator, we need to handle them as a combined expression
        if uppers.count > 1 && lowers.isEmpty {
            // First, simplify each fraction
            let simplifiedUppers = uppers.map { $0.simplified() }
            
            // Create the LaTeX for each fraction
            var parts: [String] = []
            
            // Handle the first fraction specially to preserve its sign
            let firstFraction = simplifiedUppers[0]
            parts.append(fractionToLaTeX(firstFraction))
            
            // For subsequent fractions, we'll add them with explicit + or - signs
            for i in 1..<simplifiedUppers.count {
                let fraction = simplifiedUppers[i]
                
                // Create the absolute value LaTeX (without sign)
                let absLatex = fractionToLaTeX(Fraction(
                    numerator: fraction.numerator,
                    denominator: fraction.denominator,
                    sign: 1
                ))
                
                // Add with the appropriate sign
                if fraction.sign == 1 {
                    parts.append("+" + absLatex)
                } else {
                    parts.append("-" + absLatex)
                }
            }
            
            // Join all parts
            return parts.joined()
        }
        
        // Original implementation for single fraction or division
        // Format numerator
        var numeratorLaTeX = ""
        for (index, fraction) in uppers.enumerated() {
            if index > 0 {
                numeratorLaTeX += fraction.sign == 1 ? "+" : "-"
            } else if fraction.sign == -1 {
                numeratorLaTeX += "-"
            }
            
            let absValue = fractionToLaTeX(Fraction(
                numerator: fraction.numerator,
                denominator: fraction.denominator,
                sign: 1
            ))
            
            numeratorLaTeX += absValue
        }
        
        // If there are no upper fractions
        if uppers.isEmpty {
            numeratorLaTeX = "0"
        }
        
        // If there are no lower fractions, just return the numerator
        if lowers.isEmpty {
            return numeratorLaTeX
        }
        
        // Format denominator
        var denominatorLaTeX = ""
        for (index, fraction) in lowers.enumerated() {
            if index > 0 {
                denominatorLaTeX += fraction.sign == 1 ? "+" : "-"
            } else if fraction.sign == -1 {
                denominatorLaTeX += "-"
            }
            
            let absValue = fractionToLaTeX(Fraction(
                numerator: fraction.numerator,
                denominator: fraction.denominator,
                sign: 1
            ))
            
            denominatorLaTeX += absValue
        }
        
        // Final LaTeX
        if lowers.count > 1 || (lowers.count == 1 && lowers[0].denominator > 1) {
            return "\\frac{\(numeratorLaTeX)}{(\(denominatorLaTeX))}"
        } else {
            return "\\frac{\(numeratorLaTeX)}{\(denominatorLaTeX)}"
        }
    }
    
    /// Generate a fraction expression similar to genExp function
    /// - Parameters:
    ///   - level: Difficulty level (1-3)
    ///   - methodCoefficient: Probability of using random generation method
    /// - Returns: Tuple containing LaTeX expression and result as (String, Double)
    static func genFraction(level: Int, methodCoefficient: Double = 0.5) -> (String, Double, String) {
        // Generate the fractions
        let (uppers, lowers, decimalResult, fractionString) = generateFraction(level: level, methodCoefficient: methodCoefficient)
        
        // Convert to LaTeX expression
        let expressionLatex = expressionToLaTeX(uppers: uppers, lowers: lowers)
        
        return (expressionLatex, decimalResult, fractionString)
    }
    
    /// For complete compatibility with genExp, returns LaTeX and numeric value
    /// - Parameters:
    ///   - level: Difficulty level (1-3)
    /// - Returns: Tuple containing LaTeX expression and numeric result (String, Double)
    static func genFractionToDouble(level: Int) -> (String, Double, String) {
        return genFraction(level: level)
    }
    
    /// Get the Fraction object from genExp call
    static func fractionFromGenExp(level: Int) -> (Double, String)? {
        let (_, value, fractionString) = genFraction(level: level)
        return (value, fractionString)
    }
    
    /// Test function to verify fraction evaluation
    static func testFractionEvaluation() {
        // Test the specific example: \frac{\frac{522}{18}}{(\frac{456}{19})}
        let upper = Fraction(numerator: 522, denominator: 18, sign: 1)
        let lower = Fraction(numerator: 456, denominator: 19, sign: 1)
        
        // Create arrays for the calculation
        let uppers = [upper]
        let lowers = [lower]
        
        // Calculate the result
        if let result = calculateFinalFraction(uppers: uppers, lowers: lowers) {
            print("Test Result:")
            print("Decimal value: \(result.value)")
            print("Fraction string: \(result.fractionString)")
            
            // Verify the calculation manually
            let upperValue = 522.0 / 18.0  // Should be 29.0
            let lowerValue = 456.0 / 19.0  // Should be 24.0
            let expectedValue = upperValue / lowerValue  // Should be 29/24 ≈ 1.208333...
            
            print("Manual calculation:")
            print("Upper value: \(upperValue)")
            print("Lower value: \(lowerValue)")
            print("Expected value: \(expectedValue)")
            
            // Check if the result matches the expected value
            let epsilon = 0.000001
            let isCorrect = abs(result.value - expectedValue) < epsilon
            print("Result is correct: \(isCorrect)")
        } else {
            print("Calculation failed")
        }
    }
    
    /// Test function to verify fraction subtraction
    static func testFractionSubtraction() {
        // Test the specific example: \frac{245}{5}-\frac{320}{16}
        let frac1 = Fraction(numerator: 245, denominator: 5, sign: 1)
        let frac2 = Fraction(numerator: 320, denominator: 16, sign: -1) // Note the negative sign for subtraction
        
        // Create arrays for the calculation
        let fractions = [frac1, frac2]
        
        // Calculate the result manually
        let value1 = Double(frac1.numerator) / Double(frac1.denominator) // Should be 49.0
        let value2 = Double(frac2.numerator) / Double(frac2.denominator) * Double(frac2.sign) // Should be -20.0
        let expectedValue = value1 + value2 // Should be 29.0
        
        print("Manual calculation:")
        print("First fraction: \(value1)")
        print("Second fraction: \(value2)")
        print("Expected value: \(expectedValue)")
        
        // Now let's trace through the calculation as it would happen in our code
        // Find LCM of denominators
        let denominators = fractions.map { $0.denominator }
        let lcm = FractionGenerator.findLCM(denominators)
        print("LCM of denominators: \(lcm)")
        
        // Convert all fractions to common denominator and add/subtract
        var sum = 0
        for fraction in fractions {
            let factor = lcm / fraction.denominator
            let contribution = fraction.sign * fraction.numerator * factor
            print("Converting \(fraction.numerator)/\(fraction.denominator) * \(fraction.sign) to common denominator:")
            print("  Factor: \(factor)")
            print("  Contribution: \(contribution)")
            sum += contribution
        }
        print("Sum with common denominator: \(sum)/\(lcm)")
        
        // Simplify the result
        let gcd = Fraction.gcd(abs(sum), lcm)
        let simplifiedNum = abs(sum) / gcd
        let simplifiedDen = lcm / gcd
        let sign = sum >= 0 ? 1 : -1
        print("GCD: \(gcd)")
        print("Simplified: \(sign * simplifiedNum)/\(simplifiedDen)")
        
        // Calculate decimal value
        let decimalValue = Double(sign * simplifiedNum) / Double(simplifiedDen)
        print("Decimal value: \(decimalValue)")
    }
    
    /// Run the fraction subtraction test
    static func runSubtractionTest() {
        testFractionSubtraction()
    }
    
    /// Test function to verify the specific example provided by the user
    static func testSpecificExample() {
        // Test the specific example: \frac{245}{5}-\frac{320}{16}
        let frac1 = Fraction(numerator: 245, denominator: 5, sign: 1)
        let frac2 = Fraction(numerator: 320, denominator: 16, sign: -1) // Negative for subtraction
        
        // Create arrays for the calculation
        let uppers = [frac1, frac2]
        let lowers: [Fraction] = []
        
        // Calculate the result
        if let result = calculateFinalFraction(uppers: uppers, lowers: lowers) {
            print("Test Result for \\frac{245}{5}-\\frac{320}{16}:")
            print("Decimal value: \(result.value)")
            print("Fraction string: \(result.fractionString)")
            
            // Verify the calculation manually
            let value1 = 245.0 / 5.0  // Should be 49.0
            let value2 = 320.0 / 16.0  // Should be 20.0
            let expectedValue = value1 - value2  // Should be 29.0
            
            print("Manual calculation:")
            print("First fraction: \(value1)")
            print("Second fraction: \(value2)")
            print("Expected value: \(expectedValue)")
            
            // Check if the result matches the expected value
            let epsilon = 0.000001
            let isCorrect = abs(result.value - expectedValue) < epsilon
            print("Result is correct: \(isCorrect)")
            
            // Generate LaTeX
            let latex = expressionToLaTeX(uppers: uppers, lowers: lowers)
            print("LaTeX expression: \(latex)")
        } else {
            print("Calculation failed")
        }
    }
    
    /// Run the specific example test
    static func runSpecificExampleTest() {
        testSpecificExample()
    }
    
    /// Test function to verify negative value handling
    static func testNegativeValues() {
        // Test the expression: -7-2
        let frac1 = Fraction(numerator: 7, denominator: 1, sign: -1) // -7
        let frac2 = Fraction(numerator: 2, denominator: 1, sign: 1) // +2 (positive, but will be subtracted)
        
        // Create arrays for the calculation
        let uppers = [frac1, frac2]
        let lowers: [Fraction] = []
        
        // Calculate the result
        if let result = calculateFinalFraction(uppers: uppers, lowers: []) {
            print("Test Result for -7-2:")
            print("Decimal value: \(result.value)")
            print("Fraction string: \(result.fractionString)")
            
            // Verify the calculation manually
            let expectedValue = -7.0 - 2.0  // Should be -9.0
            
            print("Manual calculation:")
            print("Expected value: \(expectedValue)")
            
            // Check if the result matches the expected value
            let epsilon = 0.000001
            let isCorrect = abs(result.value - expectedValue) < epsilon
            print("Result is correct: \(isCorrect)")
            
            // Generate LaTeX
            let latex = expressionToLaTeX(uppers: uppers, lowers: [])
            print("LaTeX expression: \(latex)")
        } else {
            print("Calculation failed")
        }
        
        // Test with the second fraction having a negative sign
        let frac3 = Fraction(numerator: 7, denominator: 1, sign: -1) // -7
        let frac4 = Fraction(numerator: 2, denominator: 1, sign: -1) // -2 (negative sign)
        
        // Create arrays for the calculation
        let uppers2 = [frac3, frac4]
        
        // Calculate the result
        if let result2 = calculateFinalFraction(uppers: uppers2, lowers: []) {
            print("\nTest Result for -7+(-2):")
            print("Decimal value: \(result2.value)")
            print("Fraction string: \(result2.fractionString)")
            
            // Verify the calculation manually
            let expectedValue2 = -7.0 + (-2.0)  // Should be -9.0
            
            print("Manual calculation:")
            print("Expected value: \(expectedValue2)")
            
            // Check if the result matches the expected value
            let epsilon = 0.000001
            let isCorrect = abs(result2.value - expectedValue2) < epsilon
            print("Result is correct: \(isCorrect)")
            
            // Generate LaTeX
            let latex2 = expressionToLaTeX(uppers: uppers2, lowers: [])
            print("LaTeX expression: \(latex2)")
        } else {
            print("Calculation failed")
        }
    }
    
    /// Run the negative values test
    static func runNegativeValuesTest() {
        testNegativeValues()
    }
    
    /// Run all tests for negative values
    static func runNegativeTests() {
        print("Running negative value tests...")
        testNegativeValues()
        print("Negative value tests completed.")
    }
}

/// Run the fraction evaluation test
func testFractionCalculation() {
    FractionGenerator.testFractionEvaluation()
}

/// Run the fraction subtraction test
func testFractionSubtraction() {
    FractionGenerator.runSubtractionTest()
}

/// Run the specific example test
func testSpecificExample() {
    FractionGenerator.runSpecificExampleTest()
}

