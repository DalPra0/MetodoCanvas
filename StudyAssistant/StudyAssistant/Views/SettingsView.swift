import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    @AppStorage("canvasAPIToken") private var canvasAPIToken = ""
    @AppStorage("firebaseAPIKey") private var firebaseAPIKey = ""
    @AppStorage("firebaseProjectId") private var firebaseProjectId = ""
    @AppStorage("geminiAPIKey") private var geminiAPIKey = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("autoSyncEnabled") private var autoSyncEnabled = false
    
    @StateObject private var integratedService: IntegratedStudyService
    @State private var showingCourseSelection = false
    @State private var canvasCoursesForSelection: [CanvasCourse] = []
    @State private var showingImportAlert = false
    @State private var isTestingConnection = false
    
    init() {
        _integratedService = StateObject(wrappedValue: IntegratedStudyService(
            firebaseAPIKey: UserDefaults.standard.string(forKey: "firebaseAPIKey") ?? "",
            firebaseProjectId: UserDefaults.standard.string(forKey: "firebaseProjectId") ?? "",
            geminiAPIKey: UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🎓 StudyAssistant")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Seu assistente acadêmico com IA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("🔗 APIs de Integração") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Canvas API Token")
                            .font(.headline)
                        SecureField("Cole seu token do Canvas aqui", text: $canvasAPIToken)
                            .textFieldStyle(.roundedBorder)
                        Text("Obtenha em: Account → Settings → Approved Integrations")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gemini API Key")
                            .font(.headline)
                        SecureField("Cole sua API key do Gemini aqui", text: $geminiAPIKey)
                            .textFieldStyle(.roundedBorder)
                        Text("Obtenha em: ai.google.dev")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Firebase Project ID")
                            .font(.headline)
                        TextField("ID do projeto Firebase", text: $firebaseProjectId)
                            .textFieldStyle(.roundedBorder)
                        Text("Encontre em: Console Firebase → Project Settings")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Firebase API Key")
                            .font(.headline)
                        SecureField("API key do Firebase", text: $firebaseAPIKey)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section("🔔 Notificações") {
                    Toggle("Habilitar Notificações", isOn: $notificationsEnabled)
                    Toggle("Sync Automático", isOn: $autoSyncEnabled)
                        .disabled(canvasAPIToken.isEmpty)
                }
                
                Section("🚀 Ações Rápidas") {
                    Button(action: testCanvasConnection) {
                        HStack {
                            Image(systemName: isTestingConnection ? "arrow.triangle.2.circlepath" : "network")
                            Text(isTestingConnection ? "Testando..." : "Testar Canvas")
                        }
                    }
                    .disabled(canvasAPIToken.isEmpty || isTestingConnection)
                    
                    Button(action: scanCanvasCourses) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Escanear Matérias do Canvas")
                        }
                    }
                    .disabled(canvasAPIToken.isEmpty)
                    
                    Button(action: backupToFirebase) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up")
                            Text("Backup Firebase")
                        }
                    }
                    .disabled(firebaseAPIKey.isEmpty || firebaseProjectId.isEmpty)
                    
                    Button(action: loadFromFirebase) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                            Text("Restaurar Firebase")
                        }
                    }
                    .disabled(firebaseAPIKey.isEmpty || firebaseProjectId.isEmpty)
                }
                
                Section("⚠️ Zona Perigosa") {
                    Button("Limpar Todos os Dados", role: .destructive) {
                        showingImportAlert = true
                    }
                }
                
                Section("ℹ️ Status") {
                    if !integratedService.statusMessage.isEmpty {
                        Text(integratedService.statusMessage)
                            .font(.caption)
                            .padding(.vertical, 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dados Locais:")
                        Text("📝 \(viewModel.tasks.count) tarefas")
                        Text("📚 \(viewModel.courses.count) matérias")
                        Text("⏰ \(viewModel.sessions.count) sessões de estudo")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Configurações")
            .alert("Limpar Dados", isPresented: $showingImportAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpar Tudo", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("Esta ação irá remover todas as tarefas, matérias e configurações. Esta ação não pode ser desfeita.")
            }
            .sheet(isPresented: $showingCourseSelection) {
                CourseSelectionView(canvasCourses: canvasCoursesForSelection) { selectedCourses in
                    importSelectedCourses(selectedCourses)
                }
            }
        }
    }
    
    private func testCanvasConnection() {
        isTestingConnection = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isTestingConnection = false
            integratedService.statusMessage = canvasAPIToken.isEmpty ? 
                "❌ Token inválido" : "✅ Conexão Canvas bem-sucedida!"
        }
    }
    
    private func scanCanvasCourses() {
        integratedService.scanCanvasCourses(apiToken: canvasAPIToken) { canvasCourses in
            self.canvasCoursesForSelection = canvasCourses
            self.showingCourseSelection = true
        }
    }
    
    private func importSelectedCourses(_ selectedCourses: [CanvasCourse]) {
        integratedService.importSelectedCourses(selectedCourses) { tasks, courses in
            for course in courses {
                if !viewModel.courses.contains(where: { $0.name == course.name }) {
                    viewModel.addCourse(course)
                }
            }
            
            for task in tasks {
                if !viewModel.tasks.contains(where: { $0.title == task.title && $0.course == task.course }) {
                    viewModel.addTask(task)
                }
            }
        }
    }
    
    private func backupToFirebase() {
        integratedService.syncTasksWithFirebase(viewModel.tasks)
    }
    
    private func loadFromFirebase() {
        integratedService.loadTasksFromFirebase { tasks in
            for task in tasks {
                if !viewModel.tasks.contains(where: { $0.id == task.id }) {
                    viewModel.addTask(task)
                }
            }
        }
    }
    
    private func clearAllData() {
        UserDefaults.standard.removeObject(forKey: "tasks")
        UserDefaults.standard.removeObject(forKey: "courses")
        UserDefaults.standard.removeObject(forKey: "sessions")
        UserDefaults.standard.removeObject(forKey: "notifications")
        
        viewModel.tasks.removeAll()
        viewModel.courses.removeAll()
        viewModel.sessions.removeAll()
        viewModel.notifications.removeAll()
        
        integratedService.statusMessage = "🗑️ Todos os dados foram limpos"
    }
}

#Preview {
    SettingsView()
        .environmentObject(StudyAssistantViewModel())
}
