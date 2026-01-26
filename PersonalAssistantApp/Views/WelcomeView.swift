//
//  WelcomeView.swift
//  PersonalAssistant
//
//  Created by Ayşe Fulya on 27.10.2025.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var userManager: UserManager
    @State private var name: String = ""
    @State private var showError: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                
                // Title
                VStack(spacing: 10) {
                    Text("Hoş Geldiniz!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Kişisel asistanınıza adınızla başlayalım")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Name Input
                VStack(spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                        
                        TextField("", text: $name, prompt: Text("Adınızı girin").foregroundColor(.gray))
                            .padding()
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .accentColor(.blue)
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                saveAndContinue()
                            }
                    }
                    .frame(height: 55)
                    .padding(.horizontal, 40)
                    
                    if showError {
                        Text("Lütfen adınızı girin")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.9))
                    }
                }
                
                // Continue Button
                Button(action: {
                    isTextFieldFocused = false
                    saveAndContinue()
                }) {
                    Text("Başlayalım")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
    }
    
    private func saveAndContinue() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            showError = true
            withAnimation {
                showError = true
            }
            return
        }
        
        showError = false
        userManager.saveUserName(trimmedName)
    }
}

#Preview {
    WelcomeView(userManager: UserManager.shared)
}
