//
//  polynomialgenerator.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 1.03.2025.
//

import SwiftUI
import SwiftMath

struct PolynomialGenerator: View {
    
    @State private var showCard = false
    @State private var score = 0
    @State private var paused = false
    @State var viewID: UUID
    
    // Polynomial-specific properties
    @State private var polynomial1: [Int] = []
    @State private var polynomial2: [Int] = []
    @State private var expandedPolynomial: [Int] = []
    @State private var userInput: String = ""
    
    // Level parameters
    let level: Int
    let coefficientRange: Int // Range for polynomial coefficients (-coefficientRange to +coefficientRange)
    
    // UI state variables
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
    
    // Display options
    let r20 = MTEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    let z = MTEdgeInsets()
    let back = Color(hue: 0.15, saturation: 0.2, brightness: 0.5)
    let display = MTMathUILabelMode.display
    let text = MTMathUILabelMode.text
    
    init(level: Int = 1) {
        self.level = level
        
        // Set coefficient range based on level
        switch level {
        case 1:
            self.coefficientRange = 5 // Easy: small numbers
        case 2:
            self.coefficientRange = 8 // Medium
        case 3:
            self.coefficientRange = 10 // Hard: full range -10 to 10
        default:
            self.coefficientRange = 5
        }
        
        let cID = UUID()
        _viewID = State(initialValue: cID)
        
        // Initialize the polynomials with default values
        _polynomial1 = State(initialValue: [])
        _polynomial2 = State(initialValue: [])
        _expandedPolynomial = State(initialValue: [])
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
    
    private func resetValues() {
        timer?.invalidate()
        timer = nil // Reset timer
        secondsElapsed = 0
        
        generatePolynomials()
        
        userInput = ""
        isVisible = false
        isVisible2 = false
        qnum = 1
        progstr = ""
        isRunning = true
        rotationAngle = 0
        score = 0
        viewID = UUID() // Generate a new ID to force view refresh
    }
    
    // Generate linear polynomial with coefficients in range -coefficientRange to +coefficientRange
    func generateLinearPolynomial() -> [Int] {
        var a = Int.random(in: -coefficientRange...coefficientRange)
        var b = Int.random(in: -coefficientRange...coefficientRange)
        
        // Ensure a is not zero (to keep it a linear polynomial)
        if a == 0 {
            a = [1, -1].randomElement()!
        }
        
        return [a, b] // Represents ax + b
    }
    
    func generatePolynomials() {
        polynomial1 = generateLinearPolynomial()
        polynomial2 = generateLinearPolynomial()
        expandedPolynomial = multiplyPolynomials(p1: polynomial1, p2: polynomial2)
        
        // For debugging
        print("Polynomial 1: \(polynomialToString([polynomial1[0], polynomial1[1], 0]))")
        print("Polynomial 2: \(polynomialToString([polynomial2[0], polynomial2[1], 0]))")
        print("Expanded: \(polynomialToString(expandedPolynomial))")
        print("Roots: \(findRoots(of: expandedPolynomial))")
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
        
        // Handle special case of zero polynomial
        if poly.allSatisfy({ $0 == 0 }) {
            return "0"
        }
        
        // Handle x^2 term
        if poly.count > 0 && poly[0] != 0 {
            if poly[0] == 1 {
                result += "x^2"
            } else if poly[0] == -1 {
                result += "-x^2"
            } else {
                result += "\(poly[0])x^2"
            }
        }
        
        // Handle x term
        if poly.count > 1 && poly[1] != 0 {
            if !result.isEmpty {
                result += poly[1] > 0 ? " + " : " "
            }
            
            if poly[1] == 1 {
                result += "x"
            } else if poly[1] == -1 {
                result += "-x"
            } else {
                result += "\(poly[1])x"
            }
        }
        
        // Handle constant term
        if poly.count > 2 && poly[2] != 0 {
            if !result.isEmpty {
                result += poly[2] > 0 ? " + " : " "
            }
            result += "\(poly[2])"
        }
        
        return result
    }
    
    // Convert polynomial to LaTeX format for MathView
    func polynomialToLaTeX(_ poly: [Int]) -> String {
        var terms: [String] = []
        
        // Handle x^2 term
        if poly.count > 0 && poly[0] != 0 {
            if poly[0] == 1 {
                terms.append("x^2")
            } else if poly[0] == -1 {
                terms.append("-x^2")
            } else {
                terms.append("\(poly[0])x^2")
            }
        }
        
        // Handle x term
        if poly.count > 1 && poly[1] != 0 {
            if poly[1] == 1 {
                terms.append("x")
            } else if poly[1] == -1 {
                terms.append("-x")
            } else {
                terms.append("\(poly[1])x")
            }
        }
        
        // Handle constant term
        if poly.count > 2 && poly[2] != 0 {
            terms.append("\(poly[2])")
        }
        
        // If no terms, it's zero
        if terms.isEmpty {
            return "0"
        }
        
        // Join terms with + signs, handling negative signs
        var result = terms[0]
        for i in 1..<terms.count {
            let term = terms[i]
            if term.first == "-" {
                result += " " + term
            } else {
                result += " + " + term
            }
        }
        
        return result
    }
    
    func findRoots(of poly: [Int]) -> [Int] {
        // Assuming the polynomial is in the form ax^2 + bx + c
        let a = poly[0], b = poly[1], c = poly[2]
        
        // Safety check for a being zero
        guard a != 0 else {
            return []
        }
        
        let discriminant = b * b - 4 * a * c
        
        // Check if there are integer roots
        if discriminant >= 0 {
            let sqrtDiscriminant = Int(sqrt(Double(discriminant)))
            
            // Only include integer roots (when sqrt(discriminant) is an integer)
            if sqrtDiscriminant * sqrtDiscriminant == discriminant {
                // Both numerator and denominator must be divisible to get an integer
                let numerator1 = -b + sqrtDiscriminant
                let numerator2 = -b - sqrtDiscriminant
                let denominator = 2 * a
                
                // Check if the division gives integers
                if numerator1 % denominator == 0 && numerator2 % denominator == 0 {
                    let root1 = numerator1 / denominator
                    let root2 = numerator2 / denominator
                    return [root1, root2]
                }
            }
        }
        
        // If we didn't find integer roots, regenerate the polynomials
        print("No integer roots found, regenerating polynomials")
        polynomial1 = generateLinearPolynomial()
        polynomial2 = generateLinearPolynomial()
        expandedPolynomial = multiplyPolynomials(p1: polynomial1, p2: polynomial2)
        return findRoots(of: expandedPolynomial) // Try again with new polynomials
    }
    
    func checkRoots() {
        // Parse user input and check if they are correct
        let roots = userInput.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        
        if roots.count == 2 {
            let correctRoots = findRoots(of: expandedPolynomial)
            
            if Set(roots) == Set(correctRoots) {
                isVisible2 = false
                isVisible = true
                progstr += "✅"
                score += 1
            } else {
                progstr += "❌"
                isVisible2 = true
            }
            
            if (qnum != totalquestions) {
                // Generate new polynomials
                generatePolynomials()
                
                userInput = ""
                qnum += 1
            } else {
                withAnimation {
                    showCard.toggle()
                }
            }
        } else {
            // Invalid input format
            isVisible2 = true
            progstr += "❌"
        }
    }
    
    func fancy() -> [DemoText] {
        [
            DemoText(polynomialToLaTeX(expandedPolynomial), bb, center, z, display, 30)
        ]
    }
    
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
    
    var body: some View {
        let font = MathFont.latinModernFont
        
        ZStack {
            // Main content
            VStack {
                // Header section with added pen button
                HStack {
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
                
                // Display the polynomials
                VStack(spacing: 25) {
                    // Show the factor form
                    VStack(alignment: .leading) {
                        Text("Factorize and find the roots:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        // Show expanded polynomial using MathView
                        ForEach(fancy()) { label in
                            MathView(equation: label.s, font: font, textAlignment: label.a, fontSize: label.w, labelMode: label.m, insets: label.i)
                                .background(label.c)
                        }
                        
                        // Instructions
                        Text("The expanded form is the product of two linear factors.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .frame(height: 200)
                .frame(maxWidth: 400)
                
                // Answer input section - only show when not in drawing mode
                if !drawingEnabled {
                    HStack {
                        TextField("Enter roots (e.g. 2,-3)", text: $userInput)
                            .keyboardType(.numbersAndPunctuation)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Button(action: {
                            checkRoots()
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
            .onAppear {
                generatePolynomials()
            }
            
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
                    gameType: .polynomial,
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

// Preview provider for the PolynomialGenerator view
struct PolynomialGenerator_Previews: PreviewProvider {
    static var previews: some View {
        PolynomialGenerator(level: 1)
    }
} 