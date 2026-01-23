//
//  UserManager.swift
//  PersonalAssistantApp
//
//  Created by Ayşe Fulya on 20.10.2025.
//


import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var userName: String = ""
    @Published var isFirstLaunch: Bool = true
    
    private let userNameKey = "UserName"
    
    private init() {
        loadUserData()
    }
    
    func saveUserName(_ name: String) {
        userName = name
        isFirstLaunch = false
        
        UserDefaults.standard.set(name, forKey: userNameKey)
        
        print("✅ Kullanıcı adı kaydedildi: \(name)")
    }
    
    private func loadUserData() {
        // Eğer kullanıcı adı varsa, isFirstLaunch = false
        if let savedName = UserDefaults.standard.string(forKey: userNameKey), !savedName.isEmpty {
            userName = savedName
            isFirstLaunch = false
            print("👤 Hoş geldin, \(userName)!")
        } else {
            // Kullanıcı adı yoksa, ilk açılış
            isFirstLaunch = true
            print("🆕 İlk açılış - kullanıcı adı sorulacak")
        }
    }
    
    func resetUser() {
        userName = ""
        isFirstLaunch = true
        UserDefaults.standard.removeObject(forKey: userNameKey)
        print("🔄 Kullanıcı sıfırlandı")
    }
}
