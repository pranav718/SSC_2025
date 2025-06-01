//
//  Entries.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 25/01/25.
//

import SwiftUI

struct DeveloperDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("About me")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Hi, I'm Pranav Ray, an 18-year-old passionate about Computer Science. Currently pursuing my CS education, I'm dedicated to learning and growing in the world of technology.")
                    .font(.body)
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 9) {
                    Text("Connect with Me:")
                        .font(.headline)
                    
                    Link("GitHub", destination: URL(string: "https://github.com/Pranav718")!)
                        .foregroundColor(.mindfulPrimary)
                    
                    Link("X (Twitter)", destination: URL(string: "https://x.com/knighn__")!)
                        .foregroundColor(.mindfulPrimary)
                }
            }
            .padding()
        }
        //.navigationTitle("Developer")
        .background(Color.mindfulBackground.ignoresSafeArea())
    }
}

struct AboutView: View {
    @EnvironmentObject private var viewModel: MindfulnessViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                   
                    CardView {
                        VStack(alignment: .center, spacing: 16) {
                            Text("Zenith")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.mindfulText)
                            
                            Text("Your mindful companion for mood tracking and self-reflection")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.mindfulText.opacity(0.7))
                        }
                    }
                    
                    NavigationLink(destination: DeveloperDetailView()) {
                        CardView {
                            VStack(alignment: .center, spacing: 16) {
                                Text("Developer                                                          ")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.mindfulText)
                                
                                Text("Tap to learn more")
                                    .font(.subheadline)
                                    .foregroundColor(.mindfulText.opacity(0.7))
                            }
                        }
                    }
                    
                    CardView {
                        VStack(alignment: .center, spacing: 12) {
                            Text("App Details")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.mindfulText)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Version")
                                        .foregroundColor(.mindfulText.opacity(0.7))
                                    Spacer()
                                    Text("1.0.0")
                                        .foregroundColor(.mindfulText)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Last Updated")
                                        .foregroundColor(.mindfulText.opacity(0.7))
                                    Spacer()
                                    Text("February 2025")
                                        .foregroundColor(.mindfulText)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Platform")
                                        .foregroundColor(.mindfulText.opacity(0.7))
                                    Spacer()
                                    Text("iOS")
                                        .foregroundColor(.mindfulText)
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationTitle("About")
        }
    }
}

#Preview {
    AboutView()
}

