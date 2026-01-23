//
//  Note.swift
//  PersonalAssistant
//
//  Models klasörüne ekle (Task.swift dosyasını sil, bunu ekle)

import Foundation
import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var completedDate: Date?
    var reminderDate: Date?
    var imagePath: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedDate: Date? = nil,
        reminderDate: Date? = nil,
        imagePath: String? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedDate = completedDate
        self.reminderDate = reminderDate
        self.imagePath = imagePath
    }
    
    // Notun hangi güne ait olduğunu belirle
    var noteDate: Date {
        // Eğer tamamlandıysa, tamamlanma tarihine ait
        if let completed = completedDate {
            return Calendar.current.startOfDay(for: completed)
        }
        // Tamamlanmadıysa, oluşturulma tarihine ait
        return Calendar.current.startOfDay(for: createdAt)
    }
}