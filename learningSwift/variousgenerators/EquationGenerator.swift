//
//  EquationGenerator.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 26.03.2025.
//

import Foundation
import SwiftUI
import SwiftMath

struct EquationGenerator: View {
    @State private var showCard = false
    @State private var score = 0
    @State private var paused = false
    @State var viewID: UUID
    
    // Equation system options
    let equationType: EquationType
    let level: Int
    var gameType: GameType = .equations
    
    // UI state
    @State private var currentEquations: [String] = []
    @State private var currentLatexEquations: String = ""
    @State private var solutions: [String: Double] = [:]
    @State private var inputValues: [String: String] = [:]
    @State private var isVisible = false
    @State private var isVisible2 = false
    @State private var qnum = 1
    @State private var progstr = ""
    @State private var secondsElapsed: Int = 0
    @State private var timer: Timer? = nil
    @State private var isRunning: Bool = true
    @State private var rotationAngle: Double = 0
    let totalquestions: Int = 10
    
    // Drawing related properties
    @State private var drawingEnabled = false
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    
    // MTMath display options
    let r20 = MTEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    let z = MTEdgeInsets()
    let display = MTMathUILabelMode.display
    let text = MTMathUILabelMode.text
    let center = MTTextAlignment.center
    let bb = Color.clear
    
    // Enum for equation type selection
    enum EquationType: String, CaseIterable {
        case oneVariable = "One Variable"
        case twoVariable = "Two Variables"
        case threeVariable = "Three Variables"
    }
    
    init(equationType: EquationType = .oneVariable, level: Int = 1) {
        self.equationType = equationType
        self.level = level
        
        let cID = UUID()
        _viewID = State(initialValue: cID)
        
        // Initialize with default values
        _currentEquations = State(initialValue: [])
        _solutions = State(initialValue: [:])
        _inputValues = State(initialValue: [:])
        
        // Generate initial equation
        let (equations, latex, solutions) = generateEquation(type: equationType, level: level)
        _currentEquations = State(initialValue: equations)
        _currentLatexEquations = State(initialValue: latex)
        _solutions = State(initialValue: solutions)
        
        // Initialize input fields based on the number of variables
        var inputs = [String: String]()
        switch equationType {
        case .oneVariable:
            inputs["x"] = ""
        case .twoVariable:
            inputs["x"] = ""
            inputs["y"] = ""
        case .threeVariable:
            inputs["x"] = ""
            inputs["y"] = ""
            inputs["z"] = ""
        }
        _inputValues = State(initialValue: inputs)
    }
    
    func fancy() -> [DemoText] {
        [
            DemoText(currentLatexEquations, bb, center, z, display, 30)
        ]
    }
    
    struct DemoText : Identifiable {
        let s: String
        let c: Color
        let a: MTTextAlignment
        let i: MTEdgeInsets
        let m: MTMathUILabelMode
        let w: CGFloat
        let id = UUID()
        
        init(_ s: String, _ c: Color = .clear, _ a: MTTextAlignment = .left,
             _ i: MTEdgeInsets = MTEdgeInsets(),
             _ m: MTMathUILabelMode = .display, _ w: CGFloat = 30) {
            self.s = s
            self.c = c
            self.a = a
            self.i = i
            self.m = m
            self.w = w
        }
    }
    
    func generateEquation(type: EquationType, level: Int) -> (equations: [String], latex: String, solutions: [String: Double]) {
        switch type {
        case .oneVariable:
            return generateOneVariableEquation(level: level)
        case .twoVariable:
            return generateTwoVariableSystem(level: level)
        case .threeVariable:
            return generateThreeVariableSystem(level: level)
        }
    }
    
