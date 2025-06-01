//
//  Entries.swift
//  SomeAnimations
//
//  Created by Pranav Ray on 25/01/25.
//

import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: MoodType
    let notes: String
    let triggers: [String]
}

enum MoodType: String, CaseIterable, Codable {
    case veryHappy = "Very Happy"
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
    case verySad = "Very Sad"
    
    var emoji: String {
        switch self {
        case .veryHappy: return "😊"
        case .happy: return "🙂"
        case .neutral: return "😐"
        case .sad: return "🙁"
        case .verySad: return "😢"
        }
    }
}

struct GratitudeEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let entries: [String]
    let prompt: String
}

struct Affirmation: Identifiable, Codable {
    let id: UUID
    let text: String
    let category: String
    var isFavorite: Bool
}

class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    
    private enum StorageKey: String {
        case moodEntries
        case gratitudeEntries
        case affirmations
        case gratitudeStreak
        case lastGratitudeDate
    }
    
    func saveMoodEntries(_ entries: [MoodEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: StorageKey.moodEntries.rawValue)
        }
    }
    
    func loadMoodEntries() -> [MoodEntry] {
        guard let data = userDefaults.data(forKey: StorageKey.moodEntries.rawValue),
              let entries = try? JSONDecoder().decode([MoodEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func saveGratitudeEntries(_ entries: [GratitudeEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: StorageKey.gratitudeEntries.rawValue)
        }
    }
    
    func loadGratitudeEntries() -> [GratitudeEntry] {
        guard let data = userDefaults.data(forKey: StorageKey.gratitudeEntries.rawValue),
              let entries = try? JSONDecoder().decode([GratitudeEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func saveAffirmations(_ affirmations: [Affirmation]) {
        if let encoded = try? JSONEncoder().encode(affirmations) {
            userDefaults.set(encoded, forKey: StorageKey.affirmations.rawValue)
        }
    }
    
    func loadAffirmations() -> [Affirmation] {
        guard let data = userDefaults.data(forKey: StorageKey.affirmations.rawValue),
              let affirmations = try? JSONDecoder().decode([Affirmation].self, from: data) else {
            return []
        }
        return affirmations
    }
    
    func updateGratitudeStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDateData = userDefaults.object(forKey: StorageKey.lastGratitudeDate.rawValue) as? Date {
            let lastDate = calendar.startOfDay(for: lastDateData)
            let streak = userDefaults.integer(forKey: StorageKey.gratitudeStreak.rawValue)
            
            if calendar.isDate(lastDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!) {
                let newStreak = streak + 1
                userDefaults.set(newStreak, forKey: StorageKey.gratitudeStreak.rawValue)
                userDefaults.set(today, forKey: StorageKey.lastGratitudeDate.rawValue)
                return newStreak
            } else if !calendar.isDate(lastDate, inSameDayAs: today) {
                userDefaults.set(1, forKey: StorageKey.gratitudeStreak.rawValue)
                userDefaults.set(today, forKey: StorageKey.lastGratitudeDate.rawValue)
                return 1
            }
            return streak
        } else {
            userDefaults.set(1, forKey: StorageKey.gratitudeStreak.rawValue)
            userDefaults.set(today, forKey: StorageKey.lastGratitudeDate.rawValue)
            return 1
        }
    }
}

class MindfulnessViewModel: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    @Published var gratitudeEntries: [GratitudeEntry] = []
    @Published var affirmations: [Affirmation] = []
    @Published var gratitudeStreak: Int = 0
    
    private let storageManager = StorageManager.shared
    
    init() {
        loadData()
    }
    
    private func loadData() {
        moodEntries = storageManager.loadMoodEntries()
        gratitudeEntries = storageManager.loadGratitudeEntries()
        affirmations = storageManager.loadAffirmations()
    }
    
    func saveMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
        storageManager.saveMoodEntries(moodEntries)
    }
    
    func saveGratitudeEntry(_ entry: GratitudeEntry) {
        gratitudeEntries.append(entry)
        storageManager.saveGratitudeEntries(gratitudeEntries)
        gratitudeStreak = storageManager.updateGratitudeStreak()
    }
    
    func hasGratitudeEntryToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return gratitudeEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: today) })
    }
    
    func saveAffirmation(_ affirmation: Affirmation) {
        affirmations.append(affirmation)
        storageManager.saveAffirmations(affirmations)
    }
    
    func toggleAffirmationFavorite(_ id: UUID) {
        if let index = affirmations.firstIndex(where: { $0.id == id }) {
            affirmations[index].isFavorite.toggle()
            storageManager.saveAffirmations(affirmations)
        }
    }
    
    func deleteAffirmation(_ id: UUID) {
        affirmations.removeAll(where: { $0.id == id })
        storageManager.saveAffirmations(affirmations)
    }
}


