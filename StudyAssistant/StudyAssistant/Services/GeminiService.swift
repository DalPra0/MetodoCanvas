import Foundation
import Combine

class GeminiService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    
    func analyzeSyllabus(_ syllabusText: String) -> AnyPublisher<SyllabusAnalysis, Error> {
        let prompt = """
        Analise o seguinte plano de ensino e extraia as seguintes informações em formato JSON:
        1. Lista de tópicos principais
        2. Datas importantes (provas, trabalhos, apresentações)
        3. Cronograma de estudos sugerido
        4. Pré-requisitos ou conhecimentos necessários
        5. Sistema de avaliação
        
        Plano de ensino:
        \(syllabusText)
        
        Responda apenas com um JSON válido seguindo esta estrutura:
        {
            "topics": ["tópico1", "tópico2"],
            "importantDates": [{"event": "Prova 1", "date": "2024-09-15", "weight": 30}],
            "studySchedule": [{"week": 1, "topics": ["intro"], "hours": 4}],
            "prerequisites": ["matemática básica"],
            "evaluation": {"provas": 60, "trabalhos": 40}
        }
        """
        
        return generateContent(prompt: prompt)
            .tryMap { response in
                guard let jsonString = response.candidates?.first?.content?.parts.first?.text,
                      let jsonData = jsonString.data(using: .utf8) else {
                    throw GeminiError.invalidResponse
                }
                
                return try JSONDecoder().decode(SyllabusAnalysis.self, from: jsonData)
            }
            .eraseToAnyPublisher()
    }
    
    func generateStudyPlan(for tasks: [StudyTask]) -> AnyPublisher<StudyPlan, Error> {
        let tasksJSON = tasks.map { task in
            """
            {
                "title": "\(task.title)",
                "course": "\(task.course)",
                "dueDate": "\(ISO8601DateFormatter().string(from: task.dueDate))",
                "priority": "\(task.priority.rawValue)",
                "estimatedTime": \(task.estimatedTime)
            }
            """
        }.joined(separator: ",")
        
        let prompt = """
        Com base nas seguintes tarefas pendentes, crie um plano de estudos otimizado para os próximos 7 dias:
        
        Tarefas: [\(tasksJSON)]
        
        Considere:
        1. Prioridades das tarefas
        2. Prazos de entrega
        3. Tempo estimado para cada tarefa
        4. Distribuição equilibrada ao longo da semana
        5. Intervalos para descanso
        
        Responda com um JSON seguindo esta estrutura:
        {
            "dailyPlans": [
                {
                    "date": "2024-08-06",
                    "totalHours": 6,
                    "sessions": [
                        {"task": "Estudar Cálculo", "startTime": "09:00", "duration": 120, "type": "focus"}
                    ]
                }
            ],
            "tips": ["dica1", "dica2"],
            "totalWeekHours": 40
        }
        """
        
        return generateContent(prompt: prompt)
            .tryMap { response in
                guard let jsonString = response.candidates?.first?.content?.parts.first?.text,
                      let jsonData = jsonString.data(using: .utf8) else {
                    throw GeminiError.invalidResponse
                }
                
                return try JSONDecoder().decode(StudyPlan.self, from: jsonData)
            }
            .eraseToAnyPublisher()
    }
    
    func chatWithDocument(_ question: String, documentContent: String) -> AnyPublisher<String, Error> {
        let prompt = """
        Baseado no seguinte documento, responda a pergunta do usuário:
        
        Documento:
        \(documentContent)
        
        Pergunta: \(question)
        
        Responda de forma clara e concisa, citando partes relevantes do documento quando necessário.
        """
        
        return generateContent(prompt: prompt)
            .tryMap { response in
                guard let text = response.candidates?.first?.content?.parts.first?.text else {
                    throw GeminiError.invalidResponse
                }
                return text
            }
            .eraseToAnyPublisher()
    }
    
    private func generateContent(prompt: String) -> AnyPublisher<GeminiResponse, Error> {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            return Fail(error: GeminiError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        let request = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [GeminiPart(text: prompt)]
                )
            ]
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: GeminiResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    enum GeminiError: Error {
        case invalidURL
        case invalidResponse
        case apiKeyMissing
    }
}


struct GeminiRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent?
}

struct SyllabusAnalysis: Codable {
    let topics: [String]
    let importantDates: [ImportantDate]
    let studySchedule: [WeeklySchedule]
    let prerequisites: [String]
    let evaluation: [String: Int]
}

struct ImportantDate: Codable {
    let event: String
    let date: String
    let weight: Int
}

struct WeeklySchedule: Codable {
    let week: Int
    let topics: [String]
    let hours: Int
}

struct StudyPlan: Codable {
    let dailyPlans: [DailyPlan]
    let tips: [String]
    let totalWeekHours: Int
}

struct DailyPlan: Codable {
    let date: String
    let totalHours: Int
    let sessions: [PlanSession]
}

struct PlanSession: Codable {
    let task: String
    let startTime: String
    let duration: Int
    let type: String
}
