//
//  GeneratorTemplate.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 28.03.2025.
//

import SwiftUI
import SwiftMath

// Protocol for generation systems to conform to
protocol GenerationSystem {
    // Method to generate a new problem
    func generateProblem(level: Int) -> (latex: String, solution: [String: Any])
    
    // Method to check if an answer is correct
    func checkAnswer(userInputs: [String: String], solution: [String: Any]) -> Bool
    
    // Method to get the variable names that need input fields
    func getInputVariables() -> [String]
    
    // Optional method for custom formatting of the solution display (for review)
    func formatSolution(solution: [String: Any]) -> String?
}

struct GeneratorTemplate: View {
    // Generator configuration
    let generationSystem: GenerationSystem
    let placeholder: String
    let instructionText: String
    let level: Int
    let gameType: GameType
    let onExit: () -> Void
    
    // UI state
    @State private var showCard = false
    @State private var score = 0
    @State private var paused = false
    @State var viewID: UUID = UUID()
    
    @State private var currentLatexProblem: String = ""
    @State private var currentSolution: [String: Any] = [:]
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
    
    // Add a state variable for equations array
    @State private var currentEquations: [String] = []
    
    init(generationSystem: GenerationSystem, placeholder: String, instructionText: String, level: Int, gameType: GameType, onExit: @escaping () -> Void = {}) {
        self.generationSystem = generationSystem
        self.placeholder = placeholder
        self.instructionText = instructionText
        self.level = level
        self.gameType = gameType
        self.onExit = onExit
        
        // Generate initial problem
        let initialProblem = generationSystem.generateProblem(level: level)
        _currentLatexProblem = State(initialValue: initialProblem.latex)
        _currentSolution = State(initialValue: initialProblem.solution)
        
        // Initialize input fields
        var initialInputs = [String: String]()
        for variable in generationSystem.getInputVariables() {
            initialInputs[variable] = ""
        }
        _inputValues = State(initialValue: initialInputs)
    }
    
    func fancy() -> [DemoText] {
        let varCount = generationSystem.getInputVariables().count
        let size: CGFloat
        switch varCount {
        case 3:
            size = 22
        case 2:
            size = 26
        default:
            size = 30
        }
        if let equations = currentSolution["equations"] as? [String] {
            return equations.map { equation in
                DemoText(equation, bb, center, z, display, size)
            }
        } else {
            // Single equation case
            return [DemoText(currentLatexProblem, bb, center, z, display, size)]
        }
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
    
    private func generateNewProblem() {
        let newProblem = generationSystem.generateProblem(level: level)
        currentLatexProblem = newProblem.latex
        currentSolution = newProblem.solution
        
        // Reset input values
        var newInputs = [String: String]()
        for variable in generationSystem.getInputVariables() {
            newInputs[variable] = ""
        }
        inputValues = newInputs
    }
    
    private func resetValues() {
        timer?.invalidate()
        timer = nil
        secondsElapsed = 0
        
        generateNewProblem()
        
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
    @State private var showQuitConfirm = false
    
    // Add this computed property to determine frame height
    private var frameHeight: CGFloat {
        let variables = generationSystem.getInputVariables().count
        switch variables {
        case 2:
            return 250
        case 3:
            return 300
        default:
            return 200
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
                
                // Problem display
                VStack {
                    Text(instructionText)
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    // Render each equation separately
                    VStack(spacing: 20) {  // Add spacing between equations
                        ForEach(fancy()) { label in
                            MathView(equation: label.s, 
                                    font: font, 
                                    textAlignment: label.a, 
                                    fontSize: label.w, 
                                    labelMode: label.m, 
                                    insets: label.i)
                                .background(label.c)
                                .padding(.horizontal)  // Add horizontal padding
                        }
                    }
                    
                    if level > 1 {
                        Text("Higher difficulty levels may require more precision")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                }
                .frame(height: frameHeight)
                .frame(maxWidth: 400)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                if !drawingEnabled {
                    // Input fields for variables
                    VStack(spacing: 15) {
                        ForEach(generationSystem.getInputVariables(), id: \.self) { variable in
                            HStack {
                                Text(variable + " =")
                                    .font(.headline)
                                    .frame(width: 50, alignment: .trailing)
                                
                                TextField(placeholder, text: Binding(
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
                            let isCorrect = generationSystem.checkAnswer(userInputs: inputValues, solution: currentSolution)
                            
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
                                generateNewProblem()
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
                                        print("syetmworkzss!!")
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
