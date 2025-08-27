//
//  ContentView.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 23.02.2025.
//

import SwiftUI
import SwiftMath

enum EquationType {
    case oneVariable
    case twoVariable
    case threeVariable
}

struct MenuView: View {
    
    enum Page {
        case level1, level2, level3, level4, polynomial, equations
    }
    
    @State private var selectedPage: Page? = nil
    @State private var expandedItem: Int? = nil
    @State private var selectedTab = 1
    @State private var equationDifficulty: Double = 1
    @State private var equationType: EquationType = .oneVariable
    
    // Difficulty levels for each game type
    @State private var level1Difficulty: Double = 1
    @State private var level2Difficulty: Double = 1
    @State private var level3Difficulty: Double = 1
    @State private var fractionDifficulty: Double = 1
    @State private var polynomialDifficulty: Double = 1
    
    @State private var showingHistory = false
    @State private var historyGameType: GameType = .operationsMix
    
    // Add these state variables to MenuView
    @State private var selectedDifficulty: String? = nil
    @State private var multiplicationExpanded: Bool = false
    @State private var divisionExpanded: Bool = false
    @State private var fractionExpanded: Bool = false
    @State private var algebraExpanded: Bool = false
    
    var body: some View {
        // Only show TabView when no game is selected
        if selectedPage == nil {
            TabView(selection: $selectedTab) {
                // First Tab - Learning
                learningTab
                    .tabItem {
                        Image(systemName: "book.fill")
                    }
                    .tag(0)
                
                // Second Tab - Home/Menu
                homeTab
                    .tabItem {
                        Image(systemName: "house.fill")
                    }
                    .tag(1)
                
                // Third Tab - Profile
                profileTab
                    .tabItem {
                        Image(systemName: "person.fill")
                    }
                    .tag(2)
            }
            .accentColor(.teal)
        } else {
            // When a game is selected, show only the game view without tabs
            NavigationStack {
                pageView(for: selectedPage!)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    
    // Home Tab View
    var homeTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom navigation bar with gradient
                ZStack(alignment: .bottomLeading) {
                    // Gradient background that extends to edges
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.teal]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 60)
                    
                    // Title text positioned properly
                    Text("TimedMath")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.leading, 16)
                }
                
