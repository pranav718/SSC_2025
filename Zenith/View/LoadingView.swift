//
//  LoadingView.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 25/01/25.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject private var viewModel: MindfulnessViewModel
    @State private var appNameOpacity = 0.0
    
    let appName = "Zenith"
    
    var body: some View {
        ZStack {
            Color.mindfulBackground
                .ignoresSafeArea()
            
            VStack {
                Text(appName)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.mindfulPrimary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(appNameOpacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                appNameOpacity = 1.0
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