    // Generate one-variable linear equation with more interesting structures
    func generateOneVariableEquation(level: Int) -> (equations: [String], latex: String, solutions: [String: Double]) {
        // Determine complexity based on level
        let maxCoefficient: Int
        let maxConstant: Int
        
        switch level {
        case 1:
            maxCoefficient = 5
            maxConstant = 20
        case 2:
            maxCoefficient = 10
            maxConstant = 50
        case 3:
            maxCoefficient = 20
            maxConstant = 100
        default:
            maxCoefficient = 5
            maxConstant = 20
        }
        
        // Generate a solution first (integer between 1-10 for level 1, larger for higher levels)
        let solution = Double(Int.random(in: 1...(5 * level)))
        
        // Choose a target equalizer number
        let targetNumber = Int.random(in: level...maxConstant)
        
        // Select expression format randomly (0: a(x+b) + c, 1: a(x+b) - c, 2: (ax-b)/c + d)
        let formatType = Int.random(in: 0...2)
        let formatType2 = Int.random(in: 0...3)
        
        // Randomize which side of the equation has the complex expression
        let complexOnLeft = Bool.random()
        
        // Variables for equation parts
        var leftSide = ""
        var rightSide = ""
        
        // Create the equation based on selected format
        switch formatType {
        case 0: // Format: a(x+b) + c = targetNumber
            let a = Int.random(in: 1...maxCoefficient)
            // Calculate b to achieve the solution
            // We know: a(solution+b) + c = targetNumber
            let c = Int.random(in: 1...maxConstant/2) // Pick a random c
            // Solving for b: a(solution+b) = targetNumber - c
            // Therefore: b = (targetNumber - c)/a - solution
            let b = Int((Double(targetNumber - c) / Double(a)) - solution)
            
            let expression = "\(a)(x\(b >= 0 ? "+" : "")\(b)) \(c >= 0 ? "+" : "")\(c)"
            leftSide = expression
            
            
            
        case 1: // Format: a(x+b) - c = targetNumber
            let a = Int.random(in: 1...maxCoefficient)
            // Calculate b to achieve the solution
            // We know: a(solution+b) - c = targetNumber
            let c = Int.random(in: 1...maxConstant/2) // Pick a random c
            // Solving for b: a(solution+b) = targetNumber + c
            // Therefore: b = (targetNumber + c)/a - solution
            let b = Int((Double(targetNumber + c) / Double(a)) - solution)
            
            let expression = "\(a)(x\(b >= 0 ? "+" : "")\(b)) - \(c)"
            leftSide = expression
            
        case 2: // Format: (ax-b)/c + d = targetNumber
            let a = Int.random(in: 1...maxCoefficient)
            let c = Int.random(in: 2...maxCoefficient) // Avoid division by 1 for more complexity
            let d = Int.random(in: 1...maxConstant/3) // Pick a random d
            
            // Break down the complex calculation into simpler steps
            let targetMinusD = targetNumber - d
            let cMultiplied = Double(c) * Double(targetMinusD)
            let aSolution = a * Int(solution)
            let b = Int(aSolution) - Int(cMultiplied)
            
            let expression = "\\frac{" + "\(a)x - \(b)" + "}{" + "\(c)" + "} \(d >= 0 ? "+" : "")\(d)"
            leftSide = expression
            
        default:
            // Should never happen, but fallback
            leftSide = "x"
            rightSide = "\(Int(solution))"
        }
        
        switch formatType2 {
        case 0: // Format: a(x+b) + c = targetNumber
            let a = Int.random(in: 1...maxCoefficient)
            // Calculate b to achieve the solution
            // We know: a(solution+b) + c = targetNumber
            let c = Int.random(in: 1...maxConstant/2) // Pick a random c
            // Solving for b: a(solution+b) = targetNumber - c
            // Therefore: b = (targetNumber - c)/a - solution
            let b = Int((Double(targetNumber - c) / Double(a)) - solution)
            
            let expression = "\(a)(x\(b >= 0 ? "+" : "")\(b)) \(c >= 0 ? "+" : "")\(c)"
            rightSide = expression
            
        case 1: // Format: a(x+b) - c = targetNumber
            let a = Int.random(in: 1...maxCoefficient)
            // Calculate b to achieve the solution
            // We know: a(solution+b) - c = targetNumber
            let c = Int.random(in: 1...maxConstant/2) // Pick a random c
            // Solving for b: a(solution+b) = targetNumber + c
            // Therefore: b = (targetNumber + c)/a - solution
            let b = Int((Double(targetNumber + c) / Double(a)) - solution)
            
            let expression = "\(a)(x\(b >= 0 ? "+" : "")\(b)) - \(c)"
            rightSide = expression
            
        case 2: // Format: (ax-b)/c + d = targetNumber
            let a = Int.random(in: 1...maxCoefficient)
            let c = Int.random(in: 2...maxCoefficient) // Avoid division by 1 for more complexity
            let d = Int.random(in: 1...maxConstant/3) // Pick a random d
            
            // Break down the complex calculation into simpler steps
            let targetMinusD = targetNumber - d
            let cMultiplied = Double(c) * Double(targetMinusD)
            let aSolution = a * Int(solution)
            let b = Int(aSolution) - Int(cMultiplied)
            
            let expression = "\\frac{" + "\(a)x - \(b)" + "}{" + "\(c)" + "} \(d >= 0 ? "+" : "")\(d)"
            rightSide = expression
            
        case 3:
            rightSide = "\(Int(targetNumber))"
        default:
            // Should never happen, but fallback
            leftSide = "x"
            rightSide = "\(Int(solution))"
        }

        
        let equationString = "\(leftSide) = \(rightSide)"
        print(equationString)
        // Convert to LaTeX format
        let latexEquation = equationString
        
        return (equations: [equationString], latex: latexEquation, solutions: ["x": solution])
    }
    
