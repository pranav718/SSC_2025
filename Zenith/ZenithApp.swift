//
//  SomeAnimationsApp.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 01/01/25.
//

import SwiftUI

@main
struct ZenithApp: App {
    @State private var isLoading = true
    @StateObject private var viewModel = MindfulnessViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    LoadingView()
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isLoading = false
                                }
                            }
                        }
                } else {
                    ContentView()
                        .transition(.move(edge: .bottom))
                        .environmentObject(viewModel)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isLoading)
        }
    }
}
