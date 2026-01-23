//
//  ProfileView.swift
//  PersonalAssistant
//
//  Views klasörüne ekle

import SwiftUI

struct ProfileView: View {
    @StateObject private var userManager = UserManager.shared
    @StateObject private var viewModel = TaskViewModel()
    
    @State private var showingNameEdit = false
    @State private var newName = ""
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                // Profil Bölümü
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userManager.userName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Kullanıcı")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                // Ayarlar
                Section("Ayarlar") {
                    Button(action: {
                        newName = userManager.userName
                        showingNameEdit = true
                    }) {
                        Label("İsmi Değiştir", systemImage: "pencil")
                    }
                }
                
                // İstatistikler
                Section("İstatistikler") {
                    HStack {
                        Text("Toplam Görev")
                        Spacer()
                        Text("\(viewModel.tasks.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Tamamlanan")
                        Spacer()
                        Text("\(viewModel.completedTasksCount)")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Bekleyen")
                        Spacer()
                        Text("\(viewModel.pendingTasksCount)")
                            .foregroundColor(.orange)
                    }
                }
                
                // Tehlikeli Alan
                Section("Veri Yönetimi") {
                    Button(role: .destructive, action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Tüm Görevleri Sil", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showingNameEdit) {
                EditNameView(
                    currentName: userManager.userName,
                    onSave: { name in
                        userManager.saveUserName(name)
                    }
                )
            }
            .alert("Tüm Görevleri Sil", isPresented: $showingDeleteConfirmation) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    viewModel.deleteAllTasks()
                }
            } message: {
                Text("Bu işlem geri alınamaz. Tüm görevleriniz silinecek.")
            }
        }
    }
}

// MARK: - Edit Name View
struct EditNameView: View {
    @Environment(\.dismiss) var dismiss
    let currentName: String
    let onSave: (String) -> Void
    
    @State private var name: String
    @FocusState private var isFocused: Bool
    
    init(currentName: String, onSave: @escaping (String) -> Void) {
        self.currentName = currentName
        self.onSave = onSave
        _name = State(initialValue: currentName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("İsim") {
                    TextField("Adınız", text: $name)
                        .focused($isFocused)
                }
            }
            .navigationTitle("İsmi Değiştir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            onSave(trimmed)
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}

#Preview {
    ProfileView()
}