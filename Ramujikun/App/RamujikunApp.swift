//
//  RamujikunApp.swift
//  Ramujikun
//
//  Created by 原里駆 on 2025/07/11.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct RamujikunApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                CalendarView()
                    .environmentObject(AuthViewModel())
            } else {
                OnboardindView()
                    .onDisappear {
                        hasSeenOnboarding = true
                    }
            }
        }
    }
}
