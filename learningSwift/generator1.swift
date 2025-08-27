//
//  generator1.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 24.02.2025.
//

import SwiftUI
import SwiftMath
// Import the ExpressionEvaluator functionality
import Foundation

struct Generator1: View {
    
    @State private var showCard = false
    @State private var score = 0
    @State private var paused = false
    @State var viewID: UUID
    
    let previewFonts = false
    let expressionGenerator = MathExpressionGenerator()
    
    // Parameters for expression generation
    let expressionType: String
    let minRes: Int
    let level: Int
    let pmAllowed: Bool
    let xsAllowed: Bool
    let cfPm: Double
    
    let r20 = MTEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    let z = MTEdgeInsets()
    let back = Color(hue: 0.15, saturation: 0.2, brightness: 0.5)
    let display = MTMathUILabelMode.display
    let text = MTMathUILabelMode.text
    @State private var currentExpression: String
    
    // Multiple answer types
    @State private var intValue: Int?
    @State private var doubleValue: Double?
    @State private var stringValue: String?
    
    @State private var inputValue: String = ""
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
    
    // Add game type property
    let gameType: GameType
    
    // Exit handler
    let onExit: () -> Void

    init(expressionType: String = "basic4op", minRes: Int = 20, level: Int = 1, 
         pmAllowed: Bool = true, xsAllowed: Bool = true, cfPm: Double = 0.5,
         gameType: GameType = .operationsMix,
         onExit: @escaping () -> Void = {}) {
        self.expressionType = expressionType
        self.minRes = minRes
        self.level = level
        self.pmAllowed = pmAllowed
        self.xsAllowed = xsAllowed
        self.cfPm = cfPm
        
        // Initialize constants early
        self.gameType = gameType
        self.onExit = onExit
        
        let cID = UUID()
        _viewID = State(initialValue: cID)
        
        // Create customParams array based on the Python implementation
        let customParams: [Any] = [pmAllowed, xsAllowed, cfPm]
        
        // Generate non-trivial expression (avoid plain single-number prompts)
        let initial = Generator1.generateNonTrivialLatex(expressionType: expressionType,
                                              minRes: minRes,
                                              level: level,
                                              customParams: customParams)
        _currentExpression = State(initialValue: initial.latex)
        _intValue = State(initialValue: initial.result.intValue)
        _doubleValue = State(initialValue: initial.result.doubleValue)
        _stringValue = State(initialValue: initial.result.stringValue)
        print("[FRAC DEBUG] ---- New Problem ---- exprType=\(expressionType)")
        print("[FRAC DEBUG] latex=\(initial.latex)")
        print("[FRAC DEBUG] expectedDouble=\(String(describing: doubleValue)) expectedInt=\(String(describing: intValue)) expectedString=\(String(describing: stringValue))")
        
        // gameType and onExit already initialized above
    }
    
    let left = MTTextAlignment.left
    let right = MTTextAlignment.right
    let center = MTTextAlignment.center
    let bb = Color.clear
    
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

    // Generate until expression is not a trivial single number like "15"
    private static func generateNonTrivialLatex(expressionType: String,
                                         minRes: Int,
                                         level: Int,
                                         customParams: [Any]) -> (latex: String, result: (intValue: Int?, doubleValue: Double?, stringValue: String?)) {
        // Limit attempts to avoid infinite loops
        var attempts = 0
        while attempts < 10 {
            attempts += 1
            let (expAny, result) = genExp(expressionType: expressionType,
                                           minRes: minRes,
                                           customParams: customParams,
                                           level: level)
            let latex: String
            if expressionType == "frac" {
                let (_, _, fractionLatex) = expAny
                latex = fractionLatex
            } else {
                latex = convertToLaTeX(expression: expAny)
            }
            // Trivial if LaTeX is just a plain integer/decimal without ops or variables
            if !isTrivialExpression(latex) {
                return (latex, (result.intValue, result.doubleValue, result.stringValue))
            }
        }
        // Fallback last generation even if trivial
        let (expAny, result) = genExp(expressionType: expressionType,
                                       minRes: minRes,
                                       customParams: customParams,
                                       level: level)
        let latex: String
        if expressionType == "frac" {
            let (_, _, fractionLatex) = expAny
            latex = fractionLatex
        } else {
            latex = convertToLaTeX(expression: expAny)
        }
        return (latex, (result.intValue, result.doubleValue, result.stringValue))
    }

