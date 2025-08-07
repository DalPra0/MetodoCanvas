import SwiftUI

struct PomodoroTimerView: View {
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var isRunning = false
    @State private var sessionType: SessionType = .focus
    @State private var completedPomodoros = 0
    @State private var selectedTask: StudyTask?
    
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    enum SessionType: String, CaseIterable {
        case focus = "Foco"
        case shortBreak = "Pausa Curta"
        case longBreak = "Pausa Longa"
        
        var duration: TimeInterval {
            switch self {
            case .focus: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }
        
        var color: Color {
            switch self {
            case .focus: return .red
            case .shortBreak: return .green
            case .longBreak: return .blue
            }
        }
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Picker("Tipo de Sessão", selection: $sessionType) {
                    ForEach(SessionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: sessionType) { _, newType in
                    timeRemaining = newType.duration
                }
                
                if sessionType == .focus && !viewModel.upcomingTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tarefa para focar:")
                            .font(.headline)
                        
                        Picker("Selecione uma tarefa", selection: $selectedTask) {
                            Text("Nenhuma selecionada").tag(nil as StudyTask?)
                            ForEach(viewModel.upcomingTasks.prefix(5)) { task in
                                Text(task.title).tag(task as StudyTask?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(sessionType.color.opacity(0.2), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(sessionType.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)
                        
                        VStack {
                            Text(timeString)
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                            Text(sessionType.rawValue)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if completedPomodoros > 0 {
                        HStack {
                            Image(systemName: "timer.circle.fill")
                                .foregroundColor(.red)
                            Text("\(completedPomodoros) pomodoros concluídos hoje")
                                .font(.subheadline)
                        }
                    }
                }
                
                HStack(spacing: 30) {
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                    
                    Button(action: toggleTimer) {
                        Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(sessionType.color)
                    }
                    
                    Button(action: skipSession) {
                        Image(systemName: "forward.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Pomodoro")
            .onReceive(timer) { _ in
                if isRunning && timeRemaining > 0 {
                    timeRemaining -= 1
                } else if timeRemaining <= 0 {
                    sessionCompleted()
                }
            }
        }
    }
    
    private var progress: Double {
        let totalTime = sessionType.duration
        return (totalTime - timeRemaining) / totalTime
    }
    
    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        isRunning.toggle()
    }
    
    private func resetTimer() {
        isRunning = false
        timeRemaining = sessionType.duration
    }
    
    private func skipSession() {
        sessionCompleted()
    }
    
    private func sessionCompleted() {
        isRunning = false
        
        if sessionType == .focus {
            completedPomodoros += 1
            
            if let task = selectedTask {
                let session = StudySession(
                    taskID: task.id,
                    courseID: UUID(),
                    startTime: Date().addingTimeInterval(-sessionType.duration),
                    endTime: Date(),
                    duration: sessionType.duration,
                    sessionType: .pomodoro
                )
                viewModel.sessions.append(session)
            }
            
            if completedPomodoros % 4 == 0 {
                sessionType = .longBreak
            } else {
                sessionType = .shortBreak
            }
        } else {
            sessionType = .focus
        }
        
        timeRemaining = sessionType.duration
        
    }
}
