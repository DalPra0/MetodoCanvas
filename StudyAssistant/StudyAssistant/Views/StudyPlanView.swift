import SwiftUI
import Foundation

struct StudyPlanView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    @AppStorage("geminiAPIKey") private var geminiAPIKey = ""
    @AppStorage("firebaseAPIKey") private var firebaseAPIKey = ""
    @AppStorage("firebaseProjectId") private var firebaseProjectId = ""
    
    @StateObject private var integratedService: IntegratedStudyService
    @State private var currentPlan: StudyPlan?
    @State private var isGenerating = false
    @State private var showingCustomization = false
    
    init() {
        _integratedService = StateObject(wrappedValue: IntegratedStudyService(
            firebaseAPIKey: UserDefaults.standard.string(forKey: "firebaseAPIKey") ?? "",
            firebaseProjectId: UserDefaults.standard.string(forKey: "firebaseProjectId") ?? "",
            geminiAPIKey: UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Plano de Estudos IA")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Cronograma inteligente personalizado")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            StatusCard(
                                title: "Tarefas Pendentes", 
                                value: "\(viewModel.upcomingTasks.count)",
                                color: .blue
                            )
                            
                            StatusCard(
                                title: "Matérias Ativas", 
                                value: "\(viewModel.courses.count)",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        if geminiAPIKey.isEmpty {
                            ConfigurationNeededCard()
                        } else if viewModel.upcomingTasks.isEmpty {
                            EmptyTasksCard()
                        } else {
                            GeneratePlanCard(
                                isGenerating: isGenerating,
                                onGenerate: generatePlan
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    if let plan = currentPlan {
                        StudyPlanDisplay(plan: plan)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .navigationTitle("Plano IA")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                if !geminiAPIKey.isEmpty && !viewModel.upcomingTasks.isEmpty {
                    generatePlan()
                }
            }
        }
    }
    
    private func generatePlan() {
        guard !geminiAPIKey.isEmpty, !viewModel.upcomingTasks.isEmpty else { return }
        
        let updatedService = IntegratedStudyService(
            firebaseAPIKey: firebaseAPIKey,
            firebaseProjectId: firebaseProjectId,
            geminiAPIKey: geminiAPIKey
        )
        
        isGenerating = true
        
        updatedService.generateWeeklyStudyPlan(for: viewModel.upcomingTasks) { plan in
            DispatchQueue.main.async {
                self.currentPlan = plan
                self.isGenerating = false
            }
        }
    }
}


struct StatusCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ConfigurationNeededCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Configuração Necessária")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Configure sua API Key do Gemini nas Configurações para gerar planos de estudo inteligentes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct EmptyTasksCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("Nenhuma Tarefa Pendente")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Adicione algumas tarefas na aba Tarefas para gerar um plano de estudos personalizado")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct GeneratePlanCard: View {
    let isGenerating: Bool
    let onGenerate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onGenerate) {
                HStack(spacing: 12) {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(.white)
                        Text("IA Gerando Plano...")
                    } else {
                        Image(systemName: "brain.head.profile")
                        Text("Gerar Plano Inteligente")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isGenerating)
            
            Text("A IA analisará suas tarefas, prazos e prioridades para criar o cronograma perfeito")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct StudyPlanDisplay: View {
    let plan: StudyPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("📅 Seu Plano Semanal")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Gerado pela IA • \(plan.dailyPlans.count) dias planejados")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(plan.totalWeekHours)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("horas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            LazyVStack(spacing: 16) {
                ForEach(Array(plan.dailyPlans.enumerated()), id: \.offset) { index, dailyPlan in
                    DailyPlanCard(dailyPlan: dailyPlan, dayIndex: index)
                }
            }
            
            if !plan.tips.isEmpty {
                AITipsSection(tips: plan.tips)
            }
        }
    }
}

struct DailyPlanCard: View {
    let dailyPlan: DailyPlan
    let dayIndex: Int
    
    private var dayColors: [Color] {
        [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(dayColors[dayIndex % dayColors.count])
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading) {
                        Text(formatDate(dailyPlan.date))
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("\(dailyPlan.totalHours)h de estudo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(dayOfWeek(from: dailyPlan.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(dayColors[dayIndex % dayColors.count].opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 8) {
                ForEach(Array(dailyPlan.sessions.enumerated()), id: \.offset) { sessionIndex, session in
                    StudySessionRow(session: session)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    private func dayOfWeek(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date).capitalized
    }
}

struct StudySessionRow: View {
    let session: PlanSession
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.startTime)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                Text("\(session.duration)min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.task)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(session.type.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: sessionTypeIcon(for: session.type))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func sessionTypeIcon(for type: String) -> String {
        switch type.lowercased() {
        case "focus": return "brain.head.profile"
        case "review": return "arrow.counterclockwise"
        case "reading": return "book"
        case "practice": return "pencil"
        default: return "clock"
        }
    }
}

struct AITipsSection: View {
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Dicas da IA")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(tip)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

#Preview {
    StudyPlanView()
        .environmentObject(StudyAssistantViewModel())
}
