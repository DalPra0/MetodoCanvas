import Foundation

struct StudyTask: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    var dueDate: Date
    var course: String
    var priority: Priority
    var isCompleted: Bool = false
    var estimatedTime: TimeInterval
    var canvasID: String?
    var createdAt: Date = Date()
    var completedAt: Date?
    
    init(title: String, description: String, dueDate: Date, course: String, priority: Priority, isCompleted: Bool = false, estimatedTime: TimeInterval, canvasID: String? = nil) {
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.course = course
        self.priority = priority
        self.isCompleted = isCompleted
        self.estimatedTime = estimatedTime
        self.canvasID = canvasID
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Baixa"
        case medium = "Média"
        case high = "Alta"
        case urgent = "Urgente"
        
        var color: String {
            switch self {
            case .low: return "#4CAF50"
            case .medium: return "#FF9800"
            case .high: return "#F44336"
            case .urgent: return "#9C27B0"
            }
        }
    }
}
