import SwiftUI
import UniformTypeIdentifiers

struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    @AppStorage("geminiAPIKey") private var geminiAPIKey = ""
    
    @State private var showingDocumentPicker = false
    @State private var showingTaskCreation = false
    @State private var showingCourseEditor = false
    @State private var isAnalyzingPDF = false
    @State private var analysisResult: SyllabusAnalysis?
    @State private var statusMessage = ""
    @State private var selectedTab = 0
    
    @StateObject private var integratedService: IntegratedStudyService
    
    init(course: Course) {
        self.course = course
        _integratedService = StateObject(wrappedValue: IntegratedStudyService(
            firebaseAPIKey: UserDefaults.standard.string(forKey: "firebaseAPIKey") ?? "",
            firebaseProjectId: UserDefaults.standard.string(forKey: "firebaseProjectId") ?? "",
            geminiAPIKey: UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CourseHeroSection(course: course)
                
                TabSelector(selectedTab: $selectedTab)
                
                TabView(selection: $selectedTab) {
                    OverviewTab(
                        course: course,
                        courseTasks: courseTasks,
                        analysisResult: analysisResult,
                        onUploadPDF: { showingDocumentPicker = true },
                        onAddTask: { showingTaskCreation = true },
                        isAnalyzing: isAnalyzingPDF,
                        statusMessage: statusMessage
                    )
                    .tag(0)
                    
                    TasksTab(
                        courseTasks: courseTasks,
                        onAddTask: { showingTaskCreation = true }
                    )
                    .tag(1)
                    
                    AnalyticsTab(course: course, courseTasks: courseTasks)
                    .tag(2)
                    
                    DocumentsTab(
                        course: course,
                        analysisResult: analysisResult,
                        onUploadPDF: { showingDocumentPicker = true },
                        isAnalyzing: isAnalyzingPDF,
                        statusMessage: statusMessage
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 600)
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Editar Matéria") {
                        showingCourseEditor = true
                    }
                    
                    Button("Nova Tarefa") {
                        showingTaskCreation = true
                    }
                    
                    Button("Upload PDF") {
                        showingDocumentPicker = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker { url in
                processPDF(from: url)
            }
        }
        .sheet(isPresented: $showingTaskCreation) {
            AddTaskView(preselectedCourse: course.name)
        }
        .sheet(isPresented: $showingCourseEditor) {
            EditCourseView(course: course)
        }
    }
    
    private var courseTasks: [StudyTask] {
        viewModel.tasks.filter { $0.course == course.name }
    }
    
    private func processPDF(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            statusMessage = "❌ Erro ao acessar arquivo"
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            statusMessage = "📄 Processando PDF..."
            isAnalyzingPDF = true
            
            integratedService.analyzeAndAddSyllabus(pdfData: data) { analysis in
                DispatchQueue.main.async {
                    self.isAnalyzingPDF = false
                    if let analysis = analysis {
                        self.analysisResult = analysis
                        self.statusMessage = "✅ PDF analisado com sucesso!"
                        
                        self.createTasksFromAnalysis(analysis)
                    } else {
                        self.statusMessage = "❌ Erro ao analisar PDF"
                    }
                }
            }
        } catch {
            statusMessage = "❌ Erro ao ler arquivo: \(error.localizedDescription)"
            isAnalyzingPDF = false
        }
    }
    
    private func createTasksFromAnalysis(_ analysis: SyllabusAnalysis) {
        for importantDate in analysis.importantDates {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            guard let dueDate = dateFormatter.date(from: importantDate.date) else { continue }
            
            let task = StudyTask(
                title: importantDate.event,
                description: "Criado automaticamente da análise do plano de ensino",
                dueDate: dueDate,
                course: course.name,
                priority: determinePriorityFromWeight(importantDate.weight),
                estimatedTime: TimeInterval(importantDate.weight * 60)
            )
            
            viewModel.addTask(task)
        }
    }
    
    private func determinePriorityFromWeight(_ weight: Int) -> StudyTask.Priority {
        switch weight {
        case 40...100: return .urgent
        case 20...39: return .high
        case 10...19: return .medium
        default: return .low
        }
    }
}


