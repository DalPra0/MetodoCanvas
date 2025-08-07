import Foundation
import Combine

class CanvasService: ObservableObject {
    private let baseURL = "https://canvas.instructure.com/api/v1"
    private var apiToken: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    func setAPIToken(_ token: String) {
        self.apiToken = token
    }
    
    
    func fetchCourses() -> AnyPublisher<[CanvasCourse], Error> {
        guard !apiToken.isEmpty else {
            return Fail(error: CanvasError.missingToken)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/courses")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                print("📡 Canvas Response Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                print("📡 Canvas Raw Data: \(String(data: data, encoding: .utf8) ?? "No data")")
                
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    throw CanvasError.invalidResponse
                }
                
                return data
            }
            .decode(type: [CanvasCourse].self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<[CanvasCourse], Error> in
                print("❌ Canvas fetchCourses error: \(error)")
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAssignments(for courseId: String) -> AnyPublisher<[CanvasAssignment], Error> {
        guard !apiToken.isEmpty else {
            return Fail(error: CanvasError.missingToken)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/courses/\(courseId)/assignments")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                print("📋 Canvas Assignments Response for course \(courseId): \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    print("❌ HTTP Error \(httpResponse.statusCode) for course \(courseId)")
                    return "[]".data(using: .utf8)!
                }
                
                return data
            }
            .decode(type: [CanvasAssignment].self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<[CanvasAssignment], Error> in
                print("❌ Canvas assignments error for course \(courseId): \(error)")
                return Just([CanvasAssignment]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchSyllabus(for courseId: String) -> AnyPublisher<CanvasSyllabus, Error> {
        guard !apiToken.isEmpty else {
            return Fail(error: CanvasError.missingToken)
                .eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/courses/\(courseId)/front_page")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: CanvasSyllabus.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    enum CanvasError: Error {
        case missingToken
        case invalidResponse
        case decodingError
    }
}

struct CanvasCourse: Codable, Identifiable {
    let id: Int
    let name: String?
    let courseCode: String?
    let term: CanvasTerm?
    let syllabusBody: String?
    let accessRestrictedByDate: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case courseCode = "course_code"
        case term
        case syllabusBody = "syllabus_body"
        case accessRestrictedByDate = "access_restricted_by_date"
    }
    
    var isValid: Bool {
        return name != nil && accessRestrictedByDate != true
    }
}

struct CanvasAssignment: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let dueAt: String?
    let pointsPossible: Double?
    let courseId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case dueAt = "due_at"
        case pointsPossible = "points_possible"
        case courseId = "course_id"
    }
    
    var dueDate: Date? {
        guard let dueAt = dueAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dueAt) ?? {
            let simpleFormatter = ISO8601DateFormatter()
            return simpleFormatter.date(from: dueAt)
        }()
    }
}

struct CanvasTerm: Codable {
    let id: Int
    let name: String
}

struct CanvasSyllabus: Codable {
    let body: String?
    let title: String
}
