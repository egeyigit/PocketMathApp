# TimedMath

TimedMath is an iOS application designed to help users practice and improve their math skills through a variety of timed exercises. The app features multiple game modes, difficulty levels, and tracks user progress to encourage improvement.

## Features

*   **Multiple Game Modes:** Practice a wide range of mathematical concepts:
    *   Basic four operations (addition, subtraction, multiplication, division)
    *   Fractions
    *   Polynomial Factoring
    *   Solving systems of linear equations (with one, two, or three variables)
*   **Difficulty Levels:** Each game mode offers Easy, Medium, and Hard difficulty settings to suit different skill levels.
*   **Timed Challenges:** Test your speed and accuracy against the clock.
*   **Performance Tracking:** The app saves your best scores and times for each game mode and difficulty, along with a history of your attempts.
*   **Learning Center:** Includes a dedicated tab with explanations of various mental math techniques to help you improve your calculation speed.
*   **Beautiful Math Rendering:** Utilizes `SwiftMath` and `LaTeXSwiftUI` to display mathematical expressions clearly and correctly.
*   **Drawing Canvas:** A scratchpad feature allows you to work out problems directly on the screen.

## How to Run

This is an iOS application built with Swift and SwiftUI. To run it on your machine, you will need a Mac with Xcode installed.

1.  **Clone the repository.**
2.  **Open the project in Xcode:**
    ```bash
    open Development/Projects/Clones/PocketMathApp/learningSwift.xcodeproj
    ```
3.  **Run the app:**
    *   Once the project is open, select an iPhone or iPad simulator from the target device dropdown at the top of the Xcode window.
    *   Click the "Run" button (the play icon) or press `Cmd+R`.

## Dependencies

This project uses Swift Package Manager for its dependencies, which include:
*   [SwiftMath](https://github.com/mgriebling/SwiftMath) - For rendering LaTeX expressions.
*   [LaTeXSwiftUI](https://github.com/colinc86/LaTeXSwiftUI) - For using LaTeX in SwiftUI.
*   [Firebase](https://github.com/firebase/firebase-ios-sdk) - Used for backend features.
*   [MathKeyboardEngine](https://github.com/MathKeyboardEngine/MathKeyboardEngine.Swift) - A custom math keyboard engine.
*   [Swift Algorithms](https://github.com/apple/swift-algorithms) - Apple's open-source library of sequence and collection algorithms.

## License

Please add your license information here.
