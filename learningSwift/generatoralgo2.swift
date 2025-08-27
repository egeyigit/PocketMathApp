//
//  generatoralgo2.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 1.03.2025.
//

import Foundation
import SwiftUI


func separateAddMinus(total: Int, r: Int, mmin: Int, mmax: Int, pmin: Int, pmax: Int) -> ([Int], [Int], String) {
    let plusc = Int.random(in: pmin...pmax)
    print(plusc)
    let minusc = Int.random(in: mmin...mmax)
    print(minusc)
    
    let surplus = Int.random(in: 1...r)
    let plustot = total + surplus
    let minustot = surplus
    
    var plusselection: [Int] = []
    var minusselection: [Int] = []
    
    var plusf: [Int] = []
    var minusf: [Int] = []
    
    if plusc == 1 {
        plusselection.append(plustot)
    } else {
        for _ in 0..<(plusc-1) {
            let a = Int.random(in: 1...plustot)
            if !plusselection.contains(a) {
                plusselection.append(a)
            }
        }
    }
    
    if minusc == 1 {
        minusselection.append(minustot)
    } else {
        for _ in 0..<(minusc-1) {
            let a = Int.random(in: 1...minustot)
            if !minusselection.contains(a) {
                minusselection.append(a)
            }
        }
    }
    
    minusselection.sort(by: >)
    plusselection.sort(by: >)
    
    if plusselection.count > 1 {
        var last = plustot
        for i in 0..<plusselection.count {
            plusf.append(last - plusselection[i])
            last = plusselection[i]
        }
        plusf.append(last)
    } else {
        plusf.append(plustot)
    }
    
    if minusselection.count > 1 {
        var last = minustot
        for i in 0..<minusselection.count {
            minusf.append(last - minusselection[i])
            last = minusselection[i]
        }
        minusf.append(last)
    } else {
        minusf.append(minustot)
    }
    
    print(minusselection, plusselection)
    print("    ------    ")
    print(minusf, plusf)
    
    return (plusf, minusf, "-")
}

func gcd(_ a: Int, _ b: Int) -> Int {
    var a = a
    var b = b
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}

func generateFraction(value: Int, maxVal: Int) -> (numerator: Int, denominator: Int) {
    // Choose a denominator between 2 and maxVal
    let denominator = Int.random(in: 2...maxVal)
    
    // Calculate the numerator
    let numerator = value * denominator
    
    return (numerator, denominator)
}

func getAllFactors(of n: Int) -> [Int] {
    var factors: [Int] = []
    let sqrtN = Int(sqrt(Double(n)))
    
    for i in 1...sqrtN {
        if n % i == 0 {
            factors.append(i)
            if i != n / i {
                factors.append(n / i)
            }
        }
    }
    
    return factors.sorted()
}

func separateDivMult(total: Int, maxfactor: Int, minop: Int, maxop: Int) -> ([Int], [Int], String) {
    // Get all factors (not just prime) of the total
    var factors = getAllFactors(of: total)
    factors = factors.filter { $0 > 1 } // Remove 1 from factors
    
    // If no factors (prime number), we'll work with the number itself
    if factors.isEmpty {
        factors = [total]
    }
    
    // Decide on the number of operands (within min and max constraints)
    var numOperands = Int.random(in: minop...maxop)
    
    // Make sure we have enough factors
    numOperands = min(numOperands, factors.count)
    
    // Select factors whose product equals the total
    var operands = [total]
    for _ in 0..<(numOperands - 1) {
        if operands.isEmpty {
            break
        }
        
        // Pick an operand to split
        let idx = Int.random(in: 0..<operands.count)
        let current = operands.remove(at: idx)
        
        // Find its factors
        let currFactors = factors.filter { current % $0 == 0 && $0 != current }
        
        if currFactors.isEmpty {
            // If no factors, put it back and try another
            operands.append(current)
            continue
        }
        
        // Choose a factor
        let factor = currFactors.randomElement()!
        operands.append(factor)
        operands.append(current / factor)
    }
    
    // Now decide which operands to express as fractions
    let fractionCount = Int.random(in: 0...operands.count)
    var fractionIndices: [Int] = []
    if fractionCount > 0 {
        fractionIndices = Array(Array(0..<operands.count).shuffled().prefix(fractionCount))
    }
    // Create the expression
    var expressionParts: [[String: Any]] = []
    
    for i in 0..<operands.count {
        if fractionIndices.contains(i) {
            // Express this operand as a fraction
            let (numerator, denominator) = generateFraction(value: operands[i], maxVal: maxfactor)
            expressionParts.append([
                "type": "fraction",
                "value": operands[i],
                "numerator": numerator,
                "denominator": denominator
            ])
        } else {
            // Keep as a regular number
            expressionParts.append([
                "type": "number",
                "value": operands[i]
            ])
        }
    }
    
    // Verify the expression
    var product = 1
    for part in expressionParts {
        product *= part["value"] as! Int
    }
    
    // Format for printing
    var expressionStr = ""
    
    var numerators: [Int] = []
    var denoms: [Int] = []
    
    for (i, part) in expressionParts.enumerated() {
        if i > 0 {
            expressionStr += " × "
        }
        
        if part["type"] as! String == "fraction" {
            denoms.append(part["denominator"] as! Int)
            numerators.append(part["numerator"] as! Int)
            expressionStr += "(\(part["numerator"]!)/\(part["denominator"]!))"
        } else {
            expressionStr += "\(part["value"]!)"
            numerators.append(part["value"] as! Int)
        }
    }
    
    print("Expression: \(expressionStr) = \(product)")
    print(expressionParts)
    
    return  (numerators, denoms, "/")
}