                // Main content
                ScrollView {
                    VStack(spacing: 10) {
                        // Level 1: 4 operations mix
                        MenuItemView(
                            title: "4 Operations Mix",
                            description: "Practice with addition, subtraction, multiplication, and division",
                            isExpanded: expandedItem == 0,
                            difficulty: $level1Difficulty,
                            onToggle: { expandedItem = expandedItem == 0 ? nil : 0 },
                            onPlay: { selectedPage = .level1 },
                            onHistory: {
                                historyGameType = .operationsMix
                                showingHistory = true
                            }
                        )
                        
                        // Level 2: Only add and subtract
                        MenuItemView(
                            title: "Addition & Subtraction",
                            description: "Practice with addition and subtraction only",
                            isExpanded: expandedItem == 1,
                            difficulty: $level2Difficulty,
                            onToggle: { expandedItem = expandedItem == 1 ? nil : 1 },
                            onPlay: { selectedPage = .level2 },
                            onHistory: {
                                historyGameType = .additionSubtraction
                                showingHistory = true
                            }
                        )
                        
                        // Level 3: Only multiply and divide
                        MenuItemView(
                            title: "Multiplication & Division",
                            description: "Practice with multiplication and division only",
                            isExpanded: expandedItem == 2,
                            difficulty: $level3Difficulty,
                            onToggle: { expandedItem = expandedItem == 2 ? nil : 2 },
                            onPlay: { selectedPage = .level3 },
                            onHistory: {
                                historyGameType = .multiplicationDivision
                                showingHistory = true
                            }
                        )
                        
                        // Level 4: Fractions
                        MenuItemView(
                            title: "Fractions",
                            description: "Practice with fraction addition, subtraction, and simplification",
                            isExpanded: expandedItem == 3,
                            difficulty: $fractionDifficulty,
                            onToggle: { expandedItem = expandedItem == 3 ? nil : 3 },
                            onPlay: { selectedPage = .level4 },
                            onHistory: {
                                historyGameType = .fractions
                                showingHistory = true
                            }
                        )
                        
                        // Polynomial Practice
                        MenuItemView(
                            title: "Polynomial Factoring",
                            description: "Practice factoring quadratic polynomials and finding roots",
                            isExpanded: expandedItem == 4,
                            difficulty: $polynomialDifficulty,
                            onToggle: { expandedItem = expandedItem == 4 ? nil : 4 },
                            onPlay: { selectedPage = .polynomial },
                            onHistory: {
                                historyGameType = .polynomial
                                showingHistory = true
                            }
                        )
                        
                        // One variable equations
                        MenuItemView(
                            title: "One Variable Equations",
                            description: "Practice solving linear equations with one variable",
                            isExpanded: expandedItem == 5,
                            difficulty: $equationDifficulty,
                            onToggle: { expandedItem = expandedItem == 5 ? nil : 5 },
                            onPlay: { 
                                selectedPage = .equations
                                equationType = .oneVariable
                            },
                            onHistory: {
                                historyGameType = .equations
                                showingHistory = true
                            }
                        )
                        
                        // Two variable equations
                        MenuItemView(
                            title: "Two Variable Systems",
                            description: "Solve systems of equations with two variables (x, y)",
                            isExpanded: expandedItem == 6,
                            difficulty: $equationDifficulty,
                            onToggle: { expandedItem = expandedItem == 6 ? nil : 6 },
                            onPlay: { 
                                selectedPage = .equations
                                equationType = .twoVariable
                            },
                            onHistory: {
                                historyGameType = .equations
                                showingHistory = true
                            }
                        )
                        
                        // Three variable equations
                        MenuItemView(
                            title: "Three Variable Systems",
                            description: "Challenge yourself with three-variable systems (x, y, z)",
                            isExpanded: expandedItem == 7,
                            difficulty: $equationDifficulty,
                            onToggle: { expandedItem = expandedItem == 7 ? nil : 7 },
                            onPlay: { 
                                selectedPage = .equations
                                equationType = .threeVariable
                            },
                            onHistory: {
                                historyGameType = .equations
                                showingHistory = true
                            }
                        )
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationDestination(isPresented: $showingHistory) {
                HistoryView(gameType: historyGameType)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // Learning Tab View with Filtering Option
    var learningTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom navigation bar with gradient
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.teal]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 60)
                    
                    Text("Mental Math & Fundamentals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.leading, 16)
                }
                
                // Learning content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Master essential concepts and mental calculation techniques!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // New: Difficulty filter
                        DifficultyFilterView(selectedDifficulty: $selectedDifficulty)
                            .padding(.horizontal)
                        
                        // Collapsible sections for each category
                        CollapsibleMathSection(
                            title: "Multiplication Techniques",
                            techniques: multiplicationTechniques,
                            isExpanded: $multiplicationExpanded,
                            selectedDifficulty: $selectedDifficulty
                        )
                        
                        CollapsibleMathSection(
                            title: "Division Techniques",
                            techniques: divisionTechniques,
                            isExpanded: $divisionExpanded,
                            selectedDifficulty: $selectedDifficulty
                        )
                        
                        CollapsibleMathSection(
                            title: "Fraction Techniques",
                            techniques: fractionTechniques,
                            isExpanded: $fractionExpanded,
                            selectedDifficulty: $selectedDifficulty
                        )
                        CollapsibleMathSection(
                            title: "Algebra Techniques",
                            techniques: algebraTechniques,
                            isExpanded: $algebraExpanded,
                            selectedDifficulty: $selectedDifficulty
                        )
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // Profile Tab View
    var profileTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom navigation bar with gradient
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.teal]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 60)
                    
                    Text("Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.leading, 16)
                }
                
                // Placeholder content
                VStack {
                    Spacer()
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    Text("Profile Content Coming Soon")
                        .font(.headline)
                        .padding()
                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // Function to return the correct view based on the selected page
    @ViewBuilder
    private func pageView(for page: Page) -> some View {
        // Use Group to contain all possible views
        Group {
            switch page {
            case .level1:
                Generator1(
                    expressionType: "basic4op",
                    minRes: 20,
                    level: Int(level1Difficulty),
                    pmAllowed: true,
                    xsAllowed: true,
                    cfPm: 0.5,
                    gameType: .operationsMix,
                    onExit: { selectedPage = nil }
                )
            case .level2:
                Generator1(
                    expressionType: "basic4op",
                    minRes: 30,
                    level: Int(level2Difficulty),
                    pmAllowed: true,
                    xsAllowed: false,
                    cfPm: 1.0,
                    gameType: .additionSubtraction,
                    onExit: { selectedPage = nil }
                )
            case .level3:
                Generator1(
                    expressionType: "basic4op",
                    minRes: 50,
                    level: Int(level3Difficulty),
                    pmAllowed: false,
                    xsAllowed: true,
                    cfPm: 0.0,
                    gameType: .multiplicationDivision,
                    onExit: { selectedPage = nil }
                )
            case .level4:
                Generator1(
                    expressionType: "frac",
                    minRes: 50,
                    level: Int(fractionDifficulty),
                    pmAllowed: false,
                    xsAllowed: true,
                    cfPm: 0.0,
                    gameType: .fractions,
                    onExit: { selectedPage = nil }
                )
            case .polynomial:
                PolynomialGenerator(
                    level: Int(polynomialDifficulty)
                )
                
            case .equations:
                let parameters = { () -> (LinearEquationSystem, String) in
                    switch equationType {
                    case .oneVariable:
                        return (LinearEquationSystem(variableCount: 1),
                                "Solve the linear equation for x")
                    case .twoVariable:
                        return (LinearEquationSystem(variableCount: 2),
                                "Solve the system of equations for x and y")
                    case .threeVariable:
                        return (LinearEquationSystem(variableCount: 3),
                                "Solve the system of equations for x, y, and z")
                    }
                }()  // Note the () to immediately execute the closure
                
                GeneratorTemplate(
                    generationSystem: parameters.0,
                    placeholder: "Enter value",
                    instructionText: parameters.1,
                    level: Int(equationDifficulty),
                    gameType: .equations,
                    onExit: { selectedPage = nil }
                )
            }
        }
    }
    
    
    // Add these computed properties to MenuView
    var multiplicationTechniques: [MentalMathTechnique] {
        [
            MentalMathTechnique(
                title: "Multiplying by 10, 100, 1000",
                description: "Just add the appropriate number of zeros to the end of the number.",
                example: "25 × 10 = 250\n53 × 100 = 5,300",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Multiplying by 5",
                description: "Multiply by 10, then divide by 2.",
                example: "18 × 5 = (18 × 10) ÷ 2 = 180 ÷ 2 = 90",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Multiplying by 9",
                description: "Multiply by 10, then subtract the original number.",
                example: "7 × 9 = (7 × 10) - 7 = 70 - 7 = 63",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Multiplying by 11",
                description: "For 2-digit numbers, add the digits and place the result between them.",
                example: "53 × 11: 5 + 3 = 8, so 53 × 11 = 583\n(If sum is > 9, carry the 1)",
                difficulty: "Medium"
            ),
            MentalMathTechnique(
                title: "Doubling and Halving",
                description: "Double one factor and halve the other - the product stays the same.",
                example: "17 × 6 = 34 × 3 = 102\n(Double 17, halve 6)",
                difficulty: "Medium"
            ),
            MentalMathTechnique(
                title: "Breaking into Parts",
                description: "Break a number into parts that are easier to multiply.",
                example: "23 × 6 = (20 × 6) + (3 × 6) = 120 + 18 = 138",
                difficulty: "Medium"
            ),
            MentalMathTechnique(
                title: "Multiplying Close to 100",
                description: "Use algebra: (100+a)(100+b) = 10000 + 100a + 100b + ab",
                example: "104 × 98 = (100+4)(100-2)\n= 10000 + 400 - 200 - 8\n= 10192",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Squaring Numbers Ending in 5",
                description: "For any number ending in 5, square it using this formula: (n × (n+1)) followed by 25.",
                example: "35² = 3 × 4 = 12, append 25 = 1225\n75² = 7 × 8 = 56, append 25 = 5625",
                difficulty: "Medium"
            ),
            MentalMathTechnique(
                title: "Squaring Close to 100",
                description: "For numbers close to 100, use (100 + d)² = 10000 + 200d + d².",
                example: "103² = 10000 + 200 × 3 + 3² = 10000 + 600 + 9 = 10609\n95² = 10000 - 200 × 5 + 5² = 10000 - 1000 + 25 = 9025",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Squaring Using Difference of Squares",
                description: "For any number n = a + b, n² = (a + b)² = a² + 2ab + b². Useful when splitting numbers.",
                example: "46² = (40 + 6)² = 40² + 2×40×6 + 6² = 1600 + 480 + 36 = 2116",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Squaring Using Nearby Square",
                description: "If you know a² and want to find (a+d)², use (a+d)² = a² + 2ad + d².",
                example: "29² = 30² - 2×30 + 1 = 900 - 60 + 1 = 841\n51² = 50² + 2×50 + 1 = 2500 + 100 + 1 = 2601",
                difficulty: "Medium"
            ),
            MentalMathTechnique(
                title: "Multiplication by Rounding and Adjusting",
                description: "Round to convenient numbers, multiply, then adjust for the difference.",
                example: "789 × 76 = (790 × 76) - 76\n= (790 × 70) + (790 × 6) - 76\n= 55300 + 4740 - 76 = 59964",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Breaking Down Complex Multiplication",
                description: "Break large numbers into parts and multiply separately using the distributive property.",
                example: "68 × 37 = (60 + 8) × (30 + 7)\n= 60×30 + 60×7 + 8×30 + 8×7\n= 1800 + 420 + 240 + 56 = 2516",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Vertical Multiplication in Your Head",
                description: "Perform traditional vertical multiplication mentally, keeping track of partial products.",
                example: "47 × 35:\nStep 1: 7 × 5 = 35 (write 5, carry 3)\nStep 2: 7 × 30 + 40 × 5 + 30 = 410\nStep 3: 40 × 30 = 1200\nStep 4: Add 5 + 410 + 1200 = 1615",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Multiplication Using Vedic Math",
                description: "Use Vedic mathematics techniques for faster multiplication.",
                example: "98 × 97:\nStep 1: Subtract from base (100): 100-98=2, 100-97=3\nStep 2: Cross-subtract: 98-3 or 97-2 = 95\nStep 3: Multiply differences: 2×3 = 6\nStep 4: Answer: 9506",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Two-Digit Square Shortcut",
                description: "For squaring two-digit numbers, use this pattern: (10a + b)² = 100a² + 20ab + b².",
                example: "26² = (20 + 6)² = 400 + 240 + 36 = 676\n73² = (70 + 3)² = 4900 + 420 + 9 = 5329",
                difficulty: "Advanced"
            ),
            MentalMathTechnique(
                title: "Special Products: Numbers Differing by 2",
                description: "For numbers that differ by 2, multiply them and add 1 to get the square of their average.",
                example: "49 × 51 = 50² - 1 = 2500 - 1 = 2499\n19 × 21 = 20² - 1 = 400 - 1 = 399",
                difficulty: "Medium"
            )
        ]
    }
    
    var divisionTechniques: [MentalMathTechnique] {
        [
            MentalMathTechnique(
                title: "Dividing by 10, 100, 1000",
                description: "Move the decimal point to the left by the appropriate number of places.",
                example: "450 ÷ 10 = 45\n2700 ÷ 100 = 27",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Dividing by 5",
                description: "Divide by 10, then multiply by 2.",
                example: "85 ÷ 5 = (85 ÷ 10) × 2 = 8.5 × 2 = 17",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Dividing by 2",
                description: "Halve the number. For odd numbers, halve the previous even number and add 0.5.",
                example: "46 ÷ 2 = 23\n47 ÷ 2 = 23.5",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Dividing by 9",
                description: "Divide by 10, then add 1/10 of the result.",
                example: "81 ÷ 9 = (81 ÷ 10) + (81 ÷ 100) = 8.1 + 0.81 = 9",
                difficulty: "Medium"
            ),
            MentalMathTechnique(
                title: "Dividing by Breaking Down",
                description: "Break down the division into smaller, more manageable parts.",
                example: "156 ÷ 4 = (160 ÷ 4) - (4 ÷ 4) = 40 - 1 = 39",
                difficulty: "Medium"
            ),
            MentalMathTechnique(
                title: "Common Fraction Conversions",
                description: "Memorize the decimal equivalents of common fractions.",
                example: "1/4 = 0.25\n3/4 = 0.75\n1/3 ≈ 0.33\n2/3 ≈ 0.67",
                difficulty: "Medium"
            )
        ]
    }
    
    var fractionTechniques: [MentalMathTechnique] {
        [
            MentalMathTechnique(
                title: "Adding Fractions",
                description: "Find a common denominator, then add the numerators.",
                example: "1/4 + 3/4 = 4/4 = 1\n1/3 + 1/6 = 2/6 + 1/6 = 3/6 = 1/2",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Simplifying Fractions",
                description: "Divide both numerator and denominator by their greatest common factor.",
                example: "8/12 = (8÷4)/(12÷4) = 2/3\n15/25 = (15÷5)/(25÷5) = 3/5",
                difficulty: "Fundamental"
            ),
            MentalMathTechnique(
                title: "Multiplying Fractions",
                description: "Multiply the numerators, multiply the denominators.",
                example: "2/3 × 3/4 = (2×3)/(3×4) = 6/12 = 1/2",
                difficulty: "Medium"
            )
        ]
    }
    
    var algebraTechniques: [MentalMathTechnique] {
        [
            // FACTORING BINOMIALS & POLYNOMIALS
            MentalMathTechnique(
                title: "Difference of Squares",
                description: "Factor expressions in the form a² - b² using the pattern (a + b)(a - b).",
                example: "x² - 16 = (x + 4)(x - 4)\n49 - y² = (7 + y)(7 - y)",
                difficulty: "Fundamental"
            ),
            
            MentalMathTechnique(
                title: "Difference & Sum of Cubes",
                description: "Factor expressions using:\na³ - b³ = (a - b)(a² + ab + b²)\na³ + b³ = (a + b)(a² - ab + b²)",
                example: "x³ - 8 = (x - 2)(x² + 2x + 4)\nx³ + 27 = (x + 3)(x² - 3x + 9)",
                difficulty: "Advanced"
            ),
            
            MentalMathTechnique(
                title: "Perfect Square Trinomials",
                description: "Recognize and factor trinomials in the form:\nx² + 2ax + a² = (x + a)²\nx² - 2ax + a² = (x - a)²",
                example: "x² + 6x + 9 = (x + 3)²\nx² - 10x + 25 = (x - 5)²",
                difficulty: "Fundamental"
            ),
            
            MentalMathTechnique(
                title: "General Trinomial Factoring",
                description: "For x² + bx + c, find numbers p and q where p + q = b and p×q = c.",
                example: "x² + 7x + 12 = (x + 3)(x + 4)\nsince 3 + 4 = 7 and 3 × 4 = 12\n\nx² - 5x + 6 = (x - 2)(x - 3)\nsince 2 + 3 = 5 and 2 × 3 = 6",
                difficulty: "Medium"
            ),
            
            // SOLVING SYSTEMS OF EQUATIONS
            MentalMathTechnique(
                title: "Solving Systems: Substitution Method",
                description: "1. Solve one equation for one variable\n2. Substitute into the second equation\n3. Solve for the remaining variable\n4. Substitute back",
                example: "x + y = 10\n2x - y = 5\n\nFrom first: y = 10 - x\nSubstitute: 2x - (10 - x) = 5\n2x - 10 + x = 5\n3x = 15\nx = 5\ny = 10 - 5 = 5\n\nSolution: (5, 5)",
                difficulty: "Advanced"
            ),
            
            MentalMathTechnique(
                title: "Solving Systems: Elimination Method",
                description: "1. Adjust equations to make coefficients of one variable equal but opposite\n2. Add equations to eliminate a variable\n3. Solve for remaining variable\n4. Substitute back",
                example: "3x + 2y = 7\n5x - 2y = 3\n\nAdd equations:\n8x = 10\nx = 5/4\n\nSubstitute:\n3(5/4) + 2y = 7\n15/4 + 2y = 7\n2y = 13/4\ny = 13/8\n\nSolution: (5/4, 13/8)",
                difficulty: "Advanced"
            ),
            
            MentalMathTechnique(
                title: "Cramer's Rule for 2×2 Systems",
                description: "For system ax + by = e, cx + dy = f:\nx = (e·d - b·f)/(a·d - b·c)\ny = (a·f - e·c)/(a·d - b·c)",
                example: "3x + 2y = 8\n5x - y = 7\n\nDeterminant = 3(-1) - 2(5) = -13\n\nx = (8(-1) - 2(7))/(-13) = 22/13\ny = (3(7) - 8(5))/(-13) = -19/13",
                difficulty: "Advanced"
            ),
            
            // POLYNOMIAL DIVISION
            MentalMathTechnique(
                title: "Synthetic Division",
                description: "Quick method to divide a polynomial by (x - r):\n1. Write coefficients of dividend\n2. Bring down first coefficient\n3. Multiply by r and add to next coefficient\n4. Repeat until finished",
                example: "Divide x³ - 2x² - 4 by (x - 3):\n    3 | 1  -2   0  -4\n      |    3   3   9\n      ---------------\n        1   1   3   5\n\nResult: x² + x + 3 + 5/(x-3)",
                difficulty: "Advanced"
            ),
            
            MentalMathTechnique(
                title: "Polynomial Long Division",
                description: "Divide polynomials systematically:\n1. Arrange in descending order\n2. Divide first terms\n3. Multiply, subtract, bring down\n4. Repeat until remainder degree < divisor degree",
                example: "Divide 2x³ + 3x² - 5x + 1 by x² + 2\n\n      2x + 3\nx² + 2 )2x³ + 3x² - 5x + 1\n       2x³ + 4x\n       ----------\n           3x² - 9x\n           3x² + 6\n           ----------\n               -9x - 5\n               -9x - 18\n               ----------\n                   14\n\nResult: 2x + 3 + 14/(x² + 2)",
                difficulty: "Advanced"
            ),
            
            // QUADRATIC METHODS
            MentalMathTechnique(
                title: "Completing the Square",
                description: "1. Get ax² + bx + c = 0 with a = 1\n2. Move c to right side\n3. Add (b/2)² to both sides\n4. Rewrite as perfect square\n5. Solve for x",
                example: "2x² - 12x + 10 = 0\nx² - 6x + 5 = 0\nx² - 6x = -5\nx² - 6x + 9 = -5 + 9\n(x - 3)² = 4\nx = 5 or x = 1",
                difficulty: "Advanced"
            ),
            
            MentalMathTechnique(
                title: "Quadratic Formula Shortcuts",
                description: "For ax² + bx + c = 0, x = (-b ± √(b² - 4ac))/2a\n\nTrick: Calculate the discriminant first and look for perfect squares.",
                example: "3x² + 10x - 8 = 0\na = 3, b = 10, c = -8\n\nDiscriminant = 10² - 4(3)(-8)\n= 100 + 96 = 196 = 14²\n\nx = (-10 ± 14)/6\nx = 2/3 or x = -4",
                difficulty: "Fundamental"
            ),
            
            // SPECIAL PATTERNS
            MentalMathTechnique(
                title: "Binomial Expansion Patterns",
                description: "Quick patterns for expanding binomials:",
                example: "(x + y)² = x² + 2xy + y²\n(x - y)² = x² - 2xy + y²\n(x + y)³ = x³ + 3x²y + 3xy² + y³\n(x - y)³ = x³ - 3x²y + 3xy² - y³\n(x + y)(x - y) = x² - y²",
                difficulty: "Fundamental"
            ),
            
            MentalMathTechnique(
                title: "Sum of Powers Patterns",
                description: "Recognize divisibility patterns in expressions with powers:",
                example: "• x^n + y^n is divisible by (x + y) when n is odd\n• x^n - y^n is divisible by (x - y) for all n\n• x^n - y^n is divisible by (x^m - y^m) when m divides n",
                difficulty: "Advanced"
            )
        ]
    }
    
    
    // Custom menu item view with expansion capability
    struct MenuItemView: View {
        let title: String
        let description: String
        let isExpanded: Bool
        @Binding var difficulty: Double
        let onToggle: () -> Void
        let onPlay: () -> Void
        let onHistory: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Main button row
                Button(action: onToggle) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if !isExpanded {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.blue)
                            .animation(.easeInOut, value: isExpanded)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                //                if isExpanded && expandedItem == 5 {
                //                    Picker("Equation Type", selection: $equationType) {
                //                        ForEach(EquationGenerator.EquationType.allCases, id: \.self) { type in
                //                            Text(type.rawValue).tag(type)
                //                        }
                //                    }
                //                    .pickerStyle(SegmentedPickerStyle())
                //                    .padding(.vertical, 8)
                //                }
                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Difficulty slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Difficulty Level: \(Int(difficulty))")
                                .font(.subheadline)
                            
                            HStack {
                                Text("Easy")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Slider(value: $difficulty, in: 1...3, step: 1)
                                    .accentColor(.blue)
                                
                                Text("Hard")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            // History button
                            Button(action: onHistory) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                    Text("History")
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            // Play button
                            Button(action: onPlay) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Play")
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isExpanded)
                }
            }
            .background(Color.white.opacity(0.001)) // Invisible background for tap area
        }
    }
    
    // Helper function to create mental math technique sections
    func mentalMathSection(title: String, techniques: [MentalMathTechnique]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(techniques) { technique in
                TechniqueCard(technique: technique)
            }
        }
    }
    
    // Data structure for mental math techniques
    struct MentalMathTechnique: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let example: String
        let difficulty: String
        
        var difficultyColor: Color {
            switch difficulty {
            case "Fundamental":
                return .purple
            case "Easy":
                return .green
            case "Medium":
                return .blue
            case "Advanced":
                return .orange
            default:
                return .gray
            }
        }
    }
    
    // Card view for individual techniques
    struct TechniqueCard: View {
        let technique: MentalMathTechnique
        @State private var isExpanded = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Title row with expand/collapse button
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(technique.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if !isExpanded {
                                Text(technique.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Difficulty badge
                        Text(technique.difficulty)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(technique.difficultyColor.opacity(0.2))
                            .foregroundColor(technique.difficultyColor)
                            .cornerRadius(4)
                        
                        // Expand/collapse chevron
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Expanded content with description and example
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(technique.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Example")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text(technique.example)
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .transition(.opacity)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
    
    // New View: Difficulty Filter
    struct DifficultyFilterView: View {
        @Binding var selectedDifficulty: String?
        
        // All possible difficulties - add Fundamental
        let difficulties = ["All", "Fundamental", "Easy", "Medium", "Advanced"]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter by Difficulty")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    ForEach(difficulties, id: \.self) { difficulty in
                        Button(action: {
                            // Set to nil if "All" is selected, otherwise set to the difficulty
                            selectedDifficulty = difficulty == "All" ? nil : difficulty
                        }) {
                            Text(difficulty)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(isSelected(difficulty) ?
                                              difficultyColor(difficulty).opacity(0.2) :
                                                Color.gray.opacity(0.1))
                                )
                                .foregroundColor(isSelected(difficulty) ?
                                                 difficultyColor(difficulty) :
                                                    Color.gray)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected(difficulty) ?
                                                difficultyColor(difficulty) :
                                                    Color.clear, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        
        // Helper to check if this difficulty is currently selected
        func isSelected(_ difficulty: String) -> Bool {
            if difficulty == "All" {
                return selectedDifficulty == nil
            } else {
                return selectedDifficulty == difficulty
            }
        }
        
        // Helper to get color for each difficulty
        func difficultyColor(_ difficulty: String) -> Color {
            switch difficulty {
            case "Fundamental":
                return .purple
            case "Easy":
                return .green
            case "Medium":
                return .blue
            case "Advanced":
                return .orange
            default:
                return .primary
            }
        }
    }
    
    // New View: Collapsible Math Section
    struct CollapsibleMathSection: View {
        let title: String
        let techniques: [MentalMathTechnique]
        @Binding var isExpanded: Bool
        @Binding var selectedDifficulty: String?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // Section header with expand/collapse button
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        
                        Spacer()
                        
                        // Show count of matching techniques
                        Text("\(filteredTechniques.count) techniques")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.blue)
                            .animation(.easeInOut, value: isExpanded)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                
                // Techniques cards (only shown if section is expanded)
                if isExpanded {
                    if filteredTechniques.isEmpty {
                        emptyResultsView
                    } else {
                        ForEach(filteredTechniques) { technique in
                            TechniqueCard(technique: technique)
                        }
                    }
                }
            }
        }
        
        var filteredTechniques: [MentalMathTechnique] {
            if let difficulty = selectedDifficulty {
                return techniques.filter { $0.difficulty == difficulty }
            } else {
                return techniques
            }
        }
        
        var emptyResultsView: some View {
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("No \(title.lowercased()) found for the selected difficulty")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
                
                Spacer()
            }
        }
    }
    
}
