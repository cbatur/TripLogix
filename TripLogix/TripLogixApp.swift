//
//  TripLogixApp.swift
//  TripLogix
//
//  Created by Cantek Batur on 2024-03-23.
//

import SwiftData
import SwiftUI
import FirebaseCore
import FBSDKCoreKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize Facebook SDK
        Settings.shared.appID = "830473245630803"
        Settings.shared.clientToken = "1cc8b6a7366c53b32d883f4fb7135229"
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Initialize Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "514838649340-0fde7bcll5meailh7nrcfd6nfgkqp6eq")

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle Facebook URL
        let handled = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

        // Handle Google Sign-In URL
        let googleHandled = GIDSignIn.sharedInstance.handle(url)
        
        return handled || googleHandled
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
                TripsView()
                    .environmentObject(SessionManager.shared)
            }
        }
        .modelContainer(for: Destination.self)
    }
}
