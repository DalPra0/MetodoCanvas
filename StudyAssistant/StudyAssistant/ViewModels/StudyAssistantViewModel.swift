import Foundation
import Combine

class StudyAssistantViewModel: ObservableObject {
    @Published var tasks: [StudyTask] = []
    @Published var courses: [Course] = []
    @Published var sessions: [StudySession] = []
    @Published var notifications: [StudyNotification] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        setupNotificationScheduling()
    }
    
    func addTask(_ task: StudyTask) {
        tasks.append(task)
        scheduleNotifications(for: task)
        saveData()
    }
    
    func updateTask(_ task: StudyTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
        }
    }
    
    func deleteTask(_ task: StudyTask) {
        tasks.removeAll { $0.id == task.id }
        saveData()
    }
    
    func completeTask(_ task: StudyTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = true
            tasks[index].completedAt = Date()
            saveData()
        }
    }
    
    func addCourse(_ course: Course) {
        courses.append(course)
        saveData()
    }
    
    func updateCourse(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
            saveData()
        }
    }
    
    func deleteCourse(_ course: Course) {
        courses.removeAll { $0.id == course.id }
        tasks.removeAll { $0.course == course.name }
        saveData()
    }
    
    var upcomingTasks: [StudyTask] {
        tasks.filter { !$0.isCompleted && $0.dueDate > Date() }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    var overdueTasks: [StudyTask] {
        tasks.filter { !$0.isCompleted && $0.dueDate < Date() }
    }
    
    var completedTasksThisWeek: [StudyTask] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return tasks.filter { $0.isCompleted && ($0.completedAt ?? Date.distantPast) > weekAgo }
    }
    
    var studyTimeThisWeek: TimeInterval {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return sessions.filter { $0.startTime > weekAgo }
            .reduce(0) { $0 + $1.actualDuration }
    }
    
    private func scheduleNotifications(for task: StudyTask) {
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: task.dueDate)!
        let oneHourBefore = Calendar.current.date(byAdding: .hour, value: -1, to: task.dueDate)!
        
        let dayBeforeNotification = StudyNotification(
            taskID: task.id,
            title: "Lembrete de Tarefa",
            message: "A tarefa '\(task.title)' vence amanhã!",
            scheduledDate: oneDayBefore,
            notificationType: .reminder,
            priority: task.priority
        )
        
        let hourBeforeNotification = StudyNotification(
            taskID: task.id,
            title: "Prazo Urgente",
            message: "A tarefa '\(task.title)' vence em 1 hora!",
            scheduledDate: oneHourBefore,
            notificationType: .deadline,
            priority: .urgent
        )
        
        notifications.append(contentsOf: [dayBeforeNotification, hourBeforeNotification])
        saveData()
    }
    
    private func setupNotificationScheduling() {
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAndDeliverNotifications()
            }
            .store(in: &cancellables)
    }
    
    private func checkAndDeliverNotifications() {
        let now = Date()
        for notification in notifications where !notification.isDelivered && notification.scheduledDate <= now {
            markNotificationAsDelivered(notification)
        }
    }
    
    private func markNotificationAsDelivered(_ notification: StudyNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isDelivered = true
            saveData()
        }
    }
    
    private func saveData() {
        if let tasksData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(tasksData, forKey: "tasks")
        }
        if let coursesData = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(coursesData, forKey: "courses")
        }
        if let sessionsData = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(sessionsData, forKey: "sessions")
        }
        if let notificationsData = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(notificationsData, forKey: "notifications")
        }
    }
    
    private func loadData() {
        if let tasksData = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([StudyTask].self, from: tasksData) {
            tasks = decodedTasks
        }
        
        if let coursesData = UserDefaults.standard.data(forKey: "courses"),
           let decodedCourses = try? JSONDecoder().decode([Course].self, from: coursesData) {
            courses = decodedCourses
        }
        
        if let sessionsData = UserDefaults.standard.data(forKey: "sessions"),
           let decodedSessions = try? JSONDecoder().decode([StudySession].self, from: sessionsData) {
            sessions = decodedSessions
        }
        
        if let notificationsData = UserDefaults.standard.data(forKey: "notifications"),
           let decodedNotifications = try? JSONDecoder().decode([StudyNotification].self, from: notificationsData) {
            notifications = decodedNotifications
        }
    }
}
