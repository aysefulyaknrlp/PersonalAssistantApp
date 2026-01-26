//
//  NotificationManager.swift
//  PersonalAssistant
//
// Created by Ayşe Fulya on 27.10.2025.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("✅ Bildirim izni verildi")
            } else {
                print("❌ Bildirim izni reddedildi")
            }
        }
    }
    
    func scheduleNotification(for note: Note) {
        guard let reminderDate = note.reminderDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Hatırlatma"
        content.body = note.title
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: note.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Bildirim eklenirken hata: \(error.localizedDescription)")
            } else {
                print("📬 Bildirim planlandı: \(note.title)")
            }
        }
    }
    
    func cancelNotification(for note: Note) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [note.id.uuidString]
        )
        print("🔕 Bildirim iptal edildi: \(note.title)")
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("🔕 Tüm bildirimler iptal edildi")
    }
    
    // Bildirim rozetlerini temizle (uygulama açıldığında)
    func clearBadges() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("📭 Bildirim rozetleri temizlendi")
    }
}
