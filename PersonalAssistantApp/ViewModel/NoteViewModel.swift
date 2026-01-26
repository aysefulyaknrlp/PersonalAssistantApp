//
//  NoteViewModel.swift
//  PersonalAssistantApp
//
//  Created by Ayşe Fulya on 27.10.2025.
//


import Foundation
import Combine

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var errorMessage = ""
    @Published var successMessage = ""
    
    private let repository = NoteRepository()
    private let notificationManager = NotificationManager.shared
    private let nlpProcessor = NaturalLanguageProcessor()
    
    init() {
        loadNotes()
    }
    
    // MARK: - Note Operations
    
    func addNote(_ note: Note) {
        notes.insert(note, at: 0)
        saveNotes()
        
        if note.reminderDate != nil {
            notificationManager.scheduleNotification(for: note)
        }
        
        successMessage = "✅ Not eklendi: \(note.title)"
        print("✅ Not eklendi: \(note.title)")
    }
    
    func deleteNote(_ note: Note) {
        if let imagePath = note.imagePath {
            ImageManager.shared.deleteImage(at: imagePath)
        }
        
        notes.removeAll { $0.id == note.id }
        saveNotes()
        notificationManager.cancelNotification(for: note)
        
        successMessage = "🗑️ Not silindi: \(note.title)"
        print("🗑️ Not silindi: \(note.title)")
    }
    
    func toggleNoteCompletion(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isCompleted.toggle()
            
            // Tamamlandıysa bugünün tarihini kaydet
            if notes[index].isCompleted {
                notes[index].completedDate = Date()
            } else {
                notes[index].completedDate = nil
            }
            
            saveNotes()
            
            let status = notes[index].isCompleted ? "tamamlandı ✓" : "açıldı"
            print("📝 Not \(status): \(note.title)")
        }
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
            notificationManager.scheduleNotification(for: note)
        }
    }
    
    // MARK: - Voice Command Processing
    
    func processVoiceCommand(_ text: String) -> Note? {
        if let note = nlpProcessor.parseVoiceCommand(text) {
            return note
        }
        errorMessage = "❌ Komut anlaşılamadı"
        return nil
    }
    
    // MARK: - Data Management
    
    private func saveNotes() {
        repository.saveNotes(notes)
    }
    
    private func loadNotes() {
        notes = repository.loadNotes()
    }
    
    func deleteAllNotes() {
        notes.removeAll()
        repository.deleteAll()
        notificationManager.cancelAllNotifications()
        print("🗑️ Tüm notlar silindi")
    }
    
    // MARK: - Computed Properties
    
    var pendingNotesCount: Int {
        notes.filter { !$0.isCompleted }.count
    }
    
    var completedNotesCount: Int {
        notes.filter { $0.isCompleted }.count
    }
    
    // Notları tarihlere göre grupla
    var groupedNotes: [(date: Date, notes: [Note])] {
        let calendar = Calendar.current
        
        // Notları tarihlerine göre grupla
        let grouped = Dictionary(grouping: notes) { note -> Date in
            return note.noteDate
        }
        
        // Tarihe göre sırala (en yeni üstte)
        return grouped.map { (date: $0.key, notes: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    // Bugünün notları
    var todayNotes: [Note] {
        let today = Calendar.current.startOfDay(for: Date())
        return notes.filter { note in
            return note.noteDate == today
        }
    }
    
    // Gecikmiş notlar (tamamlanmamış ve bugünden önce)
    var overdueNotes: [Note] {
        let today = Calendar.current.startOfDay(for: Date())
        return notes.filter { note in
            return !note.isCompleted && note.noteDate < today
        }
    }
}
