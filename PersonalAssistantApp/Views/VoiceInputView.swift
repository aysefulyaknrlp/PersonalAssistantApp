//
//  VoiceInputView.swift
//  PersonalAssistant
//
 

import SwiftUI

struct VoiceInputView: View {
    @ObservedObject var speechManager: SpeechManager
    @ObservedObject var viewModel: NoteViewModel
    @Binding var isPresented: Bool
    
    @State private var taskPreview: Note?
    @State private var editableText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Sesli Komut")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            // Recognized Text Box
            VStack(spacing: 12) {
                if speechManager.recognizedText.isEmpty && !isEditing {
                    Text("Dinliyorum...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(height: 120)
                } else {
                    VStack(spacing: 8) {
                        TextField("Not yazın veya sesli komut verin", text: $editableText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3...6)
                            .focused($isTextFieldFocused)
                            .disabled(speechManager.isRecording)
                            .onChange(of: editableText) { oldValue, newValue in
                                if !speechManager.isRecording {
                                    // Metin değiştiğinde preview'i güncelle
                                    updatePreview(from: newValue)
                                }
                            }
                        
                        if !speechManager.isRecording && !editableText.isEmpty {
                            Button(action: {
                                editableText = ""
                                taskPreview = nil
                                isTextFieldFocused = false
                            }) {
                                Text("Temizle")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .onTapGesture {
                if !speechManager.isRecording {
                    isTextFieldFocused = true
                    isEditing = true
                }
            }
            
            // Task Preview
            if let task = taskPreview {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Not Önizlemesi")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            if let reminderDate = task.reminderDate {
                                Label(formatDate(reminderDate), systemImage: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Record Button
            Button(action: {
                if speechManager.isRecording {
                    speechManager.stopRecording()
                    isTextFieldFocused = false
                    // Sesli komut bittikten sonra işle
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        editableText = speechManager.recognizedText
                        updatePreview(from: editableText)
                    }
                } else {
                    taskPreview = nil
                    isTextFieldFocused = false
                    isEditing = false
                    speechManager.startRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(speechManager.isRecording ? Color.red : Color.blue)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            
            // Add Task Button
            if let task = taskPreview {
                Button(action: {
                    viewModel.addNote(task)
                    speechManager.reset()
                    editableText = ""
                    taskPreview = nil
                    isPresented = false
                }) {
                    Text("Notu Ekle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            // Close Button
            Button(action: {
                speechManager.stopRecording()
                speechManager.reset()
                editableText = ""
                taskPreview = nil
                isPresented = false
            }) {
                Text("Kapat")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .padding()
        .onAppear {
            editableText = speechManager.recognizedText
        }
    }
    
    private func updatePreview(from text: String) {
        if !text.isEmpty {
            if let note = viewModel.processVoiceCommand(text) {
                taskPreview = note
            }
        } else {
            taskPreview = nil
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr-TR")
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    VoiceInputView(
        speechManager: SpeechManager(),
        viewModel: NoteViewModel(),
        isPresented: .constant(true)
    )
}