    // Generate system of two-variable linear equations
    func generateTwoVariableSystem(level: Int) -> (equations: [String], latex: String, solutions: [String: Double]) {
        // Determine complexity based on level
        let maxCoefficient: Int
        let maxConstant: Int
        
        switch level {
        case 1:
            maxCoefficient = 5
            maxConstant = 20
        case 2:
            maxCoefficient = 10
            maxConstant = 50
        case 3:
            maxCoefficient = 15
            maxConstant = 100
        default:
            maxCoefficient = 5
            maxConstant = 20
        }
        
        // Choose integer solutions
        let xSolution = Double(Int.random(in: 1...(5 * level)))
        let ySolution = Double(Int.random(in: 1...(5 * level)))
        
        // Generate coefficients for the first equation: ax + by = c
        let a1 = Int.random(in: 1...maxCoefficient)
        let b1 = Int.random(in: level == 1 ? 1...maxCoefficient : -maxCoefficient...maxCoefficient)

        // Break down the complex calculation
        let a1x = a1 * Int(xSolution)
        let b1y = b1 * Int(ySolution)
        let c1 = Int(a1x + b1y)
        
        // Generate coefficients for the second equation: dx + ey = f
        var a2 = Int.random(in: 1...maxCoefficient)
        var b2 = Int.random(in: level == 1 ? 1...maxCoefficient : -maxCoefficient...maxCoefficient)
        
        // Ensure the system has a unique solution (different slopes)
        while a1 * b2 == a2 * b1 {
            a2 = Int.random(in: 1...maxCoefficient)
            b2 = Int.random(in: level == 1 ? 1...maxCoefficient : -maxCoefficient...maxCoefficient)
        }

        // Break down the complex calculation
        let a2x = a2 * Int(xSolution)
        let b2y = b2 * Int(ySolution)
        let c2 = Int(a2x + b2y)
        
        // Create equation strings
        let equation1 = "\(a1)x \(b1 >= 0 ? "+" : "")\(b1)y = \(c1)"
        let equation2 = "\(a2)x \(b2 >= 0 ? "+" : "")\(b2)y = \(c2)"
        
        // Convert to LaTeX format
        let latexSystem = "\\begin{cases} " + equation1 + " \\\\ " + equation2 + " \\end{cases}"
        
        return (equations: [equation1, equation2], latex: latexSystem, solutions: ["x": xSolution, "y": ySolution])
    }
    
