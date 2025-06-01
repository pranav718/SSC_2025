//
//  BreathingExercisesView.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 25/01/25.
//


import CoreData
import SwiftUI

struct BubbleView: View {
    @EnvironmentObject private var viewModel: MindfulnessViewModel
    @State private var isAnimating = false
    let position: CGPoint
    let delay: Double
    
    var body: some View {
        Circle()
            .fill(Color.mindfulPrimary.opacity(0.3))
            .frame(width: 10, height: 10)
            .position(position)
            .scaleEffect(isAnimating ? 1.5 : 0.5)
            .opacity(isAnimating ? 0 : 0.7)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever()
                        .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct BreathingExercisesView: View {
    @State private var isBreathing = false
    @State private var breathingPhase = 0
    @State private var progress: CGFloat = 0
    @State private var selectedExercise = 0
    @State private var scale: CGFloat = 1.0
    
    let exercises = [
        ("Box Breathing", 4, 4, 4, 4),
        ("4-7-8 Breathing", 4, 7, 8, 0),
        ("Deep Breathing", 4, 0, 4, 0)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("Exercise", selection: $selectedExercise) {
                        ForEach(0..<exercises.count, id: \.self) { index in
                            Text(exercises[index].0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.mindfulCard)
                    .cornerRadius(12)
                    .shadow(color: Color.mindfulShadow, radius: 5)
                    .padding(.horizontal)
                    .onChange(of: selectedExercise) { oldValue, newValue in
                        resetBreathingExercise()
                    }

                    ZStack {
                        ForEach(0..<12) { index in
                            let angle = Double(index) * (360.0 / 12.0)
                            let radius: CGFloat = 150
                            let x = cos(angle * .pi / 180) * radius + 125
                            let y = sin(angle * .pi / 180) * radius + 125
                            
                            BubbleView(
                                position: CGPoint(x: x, y: y),
                                delay: Double(index) * 0.2
                            )
                        }
                        
                        Circle()
                            .stroke(Color.mindfulPrimary.opacity(0.2), lineWidth: 25)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.mindfulPrimary,
                                        Color.mindfulSecondary
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 25, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)
                        
                        Text(getInstructionText())
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.mindfulText)
                            .scaleEffect(scale)
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: scale
                            )
                            .onAppear {
                                scale = 1.2
                            }
                    }
                    .padding(40)
                    .background(Color.mindfulCard)
                    .cornerRadius(20)
                    .shadow(color: Color.mindfulShadow, radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Button(action: toggleBreathing) {
                        HStack {
                            Text(isBreathing ? "Stop" : "Start")
                                .font(.system(.headline, design: .rounded))
                            Image(systemName: isBreathing ? "stop.circle.fill" : "play.circle.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.mindfulPrimary, Color.mindfulSecondary]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.mindfulShadow, radius: 10, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.mindfulPrimary)
                        
                        Text(getExerciseDescription())
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.mindfulText.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.mindfulCard)
                    .cornerRadius(15)
                    .shadow(color: Color.mindfulShadow, radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationTitle("Breathing Exercises")
        }
        .accentColor(Color.mindfulPrimary)
    }
    
    func toggleBreathing() {
        isBreathing.toggle()
        if isBreathing {
            startBreathingExercise()
        } else {
            resetBreathingExercise()
        }
    }
    
    func startBreathingExercise() {
        let exercise = exercises[selectedExercise]
        let (_, inhale, hold1, exhale, hold2) = exercise
        
        progress = 0
        breathingPhase = 0
        
        let totalDuration = Double(inhale + hold1 + exhale + hold2)
        
        func runPhase() {
            guard isBreathing else { return }
            
            if breathingPhase == 0 {
                withAnimation(.linear(duration: 0.1)) {
                    progress = 0
                }
            }
            
            let currentDuration: Double
            switch breathingPhase {
            case 0: currentDuration = Double(inhale)
            case 1: currentDuration = Double(hold1)
            case 2: currentDuration = Double(exhale)
            case 3: currentDuration = Double(hold2)
            default: currentDuration = 0
            }
            
            if currentDuration == 0 {
                breathingPhase = (breathingPhase + 1) % 4
                runPhase()
                return
            }

            let phaseProgress = currentDuration / totalDuration
            let endProgress = progress + phaseProgress

            withAnimation(.linear(duration: currentDuration)) {
                progress = endProgress
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + currentDuration) {
                guard isBreathing else { return }
                breathingPhase = (breathingPhase + 1) % 4
                runPhase()
            }
        }
        
        runPhase()
    }
    
    func resetBreathingExercise() {
        isBreathing = false
        progress = 0
        breathingPhase = 0
    }
    
    func getInstructionText() -> String {
        switch breathingPhase {
        case 0: return "Inhale"
        case 1: return "Hold"
        case 2: return "Exhale"
        case 3: return "Hold"
        default: return ""
        }
    }
    
    func getExerciseDescription() -> String {
        let exercise = exercises[selectedExercise]
        return """
        \(exercise.0):
        • Inhale for \(exercise.1) seconds
        • Hold for \(exercise.2) seconds
        • Exhale for \(exercise.3) seconds
        • Hold for \(exercise.4) seconds
        """
    }
}

#Preview {
    BreathingExercisesView()
}
