//
//  DailyTasksView.swift
//  PersonalAssistant
//
//  Views klasörüne ekle

import SwiftUI

struct DailyTasksView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.groupedTasks, id: \.date) { group in
                    DailyTaskSection(
                        date: group.date,
                        tasks: group.tasks,
                        onToggle: { task in
                            viewModel.toggleTaskCompletion(task)
                        },
                        onDelete: { task in
                            viewModel.deleteTask(task)
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct DailyTaskSection: View {
    let date: Date
    let tasks: [Task]
    let onToggle: (Task) -> Void
    let onDelete: (Task) -> Void
    
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
            
            // Görevler
            VStack(spacing: 10) {
                ForEach(tasks) { task in
                    TaskRowView(
                        task: task,
                        onToggle: { onToggle(task) },
                        onDelete: { onDelete(task) }
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
    DailyTasksView(viewModel: TaskViewModel())
}