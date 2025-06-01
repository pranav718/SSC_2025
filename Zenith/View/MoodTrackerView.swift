//
//  MoodTrackerView.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 25/01/25.
//

import Charts
import CoreData
import SwiftUI


extension Color {
    static let mindfulBackground = Color(red: 173/255, green: 216/255, blue: 230/255)
    static let mindfulCard = Color(red: 240/255, green: 248/255, blue: 255/255)
    static let mindfulPrimary = Color(red: 25/255, green: 25/255, blue: 112/255)
    static let mindfulSecondary = Color(red: 135/255, green: 206/255, blue: 250/255)
    static let mindfulAccent = Color(red: 240/255, green: 248/255, blue: 255/255)
    static let mindfulText = Color(red: 25/255, green: 25/255, blue: 112/255)
    static let mindfulShadow = Color.black.opacity(0.1)
}

struct MoodTrackerView: View {
    @EnvironmentObject private var viewModel: MindfulnessViewModel
    @State private var currentMood: MoodType = .neutral
    @State private var moodNote: String = ""
    @State private var showingAddTrigger = false
    @State private var triggers: [String] = []
    @State private var moodEntries: [MoodEntry] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("How are you feeling?")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.mindfulText)

                            MoodGrid(currentMood: $currentMood)
                                .padding(.vertical, 8)
                        }
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What's on your mind?")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.mindfulText)
                            
                            TextEditor(text: $moodNote)
                                .frame(minHeight: 100)
                                .background(Color.mindfulCard.opacity(0.5))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.mindfulAccent.opacity(0.2), lineWidth: 1)
                                )
                                .foregroundColor(.mindfulText)
                        }
                    }
                    
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("What triggered this feeling?")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.mindfulText)
                                
                                Spacer()
                                
                                AddButton {
                                    showingAddTrigger = true
                                }
                            }
                            
                            if triggers.isEmpty {
                                Text("Tap + to add triggers")
                                    .foregroundColor(.mindfulText.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 8)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(triggers, id: \.self) { trigger in
                                            TriggerChip(text: trigger) {
                                                withAnimation {
                                                    triggers.removeAll { $0 == trigger }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Mood Journey")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.mindfulText)
                            
                            MoodChartView(entries: moodEntries)
                                .frame(height: 220)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationTitle("Zenith")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SaveButton(action: saveMoodEntry)
                }
            }
        }
        .sheet(isPresented: $showingAddTrigger) {
            AddTriggerView(triggers: $triggers)
        }
    }
    
    func saveMoodEntry() {
        guard !moodNote.isEmpty || !triggers.isEmpty else { return }
        let newEntry = MoodEntry(id: UUID(), date: Date(), mood: currentMood, notes: moodNote, triggers: triggers)
        moodEntries.append(newEntry)
        
        withAnimation {
            moodNote = ""
            triggers = []
            currentMood = .neutral
        }
    }
}

struct MoodGrid: View {
    @Binding var currentMood: MoodType
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
            ForEach(MoodType.allCases, id: \.self) { mood in
                MoodOption(mood: mood, isSelected: mood == currentMood) {
                    withAnimation(.spring()) {
                        currentMood = mood
                    }
                }
            }
        }
    }
}

struct MoodOption: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                    .padding(12)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.mindfulPrimary.opacity(0.2) : Color.clear)
                    )
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.mindfulPrimary : Color.clear, lineWidth: 2)
                    )
                
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(.mindfulText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.mindfulCard)
            .cornerRadius(12)
            .shadow(color: isSelected ? .mindfulShadow : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(Color.mindfulCard)
            .cornerRadius(16)
            .shadow(color: .mindfulShadow, radius: 8, x: 0, y: 4)
    }
}

struct TriggerChip: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.mindfulText)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.mindfulText.opacity(0.6))
                    .imageScale(.small)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.mindfulSecondary.opacity(0.2))
        )
    }
}

struct AddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.mindfulPrimary)
                .imageScale(.large)
                .font(.system(size: 24))
        }
    }
}

struct SaveButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Save")
                .fontWeight(.semibold)
                .foregroundColor(.mindfulPrimary)
        }
    }
}

struct MoodChartView: View {
    let entries: [MoodEntry]
    
    var body: some View {
        Chart {
            ForEach(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Mood", moodToNumeric(entry.mood))
                )
                .foregroundStyle(Color.mindfulPrimary)
                .symbol {
                    Circle()
                        .fill(Color.mindfulPrimary)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text(moodLabel(for: value.as(Int.self) ?? 3))
                        .font(.caption2)
                        .foregroundColor(.mindfulText.opacity(0.7))
                }
            }
        }
    }
    
    private func moodToNumeric(_ mood: MoodType) -> Int {
        switch mood {
        case .veryHappy: return 5
        case .happy: return 4
        case .neutral: return 3
        case .sad: return 2
        case .verySad: return 1
        }
    }
    
    private func moodLabel(for value: Int) -> String {
        switch value {
        case 5: return "Very Happy"
        case 4: return "Happy"
        case 3: return "Neutral"
        case 2: return "Sad"
        case 1: return "Very Sad"
        default: return ""
        }
    }
}

struct AddTriggerView: View {
    @Binding var triggers: [String]
    @State private var newTrigger: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                TextField("What triggered this feeling?", text: $newTrigger)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.mindfulCard) 
                    .cornerRadius(12)
                    .foregroundColor(.mindfulText)
                
                Button(action: addTrigger) {
                    Text("Add Trigger")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.mindfulPrimary)
                        )
                }
                .disabled(newTrigger.isEmpty)
                .opacity(newTrigger.isEmpty ? 0.6 : 1)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Trigger")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addTrigger() {
        if !newTrigger.isEmpty {
            triggers.append(newTrigger.trimmingCharacters(in: .whitespacesAndNewlines))
            newTrigger = ""
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    MoodTrackerView()
}
