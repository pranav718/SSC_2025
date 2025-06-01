//
//  GratitudeJournalView.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 25/01/25.
//

import SwiftUI

struct GratitudeJournalView: View {
    @EnvironmentObject private var viewModel: MindfulnessViewModel
    @State private var gratitudePrompts = [
        "What made you smile today?",
        "Name three things you're thankful for.",
        "Who made a positive impact on your day?",
        "What's something you're looking forward to?",
        "What's a small win you had today?"
    ]
    @State private var currentEntry: String = ""
    @State private var entries: [GratitudeEntry] = []
    @State private var streak: Int = 0
    @State private var currentPrompt: String = ""
    @State private var showingEntryDetail = false
    @State private var selectedEntry: GratitudeEntry?
    @State private var feedback: String = ""
    @State private var showAlert = false
    
    init() {
        _currentPrompt = State(initialValue: gratitudePrompts.randomElement() ?? "")
        if let savedEntries = UserDefaults.standard.data(forKey: "gratitudeEntries"),
           let decodedEntries = try? JSONDecoder().decode([GratitudeEntry].self, from: savedEntries) {
            _entries = State(initialValue: decodedEntries)
        }
    }
    
    
    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("CURRENT STREAK")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.mindfulText.opacity(0.7))
                            Text("\(streak) days")
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .foregroundColor(.mindfulText)
                        }
                        
                        Spacer()
                        
                        LinearGradient(gradient: Gradient(colors: [Color.mindfulPrimary, Color.mindfulSecondary]),
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
                            .mask(Image(systemName: "flame.fill")
                                .font(.system(size: 44, weight: .bold)))
                            .padding(.trailing, 8)
                    }
                    .padding(.leading, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.mindfulCard)
                    .cornerRadius(20)
                    .shadow(color: Color.mindfulShadow, radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Text("MINDFUL MOMENT")
                                .font(.system(.headline, design: .rounded))
                            Image(systemName: "sparkles")
                        }
                        .foregroundColor(Color.mindfulPrimary)
                        
                        Text(currentPrompt)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.mindfulText.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.mindfulCard)
                            .cornerRadius(15)
                        
                        TextEditor(text: $currentEntry)
                            .scrollContentBackground(.hidden)
                            .frame(height: 150)
                            .padding()
                            .background(Color.mindfulCard)
                            .cornerRadius(15)
                            .foregroundColor(.mindfulText)
                            .tint(Color.mindfulPrimary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.mindfulAccent.opacity(0.2), lineWidth: 1)
                            )
                        
                        Button(action: saveEntry) {
                            HStack {
                                Text("Save Today's Entry")
                                    .font(.system(.headline, design: .rounded))
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.mindfulPrimary, Color.mindfulSecondary]),
                                                     startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color.mindfulShadow, radius: 10, y: 5)
                        }
                        .disabled(currentEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hasEntryToday())
                        .buttonStyle(ScaleButtonStyle())
                        
                        FeedbackView(feedback: $feedback)
                        
                    }
                    .padding()
                    .background(Color.mindfulBackground)

                VStack(alignment: .leading) {
                        Text("PREVIOUS ENTRIES")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.mindfulText.opacity(0.8))
                            .padding(.horizontal)
                        
                        ForEach(entries.reversed()) { entry in
                            EntryCard(entry: entry, onDelete: { deleteEntry(entry)} )
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .onTapGesture {
                                    self.selectedEntry = entry
                                    self.showingEntryDetail = true
                                }
                        }
                    }
                }
                .padding(.vertical)
            }
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationTitle("Gratitude Journal")
            .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Entry Already Saved"),
                        message: Text("You've already saved an entry for today."),
                        dismissButton: .default(Text("OK"))
                    )
            }
        }
        .accentColor(Color.mindfulPrimary)
    }

    func saveEntry() {
        let trimmedEntry = currentEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEntry.isEmpty else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if entries.contains(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            showAlert = true
            return
        }
        
        let sentiment = SentimentAnalyzer.analyzeSentiment(text: trimmedEntry)
        let feedback: String
        
        switch sentiment {
        case "positive":
            feedback = "Your entry sounds positive! Keep it up!"
        case "negative":
            feedback = "It seems like you're feeling down. Would you like to try a breathing exercise?"
        default:
            feedback = "Your entry is neutral. Reflect on what made you feel this way."
        }
        
        self.feedback = feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.feedback = ""
            }
        }
        
        let entry = GratitudeEntry(
            id: UUID(),
            date: Date(),
            entries: [trimmedEntry],
            prompt: currentPrompt
        )
        
        entries.append(entry)
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "gratitudeEntries")
        }
        
        currentEntry = ""
        currentPrompt = gratitudePrompts.randomElement() ?? ""
        updateStreak()
        
    }
    
    func hasEntryToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return entries.contains(where: { calendar.isDate($0.date, inSameDayAs: today) } )
    }
    
    func updateStreak() {
        streak += 1
    }
    
    func deleteEntry(_ entry: GratitudeEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id} ) {
            entries.remove(at: index)
        }
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "gratitudeEntries")
        }
            
    }
    
}

struct FeedbackView: View {
    @Binding var feedback: String
    
    var body: some View {
        if !feedback.isEmpty {
            Text(feedback)
                .font(.subheadline)
                .foregroundColor(.mindfulPrimary)
                .padding()
                .background(Color.mindfulCard)
                .cornerRadius(12)
                .shadow(color: Color.mindfulShadow, radius: 5, x: 0, y: 2)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: feedback)
        }
    }
}

struct EntryCard: View {
    let entry: GratitudeEntry
    var onDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.date, style: .date)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.mindfulText.opacity(0.7))
                
                Spacer()
                
                Button(action: {
                    onDelete?()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            
            Text(entry.entries[0])
                .font(.system(.body, design: .rounded))
                .foregroundColor(.mindfulText.opacity(0.9))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(.mindfulPrimary)
                Text("Tap to view full entry")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.mindfulText.opacity(0.6))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mindfulCard)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.mindfulAccent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.mindfulShadow, radius: 8, x: 0, y: 5)
    }
}

struct EntryDetailView: View {
    let entry: GratitudeEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text(entry.date, style: .date)
                        .font(.system(.title2, design: .rounded).bold())
                        .foregroundColor(.mindfulText)
                        .padding(.bottom, 8)
      
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TODAY'S PROMPT")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.mindfulPrimary.opacity(0.8))
                            .padding(.bottom, 4)
                        
                        Text(entry.prompt)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.mindfulText.opacity(0.9))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.mindfulCard)
                            .cornerRadius(15)
                            .shadow(color: Color.mindfulShadow.opacity(0.1), radius: 5, x: 0, y: 3)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR RESPONSE")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.mindfulPrimary.opacity(0.8))
                            .padding(.bottom, 4)
                        
                        ForEach(entry.entries, id: \.self) { text in
                            Text(text)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.mindfulText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.mindfulCard)
                                .cornerRadius(15)
                                .shadow(color: Color.mindfulShadow.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                    }
                }
                .padding()
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.mindfulPrimary)
                    }
                }
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    GratitudeJournalView()
}
