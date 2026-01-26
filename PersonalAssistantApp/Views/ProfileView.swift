//
//  ProfileView.swift
//  PersonalAssistant
//
//  Created by Ayşe Fulya on 27.10.2025.
//

import SwiftUI
import Photos

struct ProfileView: View {
    @StateObject private var userManager = UserManager.shared
    @StateObject private var viewModel = NoteViewModel()
    
    @State private var showingNameEdit = false
    @State private var newName = ""
    @State private var showingDeleteConfirmation = false
    @State private var photoPermissionStatus = "Bilinmiyor"
    
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
                
                // İzinler
                Section("İzinler") {
                    HStack {
                        Label("Galeri Erişimi", systemImage: "photo")
                        Spacer()
                        Text(photoPermissionStatus)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    if photoPermissionStatus != "İzin Verildi" {
                        Button(action: {
                            requestPhotoPermission()
                        }) {
                            Text("İzin İste")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Tehlikeli Alan
                Section("Veri Yönetimi") {
                    Button(role: .destructive, action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Tüm Notları Sil", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Profil")
            .onAppear {
                checkPhotoPermission()
            }
            .sheet(isPresented: $showingNameEdit) {
                EditNameView(
                    currentName: userManager.userName,
                    onSave: { name in
                        userManager.saveUserName(name)
                    }
                )
            }
            .alert("Tüm Notları Sil", isPresented: $showingDeleteConfirmation) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    viewModel.deleteAllNotes()
                }
            } message: {
                Text("Bu işlem geri alınamaz. Tüm notlarınız silinecek.")
            }
        }
    }
    
    private func checkPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            photoPermissionStatus = "İzin Verildi"
        case .denied:
            photoPermissionStatus = "Reddedildi"
        case .notDetermined:
            photoPermissionStatus = "Belirlenmedi"
        case .restricted:
            photoPermissionStatus = "Kısıtlı"
        @unknown default:
            photoPermissionStatus = "Bilinmiyor"
        }
    }
    
    private func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                checkPhotoPermission()
            }
        }
    }
}

#Preview {
    ProfileView()
}
