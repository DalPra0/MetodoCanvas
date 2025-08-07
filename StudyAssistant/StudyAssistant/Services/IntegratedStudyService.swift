import Foundation
import Combine

class IntegratedStudyService: ObservableObject {
    @Published var isProcessingCanvas = false
    @Published var isProcessingPDF = false
    @Published var isGeneratingPlan = false
    @Published var statusMessage = ""
    
    private let canvasService = CanvasService()
    private let firebaseService: FirebaseService
    private let geminiService: GeminiService
    private let pdfService = PDFService()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(firebaseAPIKey: String, firebaseProjectId: String, geminiAPIKey: String) {
        self.firebaseService = FirebaseService(apiKey: firebaseAPIKey, projectId: firebaseProjectId)
        self.geminiService = GeminiService(apiKey: geminiAPIKey)
    }
    
    
    func syncWithCanvas(apiToken: String, completion: @escaping ([StudyTask], [Course]) -> Void) {
        guard !apiToken.isEmpty else {
            statusMessage = "⚠️ Token do Canvas é obrigatório"
            completion([], [])
            return
        }
        
        isProcessingCanvas = true
        statusMessage = "🔄 Conectando com Canvas..."
        canvasService.setAPIToken(apiToken)
        
        canvasService.fetchCourses()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    self?.isProcessingCanvas = false
                    switch completionResult {
                    case .finished:
                        self?.statusMessage = "✅ Sync com Canvas concluído!"
                    case .failure(let error):
                        self?.statusMessage = "❌ Erro no Canvas: \(error.localizedDescription)"
                        completion([], [])
                    }
                },
                receiveValue: { [weak self] canvasCourses in
                    self?.processCanvasCourses(canvasCourses, completion: completion)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processCanvasCourses(_ canvasCourses: [CanvasCourse], completion: @escaping ([StudyTask], [Course]) -> Void) {
        statusMessage = "📚 Processando matérias..."
        
        let validCanvasCourses = canvasCourses.filter { $0.isValid }
        
        print("✅ Cursos válidos encontrados: \(validCanvasCourses.count)/\(canvasCourses.count)")
        
        let convertedCourses = validCanvasCourses.map { canvasCourse in
            Course(
                name: canvasCourse.name ?? "Curso Sem Nome",
                code: canvasCourse.courseCode ?? "N/A",
                professor: "Professor",
                colorHex: self.generateRandomColor(),
                canvasID: String(canvasCourse.id)
            )
        }
        
        let dispatchGroup = DispatchGroup()
        var allTasks: [StudyTask] = []
        
        for canvasCourse in validCanvasCourses {
            dispatchGroup.enter()
            
            canvasService.fetchAssignments(for: String(canvasCourse.id))
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in
                        dispatchGroup.leave()
                    },
                    receiveValue: { assignments in
                        let courseTasks = assignments.map { assignment in
                            StudyTask(
                                title: assignment.name,
                                description: assignment.description ?? "Importado do Canvas",
                                dueDate: assignment.dueDate ?? Date().addingTimeInterval(86400),
                                course: canvasCourse.name ?? "Curso Sem Nome",
                                priority: self.determinePriority(for: assignment.dueDate),
                                estimatedTime: 3600,
                                canvasID: String(assignment.id)
                            )
                        }
                        allTasks.append(contentsOf: courseTasks)
                    }
                )
                .store(in: &cancellables)
        }
        
