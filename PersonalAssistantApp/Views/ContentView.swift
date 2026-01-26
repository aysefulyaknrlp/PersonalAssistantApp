//
//  ContentView.swift
//  PersonalAssistant
//
//  Created by Ayşe Fulya on 27.10.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NoteViewModel()
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var userManager = UserManager.shared
    
    @State private var showingAddTask = false
    @State private var showingVoiceInput = false
    @State private var showingNameEdit = false
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if userManager.isFirstLaunch {
                WelcomeView(userManager: userManager)
            } else {
                mainTabView
            }
        }
        .onAppear {
            speechManager.requestPermission()
            NotificationManager.shared.requestPermission()
            NotificationManager.shared.clearBadges()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Uygulama her aktif olduğunda bildirim rozetlerini temizle
            NotificationManager.shared.clearBadges()
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // Bugün Sekmesi
            todayView
                .tabItem {
                    Label("Bugün", systemImage: "house.fill")
                }
                .tag(0)
            
            // Takvim Sekmesi
            calendarView
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }
                .tag(1)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingVoiceInput) {
            VoiceInputView(
                speechManager: speechManager,
                viewModel: viewModel,
                isPresented: $showingVoiceInput
            )
        }
        .sheet(isPresented: $showingNameEdit) {
            EditNameView(
                currentName: userManager.userName,
                onSave: { name in
                    userManager.saveUserName(name)
                }
            )
        }
    }
    
    // MARK: - Bugün View
    private var todayView: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    HeaderView(
                        userName: userManager.userName,
                        pendingCount: viewModel.todayNotes.filter { !$0.isCompleted }.count,
                        onEditName: { showingNameEdit = true }
                    )
                    
                    // Content
                    if viewModel.todayNotes.isEmpty {
                        EmptyStateView()
                    } else {
                        NoteListView(
                            notes: viewModel.todayNotes,
                            viewModel: viewModel,
                            onToggle: { note in
                                viewModel.toggleNoteCompletion(note)
                            },
                            onDelete: { note in
                                viewModel.deleteNote(note)
                            }
                        )
                    }
                }
                
                // Floating Buttons
                FloatingActionButtons(
                    onVoicePressed: { showingVoiceInput = true },
                    onAddPressed: { showingAddTask = true }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Takvim View
    private var calendarView: some View {
        NavigationView {
            DailyTasksView(viewModel: viewModel)
                .navigationTitle("Takvim")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let userName: String
    let pendingCount: Int
    let onEditName: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Merhaba, \(userName)! 👋")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Bugün \(pendingCount) notunuz var")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onEditName) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Henüz not yok")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Aşağıdaki butonu kullanarak not ekleyin")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Floating Action Buttons
struct FloatingActionButtons: View {
    let onVoicePressed: () -> Void
    let onAddPressed: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 16) {
                // Voice Button
                Button(action: onVoicePressed) {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.purple)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                // Add Button
                Button(action: onAddPressed) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
            .padding()
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
    ContentView()
}
