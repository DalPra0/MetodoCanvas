import Foundation
import Combine

class FirebaseService: ObservableObject {
    private let apiKey: String
    private let projectId: String
    private let baseURL: String
    
    init(apiKey: String, projectId: String) {
        self.apiKey = apiKey
        self.projectId = projectId
        self.baseURL = "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/(default)/documents"
    }
        
    func saveTask(_ task: StudyTask) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/tasks?key=\(apiKey)") else {
            return Fail(error: FirebaseError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        let document: [String: Any] = [
            "fields": [
                "id": ["stringValue": task.id.uuidString],
                "title": ["stringValue": task.title],
                "description": ["stringValue": task.description],
                "course": ["stringValue": task.course],
                "priority": ["stringValue": task.priority.rawValue],
                "dueDate": ["timestampValue": ISO8601DateFormatter().string(from: task.dueDate)],
                "isCompleted": ["booleanValue": task.isCompleted],
                "estimatedTime": ["doubleValue": task.estimatedTime],
                "createdAt": ["timestampValue": ISO8601DateFormatter().string(from: task.createdAt)]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: document)
        } catch {
            return Fail(error: FirebaseError.encodingError)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { response in
                print("✅ Task '\(task.title)' salva no Firebase!")
                return ()
            }
            .mapError { error in
                print("❌ Erro ao salvar no Firebase: \(error)")
                return FirebaseError.networkError
            }
            .eraseToAnyPublisher()
    }
    
    func fetchTasks() -> AnyPublisher<[StudyTask], Error> {
        guard let url = URL(string: "\(baseURL)/tasks?key=\(apiKey)") else {
            return Fail(error: FirebaseError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let documents = json?["documents"] as? [[String: Any]] ?? []
                
                return documents.compactMap { doc -> StudyTask? in
                    guard let fields = doc["fields"] as? [String: Any],
                          let titleDict = fields["title"] as? [String: Any],
                          let title = titleDict["stringValue"] as? String,
                          let descDict = fields["description"] as? [String: Any],
                          let description = descDict["stringValue"] as? String,
                          let courseDict = fields["course"] as? [String: Any],
                          let course = courseDict["stringValue"] as? String,
                          let priorityDict = fields["priority"] as? [String: Any],
                          let priorityString = priorityDict["stringValue"] as? String,
                          let priority = StudyTask.Priority(rawValue: priorityString),
                          let dueDateDict = fields["dueDate"] as? [String: Any],
                          let dueDateString = dueDateDict["timestampValue"] as? String,
                          let dueDate = ISO8601DateFormatter().date(from: dueDateString),
                          let isCompletedDict = fields["isCompleted"] as? [String: Any],
                          let isCompleted = isCompletedDict["booleanValue"] as? Bool,
                          let estimatedTimeDict = fields["estimatedTime"] as? [String: Any],
                          let estimatedTime = estimatedTimeDict["doubleValue"] as? Double else {
                        return nil
                    }
                    
                    return StudyTask(
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        course: course,
                        priority: priority,
                        isCompleted: isCompleted,
                        estimatedTime: estimatedTime
                    )
                }
            }
            .map { tasks in
                print("✅ \(tasks.count) tarefas carregadas do Firebase!")
                return tasks
            }
            .mapError { error in
                print("❌ Erro ao carregar do Firebase: \(error)")
                return FirebaseError.decodingError
            }
            .eraseToAnyPublisher()
    }
    
    func saveCourse(_ course: Course) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/courses?key=\(apiKey)") else {
            return Fail(error: FirebaseError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        let document: [String: Any] = [
            "fields": [
                "id": ["stringValue": course.id.uuidString],
                "name": ["stringValue": course.name],
                "code": ["stringValue": course.code],
                "professor": ["stringValue": course.professor],
                "colorHex": ["stringValue": course.colorHex]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: document)
        } catch {
            return Fail(error: FirebaseError.encodingError)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in
                print("✅ Course '\(course.name)' salvo no Firebase!")
                return ()
            }
            .mapError { error in
                print("❌ Erro ao salvar course no Firebase: \(error)")
                return FirebaseError.networkError
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCourses() -> AnyPublisher<[Course], Error> {
        guard let url = URL(string: "\(baseURL)/courses?key=\(apiKey)") else {
            return Fail(error: FirebaseError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let documents = json?["documents"] as? [[String: Any]] ?? []
                
                return documents.compactMap { doc -> Course? in
                    guard let fields = doc["fields"] as? [String: Any],
                          let nameDict = fields["name"] as? [String: Any],
                          let name = nameDict["stringValue"] as? String,
                          let codeDict = fields["code"] as? [String: Any],
                          let code = codeDict["stringValue"] as? String,
                          let professorDict = fields["professor"] as? [String: Any],
                          let professor = professorDict["stringValue"] as? String,
                          let colorDict = fields["colorHex"] as? [String: Any],
                          let colorHex = colorDict["stringValue"] as? String else {
                        return nil
                    }
                    
                    return Course(
                        name: name,
                        code: code,
                        professor: professor,
                        colorHex: colorHex
                    )
                }
            }
            .map { courses in
                print("✅ \(courses.count) matérias carregadas do Firebase!")
                return courses
            }
            .mapError { error in
                print("❌ Erro ao carregar courses do Firebase: \(error)")
                return FirebaseError.decodingError
            }
            .eraseToAnyPublisher()
    }
    
    enum FirebaseError: Error {
        case invalidURL
        case encodingError
        case decodingError
        case networkError
        case authenticationFailed
    }
}
