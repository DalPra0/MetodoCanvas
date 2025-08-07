import SwiftUI

struct TasksView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    @State private var showingAddTask = false
    @State private var selectedFilter: TaskFilter = .all
    
    enum TaskFilter: String, CaseIterable {
        case all = "Todas"
        case pending = "Pendentes"
        case completed = "Concluídas"
        case overdue = "Atrasadas"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filtro", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    ForEach(filteredTasks) { task in
                        TaskRow(task: task)
                            .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Tarefas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
    private var filteredTasks: [StudyTask] {
        switch selectedFilter {
        case .all:
            return viewModel.tasks
        case .pending:
            return viewModel.tasks.filter { !$0.isCompleted && $0.dueDate >= Date() }
        case .completed:
            return viewModel.tasks.filter { $0.isCompleted }
        case .overdue:
            return viewModel.overdueTasks
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteTask(filteredTasks[index])
        }
    }
}


struct TaskRow: View {
    let task: StudyTask
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.priorityColor(from: task.priority.color))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                HStack {
                    Text(task.course)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(task.dueDate < Date() && !task.isCompleted ? .red : .secondary)
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
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}