    // Generate system of three-variable linear equations
    func generateThreeVariableSystem(level: Int) -> (equations: [String], latex: String, solutions: [String: Double]) {
        // Determine complexity based on level
        let maxCoefficient: Int
        let maxConstant: Int
        
        switch level {
        case 1:
            maxCoefficient = 3
            maxConstant = 10
        case 2:
            maxCoefficient = 5
            maxConstant = 25
        case 3:
            maxCoefficient = 8
            maxConstant = 50
        default:
            maxCoefficient = 3
            maxConstant = 10
        }
        
        // Choose integer solutions for simplicity
        let xSolution = Double(Int.random(in: 1...(3 * level)))
        let ySolution = Double(Int.random(in: 1...(3 * level)))
        let zSolution = Double(Int.random(in: 1...(3 * level)))
        
        // Generate three equations with guaranteed unique solution
        let a1 = Int.random(in: 1...maxCoefficient)
        let b1 = Int.random(in: level == 1 ? 0...maxCoefficient : -maxCoefficient...maxCoefficient)
        let c1 = Int.random(in: level == 1 ? 0...maxCoefficient : -maxCoefficient...maxCoefficient)

        // Break down the complex calculation
        let a1x3 = a1 * Int(xSolution)
        let b1y3 = b1 * Int( ySolution)
        let c1z = c1 * Int(zSolution)
        let d1 = Int(a1x3 + b1y3 + c1z)
        
        let a2 = Int.random(in: 1...maxCoefficient)
        let b2 = Int.random(in: 1...maxCoefficient) // Ensure non-zero
        let c2 = Int.random(in: level == 1 ? 0...maxCoefficient : -maxCoefficient...maxCoefficient)

        // Break down the complex calculation
        let a2x3 = a2 * Int(xSolution)
        let b2y3 = b2 * Int(ySolution)
        let c2z = c2 * Int(zSolution)
        let d2 = Int(a2x3 + b2y3 + c2z)
        
        let a3 = Int.random(in: 1...maxCoefficient)
        let b3 = Int.random(in: level == 1 ? 0...maxCoefficient : -maxCoefficient...maxCoefficient)
        let c3 = Int.random(in: 1...maxCoefficient) // Ensure non-zero

        // Break down the complex calculation
        let a3x3 = a3 * Int(xSolution)
        let b3y3 = b3 * Int(ySolution)
        let c3z = c3 * Int(zSolution)
        let d3 = Int(a3x3 + b3y3 + c3z)
        
        // Create equation strings
        let equation1 = "\(a1)x \(b1 >= 0 ? "+" : "")\(b1)y \(c1 >= 0 ? "+" : "")\(c1)z = \(d1)"
        let equation2 = "\(a2)x \(b2 >= 0 ? "+" : "")\(b2)y \(c2 >= 0 ? "+" : "")\(c2)z = \(d2)"
        let equation3 = "\(a3)x \(b3 >= 0 ? "+" : "")\(b3)y \(c3 >= 0 ? "+" : "")\(c3)z = \(d3)"
        
        // Convert to LaTeX format
        let latexSystem = "\\begin{cases} " + equation1 + " \\\\ " + equation2 + " \\\\ " + equation3 + " \\end{cases}"
        
        return (equations: [equation1, equation2, equation3], latex: latexSystem, solutions: ["x": xSolution, "y": ySolution, "z": zSolution])
    }
    
    // Convert equation to LaTeX format
    func convertToLatex(equation: String) -> String {
        // Basic conversion 
        return equation
            .replacingOccurrences(of: "x", with: "x")
            .replacingOccurrences(of: "y", with: "y")
            .replacingOccurrences(of: "z", with: "z")
    }
    
    private func checkAnswer() -> Bool {
        var allCorrect = true
        
        for (variable, expectedValue) in solutions {
            if let inputText = inputValues[variable], let inputValue = Double(inputText) {
                // Check if the input is within a small epsilon of the expected value
                let epsilon = 0.001
                if abs(inputValue - expectedValue) > epsilon {
                    allCorrect = false
                    break
                }
            } else {
                // Invalid input
                allCorrect = false
                break
            }
        }
        
        return allCorrect
    }
    
    private func resetValues() {
        timer?.invalidate()
        timer = nil
        secondsElapsed = 0
        
        let (equations, latex, newSolutions) = generateEquation(type: equationType, level: level)
        currentEquations = equations
        currentLatexEquations = latex
        solutions = newSolutions
        
        // Reset input values
        var newInputs = [String: String]()
        for key in solutions.keys {
            newInputs[key] = ""
        }
        inputValues = newInputs
        
        isVisible = false
        isVisible2 = false
        qnum = 1
        progstr = ""
        isRunning = true
        rotationAngle = 0
        score = 0
        viewID = UUID()
    }
    