func genExp(expressionType: String, minRes: Int, customParams: [Any], level: Int) -> (([Int], [Int], String), (intValue: Int?, doubleValue: Double?, stringValue: String?)) {
    if expressionType == "sqrt" {
        // Not implemented
        return (([0], [0], "0"), (0, nil, nil))
    }
    if expressionType == "square" {
        // Not implemented
        return (([0], [0], "0"), (0, nil, nil))
    }
    if expressionType == "exp" {
        // Not implemented
        return (([0], [0], "0"), (0, nil, nil))
    }
    
    if expressionType == "frac" {
        // Get difficulty params
        let level = min(max(level, 1), 3) // Ensure level is between 1-3
        let methodCoefficient = customParams.count > 2 ? (customParams[2] as? Double ?? 0.5) : 0.5
        
        // Use FractionGenerator to generate the fraction problem
        let (latex, decimalValue, fractionString) = FractionGenerator.genFraction(level: level, methodCoefficient: methodCoefficient)
        print("[FRAC DEBUG] genExp(frac) -> latex=\(latex) decimal=\(decimalValue) fraction=\(fractionString)")
        
        // Create a result tuple that matches the expected return format
        let numerators = [1] // Placeholder, not used in UI
        let denominators = [1] // Placeholder, not used in UI
        
        // Check if the decimal value is a whole number
        let intValue: Int?
        if decimalValue.truncatingRemainder(dividingBy: 1) == 0 {
            intValue = Int(decimalValue)
        } else {
            intValue = nil
        }
        
        // Return the expression tuple and all possible answer formats
        let resultTuple = (intValue, decimalValue, fractionString)
        print("[FRAC DEBUG] result tuple -> int=\(String(describing: resultTuple.0)) double=\(resultTuple.1) string=\(resultTuple.2)")
        return ((numerators, denominators, latex), resultTuple)
    }
    if expressionType == "log" {
        // Not implemented
        return (([0], [0], "0"), (0, nil, nil))
    }
    
    if expressionType == "basic4op" {
        // parameters = [plusAllowed, multdivAllowed, cfPm]
        let pmAllowed = customParams[0] as! Bool
        let xsAllowed = customParams[1] as! Bool
        let cfPm = customParams[2] as! Double
        
        // Calculate resultMax based on level
        let resultMax: Int
        var maxAddNum: Int
        
        if level == 1 {
            resultMax = 100
            maxAddNum = 50
        } else if level == 2 {
            resultMax = 500
            maxAddNum = 250
        } else {
            resultMax = 1000
            maxAddNum = 500
        }
        
        let resultNum = Int.random(in: minRes...resultMax)
        
        var exp: ([Int], [Int], String)
        // Determine min/max values for operations based on level
        let minusMin = level == 1 ? 1 : (level == 2 ? 1 : 1)
        let minusMax = level == 1 ? 3 : (level == 2 ? 3 : 3)
        let plusMin = level == 1 ? 1 : (level == 2 ? 1 : 1)
        let plusMax = level == 1 ? 3 : (level == 2 ? 3 : 2)
        

        if xsAllowed && pmAllowed {
            if Double.random(in: 0...1) < cfPm {
                exp = separateAddMinus(total: resultNum, r: maxAddNum, 
                                      mmin: minusMin, mmax: minusMax, 
                                      pmin: plusMin, pmax: plusMax)
            } else {
                let result = separateDivMult(total: resultNum, maxfactor: 50, minop: 2, maxop: level + 4)
                exp = result
            }
        } else if xsAllowed && !pmAllowed {
            let result = separateDivMult(total: resultNum, maxfactor: 50, minop: 2, maxop: level + 4)
            exp = result
        } else {
            exp = separateAddMinus(total: resultNum, r: maxAddNum, 
                                  mmin: minusMin, mmax: minusMax, 
                                  pmin: plusMin, pmax: plusMax)
        }
        
        print("returned")
        // For basic operations, return the integer result and also as a double
        return (exp, (resultNum, Double(resultNum), String(resultNum)))
    }
    
    return (([1], [2], "0"), (2, 2.0, "2")) // Default empty return
}

