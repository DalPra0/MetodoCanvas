import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    let preselectedCourse: String?
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var selectedCourse = ""
    @State private var priority = StudyTask.Priority.medium
    @State private var estimatedTime: Double = 60
    
    init(preselectedCourse: String? = nil) {
        self.preselectedCourse = preselectedCourse
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Básicas") {
                    TextField("Título da tarefa", text: $title)
                    TextField("Descrição", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Detalhes") {
                    DatePicker("Data de entrega", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    if !viewModel.courses.isEmpty {
                        Picker("Matéria", selection: $selectedCourse) {
                            Text("Selecione uma matéria").tag("")
                            ForEach(viewModel.courses, id: \.name) { course in
                                Text(course.name).tag(course.name)
                            }
                        }
                        .disabled(preselectedCourse != nil)
                    } else {
                        TextField("Nome da matéria", text: $selectedCourse)
                    }
                    
                    Picker("Prioridade", selection: $priority) {
                        ForEach(StudyTask.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    HStack {
                        Text("Tempo estimado")
                        Spacer()
                        Text("\(Int(estimatedTime)) min")
                    }
                    Slider(value: $estimatedTime, in: 15...240, step: 15)
                }
            }
            .navigationTitle("Nova Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let preselected = preselectedCourse {
                    selectedCourse = preselected
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        saveTask()
                    }
                    .disabled(title.isEmpty || selectedCourse.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        let task = StudyTask(
            title: title,
            description: description,
            dueDate: dueDate,
            course: selectedCourse,
            priority: priority,
            estimatedTime: estimatedTime * 60
        )
        
        viewModel.addTask(task)
        dismiss()
    }
}
