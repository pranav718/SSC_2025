//
//  AffirmationsView.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 25/01/25.
//


import CoreData
import SwiftUI

struct AffirmationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var viewModel: MindfulnessViewModel
    @State private var affirmations: [Affirmation] = []
    @State private var categories: [String] = ["Self-Love", "Success", "Health", "Relationships"]
    @State private var selectedCategory: String = "All"
    @State private var showingAddSheet = false
    @State private var newAffirmationText = ""
    @State private var newAffirmationCategory = "Self-Love"

    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.mindfulBackground, Color.mindfulBackground.opacity(0.9)]),
        startPoint: .top,
        endPoint: .bottom
    )

    let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color.mindfulCard, Color.mindfulCard]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var sortedAffirmations: [Affirmation] {
        affirmations.sorted { $0.isFavorite && !$1.isFavorite }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryButton(title: "All", isSelected: selectedCategory == "All")
                                .onTapGesture { selectedCategory = "All" }
                            
                            ForEach(categories, id: \.self) { category in
                                CategoryButton(title: category, isSelected: selectedCategory == category)
                                    .onTapGesture { selectedCategory = category }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sortedAffirmations) { affirmation in
                                if selectedCategory == "All" || affirmation.category == selectedCategory {
                                    AffirmationCard(affirmation: binding(for: affirmation))
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Daily Affirmations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color.mindfulText)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddAffirmationSheet(
                isPresented: $showingAddSheet,
                affirmationText: $newAffirmationText,
                category: $newAffirmationCategory,
                categories: categories,
                onSave: saveNewAffirmation
            )
        }
    }
    
    private func binding(for affirmation: Affirmation) -> Binding<Affirmation> {
        guard let index = affirmations.firstIndex(where: { $0.id == affirmation.id }) else {
            fatalError("Affirmation not found")
        }
        return $affirmations[index]
    }
    
    func saveNewAffirmation() {
        let affirmation = Affirmation(
            id: UUID(),
            text: newAffirmationText,
            category: newAffirmationCategory,
            isFavorite: false
        )
        affirmations.append(affirmation)
        newAffirmationText = ""
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(.subheadline, design: .rounded, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.mindfulPrimary : Color.mindfulCard)
                    .overlay(
                        Capsule()
                            .stroke(Color.mindfulAccent.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? .white : Color.mindfulText.opacity(0.7))
    }
}

struct AffirmationCard: View {
    @Binding var affirmation: Affirmation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(affirmation.text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.mindfulText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
            
            HStack {
                Text(affirmation.category)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.mindfulPrimary.opacity(0.2))
                    )
                    .foregroundColor(.mindfulPrimary)
                
                Spacer()
                
                Image(systemName: affirmation.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(affirmation.isFavorite ? .yellow : .mindfulPrimary)
                    .font(.system(.body, weight: .medium))
                    .onTapGesture {
                        affirmation.isFavorite.toggle()
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mindfulCard)
                .shadow(color: Color.mindfulShadow, radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mindfulAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct AddAffirmationSheet: View {
    @Binding var isPresented: Bool
    @Binding var affirmationText: String
    @Binding var category: String
    let categories: [String]
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.mindfulBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Affirmation")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.mindfulText)
                        
                        TextEditor(text: $affirmationText)
                            .scrollContentBackground(.hidden)
                            .frame(height: 120)
                            .padding()
                            .background(Color.mindfulCard)
                            .cornerRadius(12)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.mindfulText)
                            .tint(Color.mindfulPrimary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.mindfulAccent.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.mindfulText)
                        
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .foregroundColor(.mindfulText)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Affirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.mindfulPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        isPresented = false
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(.mindfulPrimary)
                }
            }
        }
    }
}



#Preview {
    AffirmationsView()
}