        dispatchGroup.notify(queue: .main) {
            self.statusMessage = "🎉 Importou \(allTasks.count) tarefas e \(convertedCourses.count) matérias!"
            completion(allTasks, convertedCourses)
        }
    }
    
    
    func analyzeAndAddSyllabus(pdfData: Data, completion: @escaping (SyllabusAnalysis?) -> Void) {
        guard !pdfData.isEmpty else {
            statusMessage = "⚠️ PDF vazio ou inválido"
            completion(nil)
            return
        }
        
        isProcessingPDF = true
        statusMessage = "📄 Extraindo texto do PDF..."
        
        pdfService.extractTextFromPDFData(pdfData)
            .flatMap { [weak self] text -> AnyPublisher<SyllabusAnalysis, Error> in
                guard let self = self else {
                    return Fail(error: IntegratedError.serviceUnavailable)
                        .eraseToAnyPublisher()
                }
                
                self.statusMessage = "🧠 Analisando conteúdo com IA..."
                return self.geminiService.analyzeSyllabus(text)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    self?.isProcessingPDF = false
                    switch completionResult {
                    case .finished:
                        self?.statusMessage = "✅ Análise do PDF concluída!"
                    case .failure(let error):
                        self?.statusMessage = "❌ Erro na análise: \(error.localizedDescription)"
                        completion(nil)
                    }
                },
                receiveValue: { analysis in
                    completion(analysis)
                }
            )
            .store(in: &cancellables)
    }
    
    
    func generateWeeklyStudyPlan(for tasks: [StudyTask], completion: @escaping (StudyPlan?) -> Void) {
        guard !tasks.isEmpty else {
            statusMessage = "⚠️ Adicione algumas tarefas primeiro"
            completion(nil)
            return
        }
        
        isGeneratingPlan = true
        statusMessage = "🧠 IA gerando plano personalizado..."
        
        geminiService.generateStudyPlan(for: tasks)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    self?.isGeneratingPlan = false
                    switch completionResult {
                    case .finished:
                        self?.statusMessage = "✅ Plano de estudos gerado!"
                    case .failure(let error):
                        self?.statusMessage = "❌ Erro ao gerar plano: \(error.localizedDescription)"
                        completion(nil)
                    }
                },
                receiveValue: { plan in
                    completion(plan)
                }
            )
            .store(in: &cancellables)
    }
    
    
    func syncTasksWithFirebase(_ tasks: [StudyTask]) {
        guard !tasks.isEmpty else { return }
        
        statusMessage = "☁️ Sincronizando com Firebase..."
        
        let syncPublishers = tasks.map { task in
            firebaseService.saveTask(task)
        }
        
        Publishers.MergeMany(syncPublishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    switch completionResult {
                    case .finished:
                        self?.statusMessage = "✅ Todas as tarefas sincronizadas com Firebase"
                    case .failure(let error):
                        self?.statusMessage = "❌ Erro no Firebase: \(error.localizedDescription)"
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func loadTasksFromFirebase(completion: @escaping ([StudyTask]) -> Void) {
        statusMessage = "☁️ Carregando dados do Firebase..."
        
        firebaseService.fetchTasks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    switch completionResult {
                    case .finished:
                        self?.statusMessage = "✅ Dados carregados do Firebase"
                    case .failure(let error):
                        self?.statusMessage = "❌ Erro ao carregar: \(error.localizedDescription)"
                        completion([])
                    }
                },
                receiveValue: { tasks in
                    completion(tasks)
                }
            )
            .store(in: &cancellables)
    }
    
    
    private func determinePriority(for dueDate: Date?) -> StudyTask.Priority {
        guard let dueDate = dueDate else { return .medium }
        
        let now = Date()
        let timeInterval = dueDate.timeIntervalSince(now)
        let daysUntilDue = timeInterval / 86400
        
        switch daysUntilDue {
        case ...1: return .urgent
        case 1...3: return .high
        case 3...7: return .medium
        default: return .low
        }
    }
    
    private func generateRandomColor() -> String {
        let colors = [
            "#007AFF", "#34C759", "#FF9500", "#FF3B30",
            "#AF52DE", "#FF2D92", "#5AC8FA", "#FFCC00"
        ]
        return colors.randomElement() ?? "#007AFF"
    }
    
    
    func scanCanvasCourses(apiToken: String, completion: @escaping ([CanvasCourse]) -> Void) {
        guard !apiToken.isEmpty else {
            statusMessage = "⚠️ Token do Canvas é obrigatório"
            completion([])
            return
        }
        
        isProcessingCanvas = true
        statusMessage = "🔍 Escaneando matérias do Canvas..."
        canvasService.setAPIToken(apiToken)
        
        canvasService.fetchCourses()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionResult in
                    self?.isProcessingCanvas = false
                    switch completionResult {
                    case .finished:
                        self?.statusMessage = "✅ Matérias encontradas!"
                    case .failure(let error):
                        self?.statusMessage = "❌ Erro no Canvas: \(error.localizedDescription)"
                        completion([])
                    }
                },
                receiveValue: { canvasCourses in
                    let validCourses = canvasCourses.filter { $0.isValid }
                    completion(validCourses)
                }
            )
            .store(in: &cancellables)
    }
    
    func importSelectedCourses(_ selectedCourses: [CanvasCourse], completion: @escaping ([StudyTask], [Course]) -> Void) {
        guard !selectedCourses.isEmpty else {
            statusMessage = "⚠️ Nenhuma matéria selecionada"
            completion([], [])
            return
        }
        
        statusMessage = "📚 Importando \(selectedCourses.count) matérias..."
        
        let convertedCourses = selectedCourses.map { canvasCourse in
            Course(
                name: canvasCourse.name ?? "Curso Sem Nome",
                code: canvasCourse.courseCode ?? "N/A",
                professor: "Professor",
                colorHex: self.generateRandomColor(),
                canvasID: String(canvasCourse.id)
            )
        }
        
        let dispatchGroup = DispatchGroup()
        var allTasks: [StudyTask] = []
        
        for canvasCourse in selectedCourses {
            dispatchGroup.enter()
            
            canvasService.fetchAssignments(for: String(canvasCourse.id))
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in
                        dispatchGroup.leave()
                    },
                    receiveValue: { assignments in
                        let courseTasks = assignments.map { assignment in
                            StudyTask(
                                title: assignment.name,
                                description: assignment.description ?? "Importado do Canvas",
                                dueDate: assignment.dueDate ?? Date().addingTimeInterval(86400),
                                course: canvasCourse.name ?? "Curso Sem Nome",
                                priority: self.determinePriority(for: assignment.dueDate),
                                estimatedTime: 3600,
                                canvasID: String(assignment.id)
                            )
                        }
                        allTasks.append(contentsOf: courseTasks)
                    }
                )
                .store(in: &cancellables)
        }
        
        dispatchGroup.notify(queue: .main) {
            self.statusMessage = "🎉 Importou \(allTasks.count) tarefas e \(convertedCourses.count) matérias!"
            completion(allTasks, convertedCourses)
        }
    }
    
    enum IntegratedError: Error {
        case serviceUnavailable
        case syncFailed
        case invalidData
        case networkError
    }
}
