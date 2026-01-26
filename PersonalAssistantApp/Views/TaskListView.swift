//
//  TaskListView.swift
//  PersonalAssistant
//
//  Created by Ayşe Fulya on 27.10.2025.
//

import SwiftUI

struct TaskListView: View {
    let tasks: [Note]
    let onToggle: (Note) -> Void
    let onDelete: (Note) -> Void
    
    var body: some View {
        NoteListView(notes: tasks, onToggle: onToggle, onDelete: onDelete)
    }
}

struct NoteListView: View {
    let notes: [Note]
    let viewModel: NoteViewModel?
    let onToggle: (Note) -> Void
    let onDelete: (Note) -> Void
    
    init(notes: [Note], viewModel: NoteViewModel? = nil, onToggle: @escaping (Note) -> Void, onDelete: @escaping (Note) -> Void) {
        self.notes = notes
        self.viewModel = viewModel
        self.onToggle = onToggle
        self.onDelete = onDelete
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(notes) { note in
                    NoteRowView(
                        note: note,
                        onToggle: { onToggle(note) },
                        onDelete: { onDelete(note) },
                        viewModel: viewModel
                    )
                }
            }
            .padding()
        }
    }
}

struct NoteRowView: View {
    let note: Note
    let onToggle: () -> Void
    let onDelete: () -> Void
    let viewModel: NoteViewModel?
    @State private var showImageFullScreen = false
    @State private var showNoteDetail = false
    
    init(note: Note, onToggle: @escaping () -> Void, onDelete: @escaping () -> Void, viewModel: NoteViewModel? = nil) {
        self.note = note
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(note.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.body)
                    .strikethrough(note.isCompleted)
                    .foregroundColor(note.isCompleted ? .secondary : .primary)
                
                if let reminderDate = note.reminderDate {
                    Label(formatDate(reminderDate), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let imagePath = note.imagePath,
               let image = ImageManager.shared.loadImage(from: imagePath) {
                Button(action: { showImageFullScreen = true }) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            if viewModel != nil {
                showNoteDetail = true
            }
        }
        .sheet(isPresented: $showImageFullScreen) {
            if let imagePath = note.imagePath,
               let image = ImageManager.shared.loadImage(from: imagePath) {
                ImageDetailView(image: image, taskTitle: note.title)
            }
        }
        .sheet(isPresented: $showNoteDetail) {
            if let viewModel = viewModel {
                NoteDetailView(viewModel: viewModel, note: note)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr-TR")
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: date)
    }
}

// Keep backward compatibility alias
typealias TaskRowView = NoteRowView

struct ImageDetailView: View {
    let image: UIImage
    let taskTitle: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            .navigationTitle(taskTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    TaskListView(
        tasks: [
            Note(title: "Markete git", reminderDate: Date()),
            Note(title: "Rapor hazırla"),
            Note(title: "Spor yap", isCompleted: true)
        ],
        onToggle: { _ in },
        onDelete: { _ in }
    )
}

