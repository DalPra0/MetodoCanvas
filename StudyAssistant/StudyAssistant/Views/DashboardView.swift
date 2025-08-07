import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    @State private var showingAddTask = false
    @State private var showingAddCourse = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(todayFormatted)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "brain.head.profile")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            )
                            .shadow(radius: 5)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        DashboardStatCard(
                            title: "Próximas",
                            value: "\(viewModel.upcomingTasks.count)",
                            subtitle: "tarefas",
                            color: .blue,
                            icon: "clock.arrow.circlepath"
                        )
                        
                        DashboardStatCard(
                            title: "Atrasadas",
                            value: "\(viewModel.overdueTasks.count)",
                            subtitle: "urgentes",
                            color: .red,
                            icon: "exclamationmark.triangle"
                        )
                        
                        DashboardStatCard(
                            title: "Concluídas",
                            value: "\(viewModel.completedTasksThisWeek.count)",
                            subtitle: "esta semana",
                            color: .green,
                            icon: "checkmark.circle"
                        )
                        
                        DashboardStatCard(
                            title: "Tempo",
                            value: formatStudyTime(viewModel.studyTimeThisWeek),
                            subtitle: "estudado",
                            color: .purple,
                            icon: "timer"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("⚡ Ações Rápidas")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            DashboardActionButton(
                                title: "Nova Tarefa",
                                subtitle: "Adicionar assignment",
                                icon: "plus.circle.fill",
                                color: .blue,
                                action: { showingAddTask = true }
                            )
                            
                            DashboardActionButton(
                                title: "Nova Matéria",
                                subtitle: "Cadastrar curso",
                                icon: "book.circle.fill",
                                color: .green,
                                action: { showingAddCourse = true }
                            )
                        }
                    }
                    
                    if !viewModel.overdueTasks.isEmpty || !viewModel.upcomingTasks.prefix(3).isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🚨 Requer Atenção")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                ForEach(viewModel.overdueTasks.prefix(2)) { task in
                                    DashboardTaskRow(task: task, isOverdue: true)
                                }
                                
                                ForEach(Array(viewModel.upcomingTasks.prefix(3))) { task in
                                    DashboardTaskRow(task: task, isOverdue: false)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationTitle("StudyAssistant")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(isPresented: $showingAddCourse) {
            AddCourseView()
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bom dia! 🌅"
        case 12..<18: return "Boa tarde! ☀️"
        default: return "Boa noite! 🌙"
        }
    }
    
    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter.string(from: Date()).capitalized
    }
    
    private func formatStudyTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        if hours == 0 {
            return "0h"
        }
        return "\(hours)h"
    }
}


struct DashboardStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct DashboardActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct DashboardTaskRow: View {
    let task: StudyTask
    let isOverdue: Bool
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isOverdue ? Color.red : Color.priorityColor(from: task.priority.color))
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    if isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(task.course)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(timeUntilDue(task.dueDate))
                        .font(.caption)
                        .foregroundColor(isOverdue ? .red : .secondary)
                }
            }
            
            Spacer()
            
            Button {
                viewModel.completeTask(task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOverdue ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 4)
    }
    
    private func timeUntilDue(_ date: Date) -> String {
        let now = Date()
        let interval = date.timeIntervalSince(now)
        
        if interval < 0 {
            return "Atrasada"
        }
        
        let days = Int(interval) / 86400
        let hours = Int(interval.truncatingRemainder(dividingBy: 86400)) / 3600
        
        if days > 0 {
            return "em \(days)d"
        } else if hours > 0 {
            return "em \(hours)h"
        } else {
            return "hoje"
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(StudyAssistantViewModel())
}
