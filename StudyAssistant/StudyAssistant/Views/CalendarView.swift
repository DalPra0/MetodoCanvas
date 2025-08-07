import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var selectedTask: StudyTask?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CalendarHeader(
                    selectedDate: $selectedDate,
                    showingDatePicker: $showingDatePicker
                )
                
                CalendarGrid(
                    selectedDate: $selectedDate,
                    tasks: viewModel.tasks,
                    courses: viewModel.courses
                )
                
                DayTasksList(
                    selectedDate: selectedDate,
                    tasks: tasksForSelectedDate,
                    courses: viewModel.courses,
                    selectedTask: $selectedTask
                )
            }
            .navigationTitle("Calendário")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDatePicker) {
                DatePicker(
                    "Selecionar Data",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .presentationDetents([.medium])
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailSheet(task: task)
            }
        }
    }
    
    private var tasksForSelectedDate: [StudyTask] {
        viewModel.tasks.filter { task in
            Calendar.current.isDate(task.dueDate, inSameDayAs: selectedDate)
        }
    }
}


struct CalendarHeader: View {
    @Binding var selectedDate: Date
    @Binding var showingDatePicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(monthYearFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(selectedDayFormatter.string(from: selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: { showingDatePicker = true }) {
                        Image(systemName: "calendar.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(-3...3, id: \.self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                        QuickDateButton(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            onTap: { selectedDate = date }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private let selectedDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter
    }()
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct QuickDateButton: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayFormatter.string(from: date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(dayNumberFormatter.string(from: date))
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
}


struct CalendarGrid: View {
    @Binding var selectedDate: Date
    let tasks: [StudyTask]
    let courses: [Course]
    
    private let calendar = Calendar.current
    private let weekdayNames = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(weekdayNames, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            tasks: tasksForDate(date),
                            courses: courses,
                            onTap: { selectedDate = date }
                        )
                    } else {
                        Color.clear
                            .frame(height: 60)
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1)
        else { return [] }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDates(inside: dateInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
            .map { calendar.isDate($0, equalTo: monthInterval.start, toGranularity: .month) ? $0 : nil }
    }
    
    private func tasksForDate(_ date: Date) -> [StudyTask] {
        tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let tasks: [StudyTask]
    let courses: [Course]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : isToday ? .blue : .primary)
                
                HStack(spacing: 2) {
                    ForEach(Array(tasks.prefix(3).enumerated()), id: \.offset) { index, task in
                        let courseColor = courses.first { $0.name == task.course }?.color ?? .blue
                        Circle()
                            .fill(courseColor)
                            .frame(width: 6, height: 6)
                    }
                    
                    if tasks.count > 3 {
                        Text("+\(tasks.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isToday && !isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


struct DayTasksList: View {
    let selectedDate: Date
    let tasks: [StudyTask]
    let courses: [Course]
    @Binding var selectedTask: StudyTask?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tarefas do Dia")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            if tasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Nenhuma tarefa para este dia")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Aproveite para descansar ou adiantar outras atividades! 🎉")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedTasks) { task in
                            CalendarTaskRow(
                                task: task,
                                courses: courses,
                                onTap: { selectedTask = task }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }
    
    private var sortedTasks: [StudyTask] {
        tasks.sorted { task1, task2 in
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted && task2.isCompleted
            }
            return task1.priority.hashValue > task2.priority.hashValue
        }
    }
}

struct CalendarTaskRow: View {
    let task: StudyTask
    let courses: [Course]
    let onTap: () -> Void
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                let courseColor = courses.first { $0.name == task.course }?.color ?? .blue
                Rectangle()
                    .fill(courseColor)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(task.priority.rawValue)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.priorityColor(from: task.priority.color).opacity(0.2))
                            .foregroundColor(Color.priorityColor(from: task.priority.color))
                            .cornerRadius(4)
                    }
                    
                    HStack {
                        Text(task.course)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(task.estimatedTime / 3600))h estimado")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if task.dueDate < Date() && !task.isCompleted {
                            Text("ATRASADA")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Button {
                    viewModel.completeTask(task)
                } label: {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4)
            )
        }
        .buttonStyle(.plain)
    }
}


struct TaskDetailSheet: View {
    let task: StudyTask
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(task.course)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(
                            icon: "calendar",
                            title: "Prazo",
                            value: DateFormatter.long.string(from: task.dueDate),
                            color: task.dueDate < Date() && !task.isCompleted ? .red : .blue
                        )
                        
                        DetailRow(
                            icon: "flag.fill",
                            title: "Prioridade",
                            value: task.priority.rawValue,
                            color: Color.priorityColor(from: task.priority.color)
                        )
                        
                        DetailRow(
                            icon: "clock",
                            title: "Tempo Estimado",
                            value: "\(Int(task.estimatedTime / 3600))h",
                            color: .purple
                        )
                        
                        if task.isCompleted, let completedAt = task.completedAt {
                            DetailRow(
                                icon: "checkmark.circle.fill",
                                title: "Concluída em",
                                value: DateFormatter.long.string(from: completedAt),
                                color: .green
                            )
                        }
                    }
                    
                    if !task.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descrição")
                                .font(.headline)
                            
                            Text(task.description)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.completeTask(task)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: task.isCompleted ? "arrow.counterclockwise" : "checkmark")
                                Text(task.isCompleted ? "Marcar como Pendente" : "Marcar como Concluída")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(task.isCompleted ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Detalhes da Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}


extension Calendar {
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(startingAfter: interval.start,
                      matching: components,
                      matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}

extension DateFormatter {
    static let long: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    CalendarView()
        .environmentObject(StudyAssistantViewModel())
}
