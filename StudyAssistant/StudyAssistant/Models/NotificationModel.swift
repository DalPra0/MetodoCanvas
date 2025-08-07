import Foundation

struct StudyNotification: Identifiable, Codable {
    var id = UUID()
    var taskID: UUID
    var title: String
    var message: String
    var scheduledDate: Date
    var notificationType: NotificationType
    var isDelivered: Bool = false
    var priority: StudyTask.Priority
    
    enum NotificationType: String, CaseIterable, Codable {
        case deadline = "Prazo"
        case reminder = "Lembrete"
        case suggestion = "Sugestão"
        case warning = "Aviso"
    }
}
