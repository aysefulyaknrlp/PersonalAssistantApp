//
//  AddTaskView.swift
//  PersonalAssistant
//
//  Views klasörüne ekle

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            Form {
                Section("Not Detayı") {
                    TextField("Ne yapılacak?", text: $title)
                }
                
                Section("Fotoğraf") {
                    if let image = selectedImage {
                        VStack(spacing: 10) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button(action: { selectedImage = nil }) {
                                Label("Fotoğrafı Kaldır", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        Button(action: { showActionSheet = true }) {
                            Label("Fotoğraf Ekle", systemImage: "camera")
                        }
                    }
                }
                
                Section("Hatırlatma") {
                    Toggle("Hatırlatma Ekle", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("Tarih ve Saat", selection: $reminderDate, in: Date()...)
                            .environment(\.locale, Locale(identifier: "tr-TR"))
                    }
                }
            }
            .navigationTitle("Yeni Not")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") { addTask() }
                        .disabled(title.isEmpty)
                }
            }
            .confirmationDialog("Fotoğraf Ekle", isPresented: $showActionSheet) {
                Button("Kamera") {
                    sourceType = .camera
                    showImagePicker = true
                }
                Button("Galeri") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
                Button("İptal", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
        }
    }
    
    private func addTask() {
        var imagePath: String?
        if let image = selectedImage {
            imagePath = ImageManager.shared.saveImage(image)
        }
        
        let note = Note(
            title: title,
            reminderDate: hasReminder ? reminderDate : nil,
            imagePath: imagePath
        )
        
        viewModel.addNote(note)
        dismiss()
    }
}

#Preview {
    AddTaskView(viewModel: NoteViewModel())
}
