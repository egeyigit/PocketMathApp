//
//  learningSwiftApp.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 23.02.2025.
//

import SwiftUI
import SwiftData
import Foundation
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct learningSwiftApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            FirstLaunchGate()
                .preferredColorScheme(.light)
        }
        
    }
}

/// A small gate that shows a first-launch screen and records download count.
struct FirstLaunchGate: View {
    @AppStorage("hasRecordedDownload") private var hasRecordedDownload = false
    @State private var userCount: Int? = nil
    @State private var appOpenCount: Int? = nil
    @State private var isReady = false
    @State private var firebaseStatus = "Initializing..."
    @State private var showingWelcomeMessage = false

    var body: some View {
        Group {
            if showingWelcomeMessage {
                VStack(spacing: 20) {
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Firebase Status: \(firebaseStatus)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let n = userCount {
                        Text("Thank you! You are the \(n)th user to download this app")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Preparing your welcome...")
                            .font(.title3)
                    }
                    
                    if let openCount = appOpenCount {
                        Text("App has been opened \(openCount) times total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { 
                        showingWelcomeMessage = false
                        hasRecordedDownload = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            } else if !hasRecordedDownload {
                VStack(spacing: 20) {
                    Text("Initializing...")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Firebase Status: \(firebaseStatus)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                }
                .padding()
                .onAppear {
                    // Ensure Firebase is configured
                    firebaseStatus = "Configuring Firebase..."
                    FirebaseManager.shared.configureIfNeeded()
                    
                    // Ensure user document exists every time app opens
                    firebaseStatus = "Checking user document..."
                    FirebaseManager.shared.ensureUserDocumentExists { count in
                        DispatchQueue.main.async {
                            if let newUserCount = count {
                                // New user document was created
                                userCount = newUserCount
                                firebaseStatus = "New user registered: \(newUserCount)"
                                showingWelcomeMessage = true
                                print("New user registered with count: \(newUserCount)")
                            } else {
                                // User document already exists
                                firebaseStatus = "User document ready"
                                hasRecordedDownload = true
                                print("User document already exists")
                            }
                        }
                    }
                    
                    // Increment app open count every time
                    firebaseStatus = "Incrementing app open count..."
                    FirebaseManager.shared.incrementAppOpenCount { count in
                        DispatchQueue.main.async {
                            appOpenCount = count
                            print("App open count incremented to: \(count ?? -1)")
                        }
                    }
                }
            } else {
                MenuView()
                    .onAppear {
                        // Ensure user document exists every time app opens
                        FirebaseManager.shared.ensureUserDocumentExists { count in
                            if let newUserCount = count {
                                // New user document was created, show welcome message
                                DispatchQueue.main.async {
                                    userCount = newUserCount
                                    showingWelcomeMessage = true
                                    hasRecordedDownload = false
                                    print("New user detected while app was running: \(newUserCount)")
                                }
                            } else {
                                print("User document check completed successfully")
                            }
                        }
                        
                        // Increment app open count every time app opens
                        FirebaseManager.shared.incrementAppOpenCount { count in
                            print("App open count incremented to: \(count ?? -1)")
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Reset First Launch") {
                                hasRecordedDownload = false
                                showingWelcomeMessage = false
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
            }
        }
    }
}