struct CourseHeroSection: View {
    let course: Course
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [course.color, course.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text(String(course.name.prefix(2)).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .shadow(radius: 10)
            
            VStack(spacing: 8) {
                Text(course.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Text(course.code)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("Prof. \(course.professor)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [course.color.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}


struct TabSelector: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("Visão Geral", "house.fill"),
        ("Tarefas", "checklist"),
        ("Analytics", "chart.bar.fill"),
        ("Documentos", "doc.fill")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    VStack(spacing: 6) {
                        Image(systemName: tab.1)
                            .font(.system(size: 18))
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                        
                        Text(tab.0)
                            .font(.caption)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = index
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
}


struct OverviewTab: View {
    let course: Course
    let courseTasks: [StudyTask]
    let analysisResult: SyllabusAnalysis?
    let onUploadPDF: () -> Void
    let onAddTask: () -> Void
    let isAnalyzing: Bool
    let statusMessage: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(
                        title: "Pendentes",
                        value: "\(courseTasks.filter { !$0.isCompleted }.count)",
                        color: .orange,
                        icon: "clock"
                    )
                    
                    StatCard(
                        title: "Concluídas",
                        value: "\(courseTasks.filter { $0.isCompleted }.count)",
                        color: .green,
                        icon: "checkmark.circle"
                    )
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    QuickActionButton(
                        title: "Nova Tarefa",
                        icon: "plus.circle.fill",
                        color: .blue,
                        action: onAddTask
                    )
                    
                    QuickActionButton(
                        title: "Upload PDF",
                        icon: "doc.badge.plus",
                        color: .green,
                        action: onUploadPDF
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct TasksTab: View {
    let courseTasks: [StudyTask]
    let onAddTask: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(courseTasks.count) Tarefas")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Nova", action: onAddTask)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if courseTasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Nenhuma tarefa cadastrada")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(courseTasks) { task in
                            SimpleTaskRow(task: task)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            
            Spacer()
        }
    }
}

struct AnalyticsTab: View {
    let course: Course
    let courseTasks: [StudyTask]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Analytics da Matéria")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(course.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(completionRate * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(course.color)
                        Text("Concluído")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private var completionRate: Double {
        guard !courseTasks.isEmpty else { return 0.0 }
        let completedCount = courseTasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(courseTasks.count)
    }
}

struct DocumentsTab: View {
    let course: Course
    let analysisResult: SyllabusAnalysis?
    let onUploadPDF: () -> Void
    let isAnalyzing: Bool
    let statusMessage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Documentos da Matéria")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Button(action: onUploadPDF) {
                HStack(spacing: 12) {
                    if isAnalyzing {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Analisando...")
                    } else {
                        Image(systemName: "doc.badge.plus")
                        Text("Upload PDF")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isAnalyzing)
            .padding(.horizontal)
            
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            if let analysis = analysisResult {
                SyllabusAnalysisView(analysis: analysis)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
}


struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct SimpleTaskRow: View {
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
                
                Text(task.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
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

struct SyllabusAnalysisView: View {
    let analysis: SyllabusAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🧠 Análise do Plano")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !analysis.topics.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📚 Tópicos (\(analysis.topics.count))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                        ForEach(analysis.topics.prefix(6), id: \.self) { topic in
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            if !analysis.importantDates.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📅 Datas Importantes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(analysis.importantDates.prefix(3), id: \.event) { date in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(date.event)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(date.date)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(date.weight)%")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.onDocumentPicked(url)
            }
        }
    }
}

#Preview {
    CourseDetailView(course: Course(
        name: "Banco de Dados",
        code: "BD-2024",
        professor: "Dr. Silva",
        colorHex: "#007AFF"
    ))
    .environmentObject(StudyAssistantViewModel())
}