    private static func isTrivialExpression(_ latex: String) -> Bool {
        // Strip LaTeX wrappers and spaces
        let trimmed = latex.replacingOccurrences(of: " ", with: "")
        // Disallow if it contains typical operation characters or variables
        let hasOpsOrVars = trimmed.contains("+") || trimmed.contains("-") || trimmed.contains("×") || trimmed.contains("\\cdot") || trimmed.contains("/") || trimmed.contains("\\frac") || trimmed.contains("x")
        if hasOpsOrVars { return false }
        // If it parses as a pure number, consider it trivial
        return Double(trimmed) != nil
    }
    
    private func resetValues() {
        timer?.invalidate()
        timer = nil // Reset timer
        secondsElapsed = 0
        
        // Create customParams and regenerate ensuring non-trivial
        let customParams: [Any] = [pmAllowed, xsAllowed, cfPm]
        let regenerated = Generator1.generateNonTrivialLatex(expressionType: expressionType,
                                                  minRes: minRes,
                                                  level: level,
                                                  customParams: customParams)
        currentExpression = regenerated.latex
        intValue = regenerated.result.intValue
        doubleValue = regenerated.result.doubleValue
        stringValue = regenerated.result.stringValue
        print("[FRAC DEBUG] ---- Reset Problem ---- exprType=\(expressionType)")
        print("[FRAC DEBUG] latex=\(regenerated.latex)")
        print("[FRAC DEBUG] expectedDouble=\(String(describing: doubleValue)) expectedInt=\(String(describing: intValue)) expectedString=\(String(describing: stringValue))")
        
        inputValue = ""
        isVisible = false
        isVisible2 = false
        qnum = 1
        progstr = ""
        isRunning = true
        rotationAngle = 0
        score = 0
        viewID = UUID() // Generate a new ID to force view refresh
    }
    
    func fancy() -> [DemoText] {
        [
            DemoText(currentExpression, bb, center, z, display, 30)
        ]
    }
    
    let chars =
    """
    \\text{ABCDEFGHIJKLMOPQRSTUVWXYZ} \\\\
    \\text{abcdefghijklmnopqrstuvwxyz 0123456789} \\\\
    \\text{<>?.,+-[]\\{\\}|=\\_()*\\%\\$!@\\#}
    """
    
