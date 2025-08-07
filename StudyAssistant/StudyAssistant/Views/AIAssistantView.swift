
import SwiftUI
import Combine

struct AIAssistantView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    @AppStorage("geminiAPIKey") private var geminiAPIKey = ""
    
    @State private var geminiService: GeminiService?
    @State private var messages: [ChatMessage] = []
    @State private var currentMessage = ""
    @State private var isLoading = false
    @State private var selectedCourse: Course?
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Assistente IA")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(selectedCourse?.name ?? "Chat Geral")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button("Chat Geral") {
                                selectedCourse = nil
                            }
                            
                            ForEach(viewModel.courses) { course in
                                Button(course.name) {
                                    selectedCourse = course
                                }
                            }
                        } label: {
                            Image(systemName: "books.vertical.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    if geminiAPIKey.isEmpty {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.orange)
                            Text("Configure sua API Key do Gemini nas Configurações")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemGroupedBackground))
                
                if geminiAPIKey.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Text("IA Não Configurada")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Vá em Configurações para adicionar sua chave da API do Google Gemini e ativar o assistente inteligente")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                        .padding(.horizontal)
                                }
                                
                                if isLoading {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        
                                        Text("IA pensando...")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        .onChange(of: messages.count) { _, _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if let lastMessage = messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    if selectedCourse != nil {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Text("Modo Contextual: Perguntas específicas sobre \(selectedCourse?.name ?? "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 12) {
                        TextField("Digite sua pergunta...", text: $currentMessage, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...4)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(currentMessage.isEmpty ? .gray : .blue)
                        }
                        .disabled(currentMessage.isEmpty || isLoading || geminiAPIKey.isEmpty)
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .onAppear {
            setupGeminiService()
            setupWelcomeMessage()
        }
        .onChange(of: geminiAPIKey) { _, _ in
            setupGeminiService()
        }
    }
    
    private func setupGeminiService() {
        if !geminiAPIKey.isEmpty {
            geminiService = GeminiService(apiKey: geminiAPIKey)
        }
    }
    
    private func setupWelcomeMessage() {
        if messages.isEmpty && !geminiAPIKey.isEmpty {
            let welcomeMessage = ChatMessage(
                content: """
👋 **Olá! Sou seu Assistente IA de Estudos**

Posso te ajudar com:
• 📚 Tirar dúvidas sobre matérias específicas
• 📝 Explicar conceitos complexos
• ⏰ Sugerir cronogramas de estudo
• 🎯 Dar dicas de produtividade
• 📖 Resumir e explicar conteúdos

**Dica:** Selecione uma matéria no menu acima para perguntas específicas!
""",
                isUser: false,
                timestamp: Date()
            )
            messages.append(welcomeMessage)
        }
    }
    
    private func sendMessage() {
        guard let geminiService = geminiService, !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: currentMessage.trimmingCharacters(in: .whitespacesAndNewlines),
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        let question = currentMessage
        currentMessage = ""
        isLoading = true
        
        let contextualPrompt: String
        if let course = selectedCourse {
            contextualPrompt = """
Você é um tutor especializado em \(course.name) (Código: \(course.code), Prof. \(course.professor)).
Responda de forma didática, clara e estruturada a seguinte pergunta do estudante:

\(question)

Use formatação markdown quando apropriado. Seja específico e educational.
"""
        } else {
            contextualPrompt = """
Você é um assistente acadêmico especializado em ajudar estudantes universitários.
Responda de forma clara e educativa a seguinte pergunta:

\(question)

Use formatação markdown quando apropriado. Dê exemplos práticos quando possível.
"""
        }
        
        geminiService.chatWithDocument(contextualPrompt, documentContent: selectedCourse?.name ?? "Contexto acadêmico geral")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        let errorMessage = ChatMessage(
                            content: "❌ **Erro na IA:** \(error.localizedDescription)\n\nVerifique sua conexão e tente novamente.",
                            isUser: false,
                            timestamp: Date()
                        )
                        self.messages.append(errorMessage)
                    }
                },
                receiveValue: { response in
                    let aiMessage = ChatMessage(
                        content: response,
                        isUser: false,
                        timestamp: Date()
                    )
                    self.messages.append(aiMessage)
                }
            )
            .store(in: &cancellables)
    }
}


struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(.init(message.content))
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 60)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: message.id)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    AIAssistantView()
        .environmentObject(StudyAssistantViewModel())
}
