import Foundation

struct StudySession: Identifiable, Codable {
    var id = UUID()
    var taskID: UUID
    var courseID: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var sessionType: SessionType
    var notes: String = ""
    
    enum SessionType: String, CaseIterable, Codable {
        case focus = "Foco"
        case review = "Revisão"
        case pomodoro = "Pomodoro"
        case reading = "Leitura"
    }
    
    var actualDuration: TimeInterval {
        guard let end = endTime else { return 0 }
        return end.timeIntervalSince(startTime)
    }
}