    func startTimer() {
        rotationAngle += 360 // Rotate continuously
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if isRunning {
                secondsElapsed += 1
            } else {
                timer.invalidate()
            }
        }
    }

    @State private var showQuitConfirm = false
    
    // Enhanced parseFractionInput function that uses ExpressionEvaluator
    private func parseFractionInput(_ input: String) -> Fraction? {
        // Normalize: remove spaces and use dot as decimal separator
        let cleanInput = input
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        
        // Check if it has a slash (fraction format)
        if cleanInput.contains("/") {
            let components = cleanInput.components(separatedBy: "/")
            if components.count == 2, 
               let rawNum = Int(components[0]),
               let rawDen = Int(components[1]), 
               rawDen != 0 {
                // Determine overall sign from both parts (e.g., -2/-3 => positive)
                let sign = (rawNum < 0 ? -1 : 1) * (rawDen < 0 ? -1 : 1)
                let numerator = abs(rawNum)
                let denominator = abs(rawDen)
                return Fraction(numerator: numerator, denominator: denominator, sign: sign).simplified()
            }
            return nil
        } 
        // Check if it's a decimal
        else if cleanInput.contains(".") {
            if let decimalValue = Double(cleanInput) {
                // Convert decimal to fraction
                return decimalToFraction(decimalValue)
            }
            return nil
        }
        // If it's an expression, try to evaluate it using ExpressionEvaluator
        else if cleanInput.contains(where: { "+-*()".contains($0) }) {
            if let result = evaluateExpression(cleanInput) {
                return decimalToFraction(result)
            }
            return nil
        }
        // It's just a regular number (integer)
        else {
            if let number = Int(cleanInput) {
                let sign = number < 0 ? -1 : 1
                return Fraction(
                    numerator: abs(number),
                    denominator: 1,
                    sign: sign
                )
            }
            return nil
        }
    }
    
    // Function to convert decimal to fraction
    private func decimalToFraction(_ decimal: Double) -> Fraction {
        let precision = 0.000001
        var value = abs(decimal)
        var numerator = 0
        var denominator = 1
        var n1 = 1
        var d1 = 0
        var n2 = 0
        var d2 = 1
        var b = value
        
        repeat {
            let a = floor(b)
            let aux = n1
            n1 = Int(a) * n1 + n2
            n2 = aux
            let aux2 = d1
            d1 = Int(a) * d1 + d2
            d2 = aux2
            b = 1/(b - a)
            
            numerator = Int(n1)
            denominator = Int(d1)
            
        } while abs(value - Double(numerator)/Double(denominator)) > precision && b != Double.infinity
        
        let sign = decimal < 0 ? -1 : 1
        
        return Fraction(
            numerator: numerator,
            denominator: denominator,
            sign: sign
        ).simplified()
    }
    
    // Add a convenience function for evaluate
    private func evaluateExpression(_ expression: String) -> Double? {
        do {
            return try ExpressionEvaluator.evaluate(expression)
        } catch {
            print("Error evaluating expression: \(error.localizedDescription)")
            return nil
        }
    }
    
    var body: some View {
        let font = MathFont.latinModernFont
        
        ZStack {
            // Main content
            VStack {
                // Header section
                HStack {
                    // Inline back next to question text
                    Button("<Back") { showQuitConfirm = true }
                        .buttonStyle(.plain)
                        .foregroundColor(.black)
                        .confirmationDialog("Quit game? Your progress won't be saved.", isPresented: $showQuitConfirm, titleVisibility: .visible) {
                            Button("Quit", role: .destructive) { onExit() }
                            Button("Cancel", role: .cancel) {}
                        }
                    // Question number with pause button directly to the right
                    HStack(spacing: 5) {
                        VStack(alignment: .leading) {
                            Text("question")
                                .fontWeight(.thin)
                            Text("\(qnum)/\(totalquestions)")
                                .font(.title)
                        }
                        
                        // Pause button moved right after the VStack
                        Button {
                            paused = !paused
                            print("scoreprinted")
                            print(score)
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
                    
                    // Progress
                    Text("\(progstr)")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    // Pen toggle button
                    Button(action: {
                        drawingEnabled.toggle()
                        if !drawingEnabled {
                            // Clear drawings when exiting drawing mode
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
                    
                    // Timer
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
                
                // Math expression view
                VStack {
                    ForEach(fancy()) { label in
                        MathView(equation: label.s, font: font, textAlignment: label.a, fontSize: label.w, labelMode: label.m, insets: label.i)
                            .background(label.c)
                    }
                }
                .frame(height: 200)
                .frame(maxWidth: 400)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Answer input section - only show when not in drawing mode
                if !drawingEnabled {
                    HStack {
                        TextField((expressionType != "frac" ? "Enter integer": ("Type as 1/5, 0.2, or expressions")) , text: $inputValue)
                            // Use standard keyboard for fractions, number pad for others
                            .keyboardType(expressionType == "frac" ? .default : .numberPad)
                            // For fractions, add a hint text about format
                           
                           
                        .padding()
                        .background(Color.white)
                            .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Button(action: {
                            if expressionType == "frac" {
                                // For fraction expressions, parse the fraction input
                                if let inputFraction = parseFractionInput(inputValue) {
                                    // Normalize numeric comparison to handle cases like -a/-b == a/b
                                    let inputDecimal = Double(inputFraction.numerator * inputFraction.sign) / Double(inputFraction.denominator)
                                    var isCorrect = false
                                    let epsilon = 0.000001
                                    print("[FRAC DEBUG] expected double=\(String(describing: doubleValue)), int=\(String(describing: intValue)), string=\(String(describing: stringValue))")
                                    print("[FRAC DEBUG] user input fraction= \(inputFraction.sign < 0 ? "-" : "")\(inputFraction.numerator)/\(inputFraction.denominator) -> decimal=\(inputDecimal)")
                                    if let expectedString = stringValue { print("[FRAC DEBUG] expectedString raw=\(expectedString)") }
                                    
                                    if let expectedDouble = doubleValue {
                                        let diff = abs(inputDecimal - expectedDouble)
                                        print("[FRAC DEBUG] compare to expectedDouble diff=\(diff)")
                                        if diff < epsilon { isCorrect = true }
                                    } else if let expectedString = stringValue, let expectedFrac = parseFractionInput(expectedString) {
                                        let expectedDec = Double(expectedFrac.numerator * expectedFrac.sign) / Double(expectedFrac.denominator)
                                        let diff = abs(inputDecimal - expectedDec)
                                        print("[FRAC DEBUG] compare to expectedString parsed decimal=\(expectedDec) diff=\(diff)")
                                        if diff < epsilon { isCorrect = true }
                                    } else if let expectedInt = intValue {
                                        let diff = abs(inputDecimal - Double(expectedInt))
                                        print("[FRAC DEBUG] compare to expectedInt diff=\(diff)")
                                        if diff < epsilon { isCorrect = true }
                                    }
                                    
                                    if isCorrect {
                                        isVisible2 = false
                                        isVisible = true
                                        progstr += "✅"
                                        score += 1
                                        print("[FRAC DEBUG] accepted")
                                    } else {
                                        progstr += "❌"
                                        isVisible2 = true
                                        print("[FRAC DEBUG] rejected")
                                    }
                                } else {
                                    // Try to evaluate the input as an expression
                                    if let result = evaluateExpression(inputValue) {
                                        // Check against all possible answer formats
                                        var isCorrect = false
                                        
                                        // Check against double value with small epsilon
                                        if let expectedDouble = doubleValue {
                                            let epsilon = 0.000001
                                            let diff = abs(result - expectedDouble)
                                            print("[FRAC DEBUG] expr compare to expectedDouble diff=\(diff)")
                                            if diff < epsilon {
                                                isCorrect = true
                                            }
                                        }
                                        
                                        // Check against integer value (if it's a whole number)
                                        if let expectedInt = intValue {
                                            let diff = abs(result - Double(expectedInt))
                                            print("[FRAC DEBUG] expr compare to expectedInt diff=\(diff)")
                                            if diff < 0.000001 {
                                                isCorrect = true
                                            }
                                        }
                                        
                                        if let expectedString = stringValue, let expectedFrac = parseFractionInput(expectedString) {
                                            let expectedDec = Double(expectedFrac.numerator * expectedFrac.sign) / Double(expectedFrac.denominator)
                                            let diff = abs(result - expectedDec)
                                            print("[FRAC DEBUG] expr compare to expectedString parsed decimal=\(expectedDec) diff=\(diff)")
                                            if diff < 0.000001 { isCorrect = true }
                                        }
                                        
                                        if isCorrect {
                                            isVisible2 = false
                                            isVisible = true
                                            progstr += "✅"
                                            score += 1
                                            print("[FRAC DEBUG] expr accepted")
                                        } else {
                                            progstr += "❌"
                                            isVisible2 = true
                                            print("[FRAC DEBUG] expr rejected")
                                        }
                                    } else {
                                        // Invalid expression
                                        progstr += "❌"
                                        isVisible2 = true
                                        print("[FRAC DEBUG] invalid expression parse")
                                    }
                                }
                            } else {
                                
                                print("intval???")
                                print(intValue)
                                // For non-fraction expressions, check against integer value first
                                if let inputNum = Int(inputValue), let expectedInt = intValue, inputNum == expectedInt {
                                    isVisible2 = false
                                    isVisible = true
                                    progstr += "✅"
                                    score += 1
                                } else if let inputDouble = Double(inputValue), let expectedDouble = doubleValue {
                                    // Try as a double with small epsilon
                                    let epsilon = 0.000001
                                    if abs(inputDouble - expectedDouble) < epsilon {
                            isVisible2 = false
                            isVisible = true
                            progstr += "✅"
                            score += 1
                        } else {
                            progstr += "❌"
                            isVisible2 = true
                                    }
                                } else {
                                    progstr += "❌"
                                    isVisible2 = true
                                }
                        }
                        
                        if (qnum != totalquestions) {
                                // Create customParams array based on the Python implementation
                                let customParams: [Any] = [pmAllowed, xsAllowed, cfPm]
                                
                                // Regenerate ensuring non-trivial expression
                                let nonTrivial = Generator1.generateNonTrivialLatex(expressionType: expressionType,
                                                                         minRes: minRes,
                                                                         level: level,
                                                                         customParams: customParams)
                                
                                // Atomically update expression and expected values
                                currentExpression = nonTrivial.latex
                                intValue = nonTrivial.result.intValue
                                doubleValue = nonTrivial.result.doubleValue
                                stringValue = nonTrivial.result.stringValue
                                // Debug: new expression generated
                                // print("newexp")
                                // print(currentExpression)
                                
                                
                                
                            inputValue = ""
                            qnum += 1
                        } else {
                            withAnimation {
                                showCard.toggle()
                            }
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
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
                .frame(height: 60) // Fixed height for feedback area
                } else {
                    // Drawing mode controls
                    HStack {
                        Button(action: {
                            lines = []  // Clear all drawings
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
                            lines = []  // Clear drawings when exiting
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
                    
                    // Extra space where the input field and feedback would be
                    Spacer()
                        .frame(height: 60)
                }
            }
            .id(viewID)
            .padding()
            .opacity(drawingEnabled ? 0.5 : 1.0) // Dim instead of disable when drawing
            
            // Drawing canvas overlay
            if drawingEnabled {
                DrawingCanvas(currentLine: $currentLine, lines: $lines, drawingEnabled: $drawingEnabled)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.7))
                    .transition(.opacity)
                    .zIndex(10) // Ensure it's on top
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
                    .zIndex(20) // Above drawing layer
            }
        }
        .onChange(of: drawingEnabled) { newValue in
            // Clear lines when disabling drawing mode
            if !newValue {
                lines = []
            }
        }
    }
}

// Drawing data structures
struct Line: Identifiable {
    var points: [CGPoint] = []
    var color: Color = .red
    var lineWidth: CGFloat = 3
    let id = UUID()
}

// Updated drawing canvas view that works better on simulator and devices
struct DrawingCanvas: View {
    @Binding var currentLine: Line
    @Binding var lines: [Line]
    @Binding var drawingEnabled: Bool
    
    var body: some View {
        ZStack {
            // Clear background to capture all touch events
            Color.white.opacity(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Drawing canvas
            Path { path in
                // Draw all existing lines
                for line in lines {
                    if let firstPoint = line.points.first {
                        path.move(to: firstPoint)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                
                // Draw the current line
                if let firstPoint = currentLine.points.first {
                    path.move(to: firstPoint)
                    for point in currentLine.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(Color.red, lineWidth: 3)
            
            // Controls for drawing mode
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        lines = []  // Clear all drawings
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        drawingEnabled = false
                        lines = []  // Clear drawings when exiting
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
            }
        }
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    let newPoint = value.location
                    
                    // If this is a new line, start it
                    if currentLine.points.isEmpty {
                        currentLine.points = [newPoint]
                        lines.append(currentLine)
                    } else {
                        // Otherwise append to the current line
                        currentLine.points.append(newPoint)
                        
                        // Update the copy in the lines array
                        if let index = lines.indices.last {
                            lines[index].points = currentLine.points
                        }
                    }
                }
                .onEnded { _ in
                    // Create a new line instance for the next drag
                    currentLine = Line()
                }
        )
        .contentShape(Rectangle()) // Make sure the entire area can receive gestures
    }
}

#Preview {
    Generator1()
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
