//
//  ContentView.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 01/01/25.

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var viewModel: MindfulnessViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MoodTrackerView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Mood")
                }
                .tag(0)
            
            GratitudeJournalView()
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Gratitude")
                }
                .tag(1)
            
            BreathingExercisesView()
                .tabItem {
                    Image(systemName: "lungs")
                    Text("Breathe")
                }
                .tag(2)
            
            AffirmationsView()
                .tabItem {
                    Image(systemName: "quote.bubble")
                    Text("Affirmations")
                }
                .tag(3)
            
            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("About")
                }
                .tag(5)
            
        }
    }
}

#Preview{
    ContentView()
}

