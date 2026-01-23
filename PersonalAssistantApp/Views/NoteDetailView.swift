//
//  NoteDetailView.swift
//  PersonalAssistant
//
//  Views klasörüne ekle

import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteViewModel
    let note: Note
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var hasReminder: Bool
    @State private var reminderDate: Date
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(viewModel: NoteViewModel, note: Note) {
        self.viewModel = viewModel
        self.note = note
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
        _hasReminder = State(initialValue: note.reminderDate != nil)
        _reminderDate = State(initialValue: note.reminderDate ?? Date())
        
        if let imagePath = note.imagePath,
           let image = ImageManager.shared.loadImage(from: imagePath) {
            _selectedImage = State(initialValue: image)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Not Başlığı") {
                    TextField("Başlık", text: $title)
                }
                
                Section("İçerik") {
                    TextField("Detaylar", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Fotoğraf") {
                    if let image = selectedImage {
                        VStack(spacing: 10) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button(action: { 
                                selectedImage = nil
                            }) {
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
            .navigationTitle("Notu Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { saveNote() }
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
    
    private func saveNote() {
        var imagePath = note.imagePath
        
        // Yeni fotoğraf varsa kaydet
        if let image = selectedImage, imagePath == nil {
            imagePath = ImageManager.shared.saveImage(image)
        }
        
        // Eski fotoğraf kaldırıldıysa sil
        if selectedImage == nil && note.imagePath != nil {
            ImageManager.shared.deleteImage(at: note.imagePath!)
            imagePath = nil
        }
        
        let updatedNote = Note(
            id: note.id,
            title: title,
            content: content,
            isCompleted: note.isCompleted,
            createdAt: note.createdAt,
            completedDate: note.completedDate,
            reminderDate: hasReminder ? reminderDate : nil,
            imagePath: imagePath
        )
        
        viewModel.updateNote(updatedNote)
        dismiss()
    }
}

#Preview {
    NoteDetailView(
        viewModel: NoteViewModel(),
        note: Note(title: "Örnek Not", content: "Bu bir örnek not içeriğidir", reminderDate: Date())
    )
}



