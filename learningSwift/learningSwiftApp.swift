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
    @State private var downloadCount: Int? = nil
    @State private var isReady = false

    var body: some View {
        Group {
            if !hasRecordedDownload {
                VStack(spacing: 20) {
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    if let n = downloadCount {
                        Text("You are the \(n)th user to download this app")
                            .font(.title3)
                    } else {
                        Text("Preparing your first launch...")
                            .font(.title3)
                    }
                    Button(action: { hasRecordedDownload = true }) {
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
                .onAppear {
                    FirebaseManager.shared.configureIfNeeded()
                    FirebaseManager.shared.fetchAndIncrementDownloadCount { count in
                        downloadCount = count
                    }
                }
            } else {
                MenuView()
            }
        }
    }
}