    func startTimer() {
        rotationAngle += 360
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if isRunning {
                secondsElapsed += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    var body: some View {
        let font = MathFont.latinModernFont
        
        ZStack {
            // Main content
            VStack {
                // Header section
                HStack {
                    HStack(spacing: 5) {
                        VStack(alignment: .leading) {
                            Text("question")
                                .fontWeight(.thin)
                            Text("\(qnum)/\(totalquestions)")
                                .font(.title)
                        }
                        
                        Button {
                            paused = !paused
                        } label: {
                            if paused {
                                Image(systemName: "play")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.black)
                            } else {
                                Image(systemName: "pause.rectangle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.leading, 5)
                    }
                    
                    Spacer()
                    
                    Text("\(progstr)")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button(action: {
                        drawingEnabled.toggle()
                        if !drawingEnabled {
                            lines = []
                        }
                    }) {
                        Image(systemName: drawingEnabled ? "pencil.slash" : "pencil")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(drawingEnabled ? .red : .black)
                    }
                    .padding(.trailing, 8)
                    
                    HStack {
                        Text("\(secondsElapsed)")
                            .font(.title2)
                        Image(systemName: "gauge.with.needle")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: rotationAngle)
                            .onAppear {
                                startTimer()
                            }
                    }
                }
                
                // Equation display
                VStack {
                    Text("Solve the equation\(currentEquations.count > 1 ? "s" : "")")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(fancy()) { label in
                        MathView(equation: label.s, font: font, textAlignment: label.a, fontSize: label.w, labelMode: label.m, insets: label.i)
                            .background(label.c)
                    }
                    
                    if level > 1 {
                        Text("Find the values to 2 decimal places if needed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                }
                .frame(height: 200)
                .frame(maxWidth: 400)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                if !drawingEnabled {
                    // Input fields for variables
                    VStack(spacing: 15) {
                        ForEach(solutions.keys.sorted(), id: \.self) { variable in
                            HStack {
                                Text(variable + " =")
                                    .font(.headline)
                                    .frame(width: 50, alignment: .trailing)
                                
                                TextField("Enter value", text: Binding(
                                    get: { self.inputValues[variable] ?? "" },
                                    set: { self.inputValues[variable] = $0 }
                                ))
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            }
                        }
                        
                        Button(action: {
                            let isCorrect = checkAnswer()
                            
                            if isCorrect {
                                isVisible2 = false
                                isVisible = true
                                progstr += "✅"
                                score += 1
                            } else {
                                progstr += "❌"
                                isVisible2 = true
                            }
                            
                            if qnum != totalquestions {
                                let (newEquations, newLatex, newSolutions) = generateEquation(type: equationType, level: level)
                                currentEquations = newEquations
                                currentLatexEquations = newLatex
                                solutions = newSolutions
                                
                                // Reset input values
                                var newInputs = [String: String]()
                                for key in solutions.keys {
                                    newInputs[key] = ""
                                }
                                inputValues = newInputs
                                
                                qnum += 1
                            } else {
                                withAnimation {
                                    showCard.toggle()
                                }
                            }
                        }) {
                            Text("Check Answer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)
                    
                    // Feedback messages
                    ZStack {
                        if isVisible {
                            Text("Correct")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .opacity(isVisible ? 1 : 0)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .onAppear {
                                    withAnimation(.easeOut(duration: 1)) {
                                        isVisible = false
                                    }
                                }
                        }
                        if isVisible2 {
                            Text("Wrong")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                                .opacity(isVisible2 ? 1 : 0)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .onAppear {
                                    withAnimation(.easeOut(duration: 1)) {
                                        isVisible2 = false
                                    }
                                }
                        }
                    }
                    .frame(height: 60)
                } else {
                    // Drawing mode controls
                    HStack {
                        Button(action: {
                            lines = []
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            drawingEnabled = false
                            lines = []
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Done")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
            .id(viewID)
            .padding()
            .opacity(drawingEnabled ? 0.5 : 1.0)
            
            // Drawing canvas overlay
            if drawingEnabled {
                DrawingCanvas(currentLine: $currentLine, lines: $lines, drawingEnabled: $drawingEnabled)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.7))
                    .transition(.opacity)
                    .zIndex(10)
            }
            
            // Overlay cards
            if showCard {
                LevelEndCard(
                    score: $score,
                    showCard: $showCard,
                    viewID: $viewID,
                    onPlayAgain: resetValues,
                    gameType: gameType,
                    difficulty: level,
                    timeElapsed: secondsElapsed
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(20)
            }
            
            if paused {
                pausemenu(score: $score, paused: $paused)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(20)
            }
        }
        .onChange(of: drawingEnabled) { newValue in
            if !newValue {
                lines = []
            }
        }
    }
}

struct EquationGenerator_Previews: PreviewProvider {
    static var previews: some View {
        EquationGenerator(equationType: .twoVariable, level: 2)
    }
}
