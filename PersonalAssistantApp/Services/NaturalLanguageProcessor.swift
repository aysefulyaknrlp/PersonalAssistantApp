//
//  NaturalLanguageProcessor.swift
//  PersonalAssistantApp
//
//  Services klasörüne ekle

import Foundation

class NaturalLanguageProcessor {
    
    func parseVoiceCommand(_ text: String) -> Note? {
        let lowercased = text.lowercased()
        
        let reminderDate = detectReminderDate(from: lowercased)
        let noteTitle = cleanNoteTitle(from: text)
        
        guard !noteTitle.isEmpty else {
            print("⚠️ Not başlığı boş")
            return nil
        }
        
        let note = Note(title: noteTitle, reminderDate: reminderDate)
        print("🎤 Sesli komut işlendi: '\(note.title)'")
        
        return note
    }
    
    // MARK: - Private Methods
    
    private func detectReminderDate(from text: String) -> Date? {
        if text.contains("yarın") {
            return createDate(daysFromNow: 1, hour: 9, minute: 0)
        }
        else if text.contains("bugün") || text.contains("bu gün") {
            return createDate(daysFromNow: 0, hour: 18, minute: 0)
        }
        else if text.contains("gelecek hafta") || text.contains("önümüzdeki hafta") {
            return createDate(daysFromNow: 7, hour: 9, minute: 0)
        }
        else if text.contains("pazartesi") {
            return nextWeekday(.monday)
        }
        else if text.contains("salı") {
            return nextWeekday(.tuesday)
        }
        else if text.contains("çarşamba") {
            return nextWeekday(.wednesday)
        }
        else if text.contains("perşembe") {
            return nextWeekday(.thursday)
        }
        else if text.contains("cuma") {
            return nextWeekday(.friday)
        }
        else if text.contains("cumartesi") {
            return nextWeekday(.saturday)
        }
        else if text.contains("pazar") {
            return nextWeekday(.sunday)
        }
        
        return nil
    }
    
    private func cleanNoteTitle(from text: String) -> String {
        var noteTitle = text
        
        let removeWords = [
            "ekle", "görev", "hatırlat", "hatırlatma", "yarın", "bugün", "bu gün",
            "acil", "önemli", "hemen", "düşük öncelik", "acele değil",
            "gelecek hafta", "önümüzdeki hafta", "pazartesi", "salı", "çarşamba",
            "perşembe", "cuma", "cumartesi", "pazar", "önemli değil", "lütfen",
            "add", "task", "remind", "tomorrow", "today", "urgent", "important",
            "not"
        ]
        
        for word in removeWords {
            noteTitle = noteTitle.replacingOccurrences(
                of: word,
                with: "",
                options: .caseInsensitive
            )
        }
        
        noteTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        noteTitle = noteTitle.trimmingCharacters(in: .punctuationCharacters)
        
        return noteTitle
    }
    
    private func createDate(daysFromNow: Int, hour: Int, minute: Int) -> Date? {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        components.day! += daysFromNow
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }
    
    private func nextWeekday(_ weekday: Weekday) -> Date? {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let targetWeekday = weekday.rawValue
        
        var daysToAdd = targetWeekday - today
        if daysToAdd <= 0 {
            daysToAdd += 7
        }
        
        guard let futureDate = calendar.date(byAdding: .day, value: daysToAdd, to: Date()) else {
            return nil
        }
        
        var components = calendar.dateComponents([.year, .month, .day], from: futureDate)
        components.hour = 9
        components.minute = 0
        
        return calendar.date(from: components)
    }
    
    enum Weekday: Int {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }
}
