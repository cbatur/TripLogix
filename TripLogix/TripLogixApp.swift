//
//  TripLogixApp.swift
//  TripLogix
//
//  Created by Cantek Batur on 2024-03-23.
//

import SwiftData
import SwiftUI

@main
struct TripLogixApp: App {
    @State private var isShowingLaunchView = true
    
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
