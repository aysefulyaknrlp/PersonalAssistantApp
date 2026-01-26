//
//  DailyTasksView.swift
//  PersonalAssistant
//
//  Created by Ayşe Fulya on 27.10.2025.
//

import SwiftUI

struct DailyTasksView: View {
    @ObservedObject var viewModel: NoteViewModel
    @State private var selectedDate: Date? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal Calendar
            HorizontalCalendarView(selectedDate: $selectedDate)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
                .zIndex(1)
            
            if viewModel.groupedNotes.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if let selected = selectedDate {
                            // Show specific date
                            if let notesForDate = notes(for: selected), !notesForDate.isEmpty {
                                DailyTaskSection(
                                    date: selected,
                                    tasks: notesForDate,
                                    onToggle: { task in viewModel.toggleNoteCompletion(task) },
                                    onDelete: { task in viewModel.deleteNote(task) },
                                    viewModel: viewModel
                                )
                            } else {
                                // No notes for selected date
                                checkmarkEmptyView
                            }
                        } else {
                            // Show all dates (original behavior)
                            ForEach(viewModel.groupedNotes, id: \.date) { group in
                                DailyTaskSection(
                                    date: group.date,
                                    tasks: group.notes,
                                    onToggle: { task in viewModel.toggleNoteCompletion(task) },
                                    onDelete: { task in viewModel.deleteNote(task) },
                                    viewModel: viewModel
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Henüz not yok")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Not ekleyerek başlayın")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var checkmarkEmptyView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.4))
            Text("Bu tarih için planlanmış not yok")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
    
    private func notes(for date: Date) -> [Note]? {
        let calendar = Calendar.current
        // Find the group that matches the date
        return viewModel.groupedNotes.first { group in
            calendar.isDate(group.date, inSameDayAs: date)
        }?.notes
    }
}

struct DailyTaskSection: View {
    let date: Date
    let tasks: [Note]
    let onToggle: (Note) -> Void
    let onDelete: (Note) -> Void
    let viewModel: NoteViewModel?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tarih Başlığı
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(fullDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Tamamlanma istatistiği
                Text("\(completedCount)/\(tasks.count)")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(progressColor.opacity(0.2))
                    .foregroundColor(progressColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 4)
            
            // Notlar
            VStack(spacing: 10) {
                ForEach(tasks) { task in
                    NoteRowView(
                        note: task,
                        onToggle: { onToggle(task) },
                        onDelete: { onDelete(task) },
                        viewModel: viewModel
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var dateTitle: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "Bugün"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Dün"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "tr-TR")
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }
    
    private var fullDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr-TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private var progressColor: Color {
        let percentage = Double(completedCount) / Double(tasks.count)
        if percentage == 1.0 {
            return .green
        } else if percentage >= 0.5 {
            return .orange
        } else {
            return .blue
        }
    }
}

#Preview {
    DailyTasksView(viewModel: NoteViewModel())
}
