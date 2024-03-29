//
//  TripLogixApp.swift
//  TripLogix
//
//  Created by Cantek Batur on 2024-03-23.
//

import SwiftData
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
struct TripLogixApp: App {
    @State private var isShowingLaunchView = true
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if isShowingLaunchView {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isShowingLaunchView = false
                        }
                    }
            } else {
                MainTabbedView()
            }
        }
        .modelContainer(for: Destination.self)
    }
}