// Function to convert the array to LaTeX format
func convertToLaTeX(expression: ([Int], [Int], String)) -> String {
    let (numerators, denominators, operationType) = expression
    
    var latexExpression = ""
    
    if operationType == "-" {
        // Addition/subtraction expression
        if numerators.isEmpty {
            return "0"
        }
        
        for (index, num) in numerators.enumerated() {
            if index == 0 {
                latexExpression += "\(num)"
            } else {
                latexExpression += " + \(num)"
            }
        }
        
        // Subtract the denominators (minus values)
        for denominator in denominators where denominator > 0 {
            latexExpression += " - \(denominator)"
        }
    } else if operationType == "/" {
        // Multiplication/division expression
        if numerators.isEmpty {
            return "0"
        }
        
        // Create the numerator part
        let numeratorPart = numerators.map { "\($0)" }.joined(separator: " \\cdot ")
        
        // If there are denominators, create a fraction
        if !denominators.isEmpty && denominators.first! > 0 {
            let denominatorPart = denominators.map { "\($0)" }.joined(separator: " \\cdot ")
            latexExpression = "\\frac{\(numeratorPart)}{\(denominatorPart)}"
        } else {
            // No denominators, just show the numerator part
            latexExpression = numeratorPart
        }
    }
    
    return latexExpression
}

// Example usage

struct PolynomialQuestionView: View {
    @State private var polynomial1: [Int] = []
    @State private var polynomial2: [Int] = []
    @State private var expandedPolynomial: [Int] = []
    @State private var userInput: String = ""
    @State private var feedback: String = ""

    var body: some View {
        VStack {
            Text("Polynomial Multiplication")
                .font(.largeTitle)
                .padding()

            Text("Expanded Polynomial: \(polynomialToString(expandedPolynomial))")
                .padding()

            TextField("Enter the roots (comma separated)", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Check Roots") {
                checkRoots()
            }
            .padding()

            Text(feedback)
                .padding()
                .foregroundColor(feedback == "Correct!" ? .green : .red)
        }
        .onAppear {
            generatePolynomials()
        }
    }

    func generatePolynomials() {
        polynomial1 = generateLinearPolynomial()
        polynomial2 = generateLinearPolynomial()
        expandedPolynomial = multiplyPolynomials(p1: polynomial1, p2: polynomial2)
    }

    func generateLinearPolynomial() -> [Int] {
        let a = Int.random(in: -10..<10)
        let b = Int.random(in: -10..<10)
        return [a, b] // Represents ax + b
    }

    func multiplyPolynomials(p1: [Int], p2: [Int]) -> [Int] {
        let a1 = p1[0], b1 = p1[1]
        let a2 = p2[0], b2 = p2[1]
        // (a1x + b1)(a2x + b2) = a1a2x^2 + (a1b2 + a2b1)x + b1b2
        let c2 = a1 * a2
        let c1 = a1 * b2 + a2 * b1
        let c0 = b1 * b2
        return [c2, c1, c0]
    }

    func polynomialToString(_ poly: [Int]) -> String {
        var result = ""
        if poly[0] != 0 {
            result += "\(poly[0])x^2 "
        }
        if poly[1] != 0 {
            result += "\(poly[1] >= 0 ? "+" : "")\(poly[1])x "
        }
        if poly[2] != 0 {
            result += "\(poly[2] >= 0 ? "+" : "")\(poly[2])"
        }
        return result
    }

    func checkRoots() {
        // Parse user input and check if they are correct
        let roots = userInput.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        if roots.count == 2 {
            let correctRoots = findRoots(of: expandedPolynomial)
            if Set(roots) == Set(correctRoots) {
                feedback = "Correct!"
            } else {
                feedback = "Incorrect. Try again."
            }
        } else {
            feedback = "Please enter two roots."
        }
    }

    func findRoots(of poly: [Int]) -> [Int] {
        // Assuming the polynomial is in the form ax^2 + bx + c
        let a = poly[0], b = poly[1], c = poly[2]
        let discriminant = b * b - 4 * a * c
        if discriminant >= 0 {
            let root1 = (-b + Int(sqrt(Double(discriminant)))) / (2 * a)
            let root2 = (-b - Int(sqrt(Double(discriminant)))) / (2 * a)
            return [root1, root2]
        }
        return []
    }
}

struct PolynomialQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        PolynomialQuestionView()
    }
}



