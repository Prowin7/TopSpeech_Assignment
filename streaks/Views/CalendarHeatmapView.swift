import SwiftUI

/// Calendar heatmap showing practice history with color-coded days
struct CalendarHeatmapView: View {
    @ObservedObject var viewModel: StreakViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.tsPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.tsPrimary.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(viewModel.selectedMonth.monthYear)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.tsPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.tsPrimary.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                // Leading empty cells
                ForEach(0..<viewModel.selectedMonth.firstWeekdayOfMonth, id: \.self) { _ in
                    Color.clear
                        .frame(height: 36)
                }
                
                // Day cells
                ForEach(viewModel.selectedMonth.datesInMonth(), id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        practiceDay: viewModel.streakData.practiceDays[date.dateKey],
                        isToday: date.isToday,
                        isFuture: date > Date()
                    )
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .tsSubtle.opacity(0.2), text: "No practice")
                LegendItem(color: .tsPrimary, text: "Practiced")
                LegendItem(color: .tsFreeze, text: "Freeze used")
            }
            .font(.caption2)
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Practice calendar for \(viewModel.selectedMonth.monthYear)")
    }
    
    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            }
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let practiceDay: PracticeDay?
    let isToday: Bool
    let isFuture: Bool
    
    var body: some View {
        Text("\(date.dayOfMonth)")
            .font(.caption)
            .fontWeight(isToday ? .bold : .regular)
            .foregroundColor(foregroundColor)
            .frame(height: 36)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.tsPrimary : Color.clear, lineWidth: 2)
            )
            .opacity(isFuture ? 0.3 : 1.0)
            .accessibilityLabel(accessibilityText)
    }
    
    private var backgroundColor: Color {
        guard !isFuture else { return .clear }
        
        if let day = practiceDay {
            if day.didPractice {
                return .tsPrimary.opacity(0.8)
            } else if day.usedFreeze {
                return .tsFreeze.opacity(0.5)
            }
        }
        
        return isToday ? Color.tsPrimary.opacity(0.1) : Color.tsSubtle.opacity(0.1)
    }
    
    private var foregroundColor: Color {
        if let day = practiceDay, (day.didPractice || day.usedFreeze) {
            return .white
        }
        return .primary
    }
    
    private var accessibilityText: String {
        let dateStr = date.shortDate
        if let day = practiceDay {
            if day.didPractice { return "\(dateStr): practiced" }
            if day.usedFreeze { return "\(dateStr): freeze used" }
        }
        return "\(dateStr): no practice"
    }
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}
