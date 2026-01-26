//
//  HorizontalCalendarView.swift
//  PersonalAssistantApp
//
//  Created by Personal Assistant on 26.01.2026.
//

import SwiftUI

struct HorizontalCalendarView: View {
    @Binding var selectedDate: Date?
    @State private var dates: [Date] = []
    @State private var currentWeekStart: Date = Date()
    
    var body: some View {
        VStack(spacing: 12) {
            // Month Year Header
            Text(monthYearTitle)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack {
                // Previous Button
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dates, id: \.self) { date in
                            DateCell(date: date, isSelected: isSelected(date))
                                .onTapGesture {
                                    withAnimation {
                                        if isSelected(date) {
                                            selectedDate = nil
                                        } else {
                                            selectedDate = date
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
                
                // Next Button
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canGoNext ? .primary : .gray.opacity(0.3))
                        .padding(.horizontal, 8)
                }
                .disabled(!canGoNext)
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
        .onAppear {
            setupInitialWeek()
        }
    }
    
    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr-TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentWeekStart).capitalized
    }
    
    private var canGoNext: Bool {
        let calendar = Calendar.current
        let today = Date()
        
        // Find start of current week for today
        let todayComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let thisWeekStart = calendar.date(from: todayComponents) else { return false }
        
        // We can go next only if currentWeekStart is strictly before thisWeekStart
        // Note: effectively checking if currentWeekStart < thisWeekStart
        return currentWeekStart < thisWeekStart
    }
    
    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return Calendar.current.isDate(selectedDate, inSameDayAs: date)
    }
    
    private func setupInitialWeek() {
        // Find the start of the current week (Monday)
        let calendar = Calendar.current
        let today = Date()
        
        // Adjust to find Monday as start of week
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        if let monday = calendar.date(from: components) {
             self.currentWeekStart = monday
        } else {
            self.currentWeekStart = today
        }
        generateDates()
    }
    
    private func generateDates() {
        let calendar = Calendar.current
        var generatedDates: [Date] = []
        
        // We assume currentWeekStart is already set correctly to the beginning of the week we want to show
        // But `date(from: components)` might give Sunday for some locales.
        // Let's re-align currentWeekStart to the first day of the week (Monday) explicitly if needed,
        // or just trust the logic.
        // Let's force start from Monday for consistency if that's desired, or respect locale.
        // Given Turkish context, Monday (Pazartesi) is standard.
        // Let's just iterate 7 days from currentWeekStart.
        
        // Actually, let's fix the start day logic in setup to be solid.
        // Let's move this logic to a helper.
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: currentWeekStart) {
                generatedDates.append(date)
            }
        }
        
        self.dates = generatedDates
    }
    
    private func previousWeek() {
        if let newStart = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart) {
            currentWeekStart = newStart
            withAnimation {
                generateDates()
            }
        }
    }
    
    private func nextWeek() {
        if let newStart = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStart) {
            currentWeekStart = newStart
            withAnimation {
                generateDates()
            }
        }
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Text(dayString)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .secondary)
            
            Text(dayNumberString)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(isSelected ? Color.blue.opacity(0.8) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr-TR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private var dayNumberString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

#Preview {
    HorizontalCalendarView(selectedDate: .constant(Date()))
}
