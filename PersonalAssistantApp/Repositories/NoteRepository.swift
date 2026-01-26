//
//  NoteRepository.swift
//  PersonalAssistantApp
//
//  Created by Ayşe Fulya on 27.10.2025.
//

import Foundation

class NoteRepository {
    private let saveKey = "SavedNotes"
    
    func saveNotes(_ notes: [Note]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encoded = try encoder.encode(notes)
            
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("✅ Notlar kaydedildi: \(notes.count) not")
        } catch {
            print("❌ Not kaydetme hatası: \(error.localizedDescription)")
        }
    }
    
    func loadNotes() -> [Note] {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            print("📂 Hiç not yok")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([Note].self, from: data)
            print("📂 \(decoded.count) not yüklendi")
            return decoded
        } catch {
            print("❌ Not yükleme hatası: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: saveKey)
        print("🗑️ Tüm notlar silindi")
    }
}
