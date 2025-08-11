# 📚 StudyAssistant

<div align="center">

![StudyAssistant Logo](https://img.shields.io/badge/StudyAssistant-AI%20Powered-blue?style=for-the-badge&logo=apple&logoColor=white)

[![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=ios&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-0066CC?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-1575F9?style=for-the-badge&logo=xcode&logoColor=white)](https://developer.apple.com/xcode/)

**🎯 Seu assistente pessoal de estudos com IA integrada**

*Organize suas tarefas acadêmicas, sincronize com Canvas LMS e tenha um tutor de IA sempre disponível*

[🚀 Começar](#-instalação) • [📱 Features](#-características-principais) • [🔧 APIs](#-apis-e-integrações) • [📖 Documentação](#-estrutura-do-projeto)

</div>

---

## 📱 Screenshots & Demo

<div align="center">

| Dashboard | Tarefas | IA Assistant | Análise |
|-----------|---------|--------------|---------|
| ![Dashboard](https://via.placeholder.com/200x400/007AFF/white?text=Dashboard) | ![Tasks](https://via.placeholder.com/200x400/34C759/white?text=Tasks) | ![AI](https://via.placeholder.com/200x400/AF52DE/white?text=AI+Chat) | ![Analytics](https://via.placeholder.com/200x400/FF9500/white?text=Analytics) |

</div>

> 🎥 **Demo em Vídeo:** [Assista ao StudyAssistant em ação](https://example.com/demo)

---

## ✨ Características Principais

### 🎯 **Gestão Inteligente de Estudos**
- ✅ **Gerenciamento de Tarefas** com prioridades e prazos
- 📅 **Calendário Integrado** com visualização semanal/mensal  
- 📊 **Analytics de Produtividade** com métricas detalhadas
- ⏱️ **Timer Pomodoro** para sessões de estudo focadas

### 🤖 **Assistente de IA (Google Gemini)**
- 💬 **Chat Inteligente** para dúvidas acadêmicas
- 📄 **Análise de Documentos PDF** com perguntas e respostas
- 📋 **Análise de Ementas** com extração automática de informações
- 🗓️ **Geração de Planos de Estudo** personalizados

### 🔗 **Integrações Acadêmicas**
- 🎓 **Canvas LMS** - Sincronização automática de cursos e tarefas
- ☁️ **Firebase** - Backup e sincronização entre dispositivos
- 📚 **Gestão de Matérias** com cores personalizadas
- 🔔 **Notificações Inteligentes** baseadas em prioridades

---

## 🛠 Tecnologias Utilizadas

### **Frontend & Framework**
![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=flat-square&logo=swift&logoColor=white)
![Combine](https://img.shields.io/badge/Combine-FF6B35?style=flat-square&logo=swift&logoColor=white)
![Core Data](https://img.shields.io/badge/UserDefaults-8A2BE2?style=flat-square&logo=apple&logoColor=white)

### **APIs & Serviços**
![Google Gemini](https://img.shields.io/badge/Google_Gemini-4285F4?style=flat-square&logo=google&logoColor=white)
![Canvas LMS](https://img.shields.io/badge/Canvas_LMS-E13B30?style=flat-square&logo=instructure&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)

### **Ferramentas**
![Xcode](https://img.shields.io/badge/Xcode-1575F9?style=flat-square&logo=xcode&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)
![iOS](https://img.shields.io/badge/iOS_17+-000000?style=flat-square&logo=apple&logoColor=white)

---

## 📋 Pré-requisitos

### **Ambiente de Desenvolvimento**
```bash
• macOS Sonoma 14.0+ ou superior
• Xcode 15.0+ 
• iOS 17.0+ (para testing em device)
• Swift 5.9+
```

### **Chaves de API Necessárias**
| Serviço | Onde Obter | Documentação |
|---------|------------|--------------|
| 🤖 **Google Gemini** | [Google AI Studio](https://makersuite.google.com/) | [Docs](https://ai.google.dev/docs) |
| 🎓 **Canvas LMS** | Canvas → Settings → API Key | [API Docs](https://canvas.instructure.com/doc/api/) |
| ☁️ **Firebase** | [Firebase Console](https://console.firebase.google.com/) | [Setup Guide](https://firebase.google.com/docs/ios/setup) |

---

## 🚀 Instalação

### **1. Clone o Repositório**
```bash
git clone https://github.com/lucasdalpra/StudyAssistant.git
cd StudyAssistant
```

### **2. Abrir no Xcode**
```bash
open StudyAssistant.xcodeproj
```

### **3. Configurar Dependências**
O projeto usa **Swift Package Manager**. As dependências serão instaladas automaticamente:
- Nenhuma dependência externa (projeto nativo)

### **4. Configurar APIs**
1. **Gemini AI:**
   - Obtenha sua chave em [Google AI Studio](https://makersuite.google.com/)
   - Adicione no app em: `Configurações → Chave da API Gemini`

2. **Canvas LMS:**
   - Gere token em: Canvas → Account → Settings → Approved Integrations
   - Configure no app: `Configurações → Integração Canvas`

3. **Firebase (Opcional):**
   - Crie projeto no [Firebase Console](https://console.firebase.google.com/)
   - Configure no app: `Configurações → Backup Firebase`

### **5. Build & Run**
```bash
Cmd + R para executar no simulador
```

---

## 📖 Como Usar

### **🏠 Dashboard Inicial**
```swift
// O dashboard mostra um resumo das suas atividades
- 📊 Métricas da semana (tarefas completadas, tempo estudado)
- ⚠️ Tarefas em atraso
- 📅 Próximas atividades
- 🎯 Progresso dos estudos
```

### **✅ Gerenciar Tarefas**
```swift
// Adicionar nova tarefa
1. Toque em "Tarefas" → "+"
2. Preencha: título, descrição, matéria, prazo
3. Defina prioridade (Baixa/Média/Alta/Urgente)
4. Estime tempo necessário
```

### **🤖 Usar Assistente IA**
```swift
// Funcionalidades do Gemini
- 💬 Chat livre para dúvidas
- 📄 Upload de PDF para análise
- 📋 Análise automática de ementas
- 🗓️ Geração de cronogramas de estudo
```

### **🔗 Sincronizar com Canvas**
```swift
// Importar do Canvas LMS
1. Configure token em Configurações
2. Vá para "Matérias" → "Sincronizar Canvas"
3. Selecione cursos para importar
4. Tarefas serão importadas automaticamente
```

---

## 🔧 APIs e Integrações

### **🤖 Google Gemini AI**

<details>
<summary><strong>📡 Endpoints Utilizados</strong></summary>

```swift
// Configuração da API
class GeminiService: ObservableObject {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    // Funcionalidades implementadas:
    ✅ generateContent(prompt:) - Chat geral
    ✅ analyzeSyllabus(_:) - Análise de ementas  
    ✅ generateStudyPlan(for:) - Planos de estudo
    ✅ chatWithDocument(_:documentContent:) - Chat com PDFs
}
```

**Estrutura de Request:**
```json
{
  "contents": [
    {
      "parts": [
        {"text": "Seu prompt aqui"}
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 2048
  }
}
```

**Rate Limits:** 15 RPM (Requests per minute) no plano gratuito

</details>

### **🎓 Canvas LMS API**

<details>
<summary><strong>📚 Endpoints Implementados</strong></summary>

```swift
class CanvasService: ObservableObject {
    private let baseURL = "https://canvas.instructure.com/api/v1"
    
    // Endpoints utilizados:
    ✅ GET /courses - Lista cursos
    ✅ GET /courses/{id}/assignments - Assignments do curso
    ✅ GET /courses/{id}/front_page - Página inicial/ementa
}
```

**Autenticação:**
```http
Authorization: Bearer {seu_canvas_token}
Content-Type: application/json
```

**Exemplo de Response - Courses:**
```json
[
  {
    "id": 12345,
    "name": "Cálculo I", 
    "course_code": "CALC001",
    "term": {
      "id": 67890,
      "name": "2024/2"
    }
  }
]
```

</details>

### **☁️ Firebase Firestore**

<details>
<summary><strong>🔥 Estrutura de Dados</strong></summary>

```swift
class FirebaseService: ObservableObject {
    private let baseURL = "https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"
    
    // Collections:
    📄 /tasks - Tarefas do usuário
    📚 /courses - Matérias
    📊 /sessions - Sessões de estudo
}
```

**Documento Task:**
```json
{
  "fields": {
    "id": {"stringValue": "uuid"},
    "title": {"stringValue": "Estudar Cálculo"},
    "description": {"stringValue": "Capítulo 5 - Derivadas"},
    "course": {"stringValue": "Cálculo I"},
    "priority": {"stringValue": "high"},
    "dueDate": {"timestampValue": "2024-08-20T10:00:00Z"},
    "isCompleted": {"booleanValue": false},
    "estimatedTime": {"doubleValue": 7200}
  }
}
```

**Autenticação:** API Key via query parameter `?key={API_KEY}`

</details>

### **📄 PDF Service**

<details>
<summary><strong>📋 Processamento de Documentos</strong></summary>

```swift
class PDFService: ObservableObject {
    // Funcionalidades:
    ✅ extractText(from: Data) - Extração de texto
    ✅ analyzeWithAI(text: String) - Análise via Gemini
    ✅ generateQuestions(from: String) - Gera perguntas
}
```

**Fluxo de Processamento:**
```
PDF Upload → Text Extraction → AI Analysis → Q&A Interface
```

</details>

---

## 📁 Estrutura do Projeto

```
StudyAssistant/
├── 📱 StudyAssistant/
│   ├── 🎯 StudyAssistantApp.swift         # Entry point
│   ├── 📄 ContentView.swift               # Tab navigation
│   │
│   ├── 📊 Models/                         # Data models
│   │   ├── CourseModel.swift              # Course structure
│   │   ├── TaskModel.swift                # Task with priorities
│   │   ├── StudySessionModel.swift        # Study sessions
│   │   └── NotificationModel.swift        # Smart notifications
│   │
│   ├── 🎨 Views/                          # SwiftUI Views
│   │   ├── DashboardView.swift            # Main dashboard
│   │   ├── TasksView.swift                # Task management
│   │   ├── CoursesView.swift              # Course management
│   │   ├── AIAssistantView.swift          # Gemini chat interface
│   │   ├── CalendarView.swift             # Calendar integration
│   │   ├── StudyPlanView.swift            # AI-generated plans
│   │   ├── AnalyticsView.swift            # Productivity metrics
│   │   ├── PomodoroTimerView.swift        # Focus timer
│   │   └── ConfigView.swift               # Settings & API keys
│   │
│   ├── 🧠 ViewModels/                     # Business logic
│   │   └── StudyAssistantViewModel.swift  # Main view model
│   │
│   ├── 🔗 Services/                       # API integrations
│   │   ├── GeminiService.swift            # Google AI integration
│   │   ├── CanvasService.swift            # Canvas LMS sync
│   │   ├── FirebaseService.swift          # Cloud backup
│   │   ├── PDFService.swift               # Document processing
│   │   └── IntegratedStudyService.swift   # Unified service
│   │
│   ├── 🛠 Utils/                          # Utilities
│   │   ├── ColorExtension.swift           # Color helpers
│   │   └── UIComponents.swift             # Reusable components
│   │
│   └── 🎨 Assets.xcassets/                # App assets
│       ├── AppIcon.appiconset/            # App icon
│       └── AccentColor.colorset/          # Theme colors
│
└── 📦 StudyAssistant.xcodeproj/          # Xcode project
```

---

## 🎮 Funcionalidades em Detalhe

### **📊 Dashboard Analytics**
```swift
// Métricas calculadas automaticamente:
• ✅ Tarefas completadas esta semana
• ⏰ Tempo total de estudo
• 📈 Produtividade por matéria
• 🎯 Taxa de conclusão de tarefas
• ⚠️ Identificação de tarefas em atraso
```

### **🤖 Assistente IA - Gemini**
```swift
// Comandos disponíveis:
"Explique [conceito]"              → Explicação detalhada
"Crie um cronograma para [matéria]" → Plano de estudos
"Resuma este PDF"                  → Análise de documento  
"Gere perguntas sobre [tópico]"    → Quiz personalizado
"Como estudar para [prova]?"       → Estratégias de estudo
```

### **🔔 Sistema de Notificações**
```swift
// Notificações inteligentes:
📅 1 dia antes do prazo    → "Lembrete: Tarefa vence amanhã"
⏰ 1 hora antes do prazo   → "URGENTE: Tarefa vence em 1h"
🎯 Baseadas na prioridade  → Cores e sons diferentes
📊 Resumo semanal          → "Você completou X tarefas"
```

---

## 🔐 Configuração de Segurança

### **🔑 Gerenciamento de API Keys**
```swift
// Armazenamento seguro no UserDefaults
UserDefaults.standard.set(apiKey, forKey: "geminiAPIKey")
UserDefaults.standard.set(canvasToken, forKey: "canvasToken")

// ⚠️ IMPORTANTE: Nunca commite API keys no código
// ✅ Configure através da interface do app
```

### **🔒 Privacidade de Dados**
- ✅ Dados armazenados localmente por padrão
- ✅ Sincronização Firebase opcional
- ✅ Nenhum dado pessoal enviado sem consentimento
- ✅ API keys criptografadas no device

---

## 🚧 Roadmap & Próximas Features

### **🎯 Versão 2.0 - Planejado**
- [ ] 🔐 **Autenticação** com Apple ID / Google
- [ ] 👥 **Grupos de Estudo** colaborativos
- [ ] 📊 **Relatórios PDF** exportáveis  
- [ ] 🔄 **Sync Multi-device** em tempo real
- [ ] 🎨 **Temas Personalizados** 
- [ ] 📱 **Widget iOS** para quick actions

### **🔮 Versão 3.0 - Futuro**
- [ ] 🤝 **Integração Microsoft Teams**
- [ ] 🎙️ **Transcrição de Aulas** com IA
- [ ] 📚 **Biblioteca Digital** integrada
- [ ] 🧑‍🎓 **Mentoria Virtual** com IA
- [ ] 🎯 **Gamificação** com pontuações

---

## 🤝 Contribuindo

### **🛠 Como Contribuir**
1. **Fork** o projeto
2. **Clone** seu fork: `git clone https://github.com/seu-usuario/StudyAssistant.git`
3. **Crie** uma branch: `git checkout -b feature/nova-feature`
4. **Commit** suas mudanças: `git commit -m 'Add: nova feature incrível'`
5. **Push** para a branch: `git push origin feature/nova-feature`
6. **Abra** um Pull Request

### **📝 Guidelines**
- ✅ Siga o padrão SwiftUI e MVVM
- ✅ Adicione testes para novas features
- ✅ Documente APIs e funções complexas
- ✅ Use commits semânticos (feat, fix, docs, etc.)

### **🐛 Reportar Bugs**
Encontrou um bug? [Abra uma issue](https://github.com/DalPra0/StudyAssistant/issues) com:
- 📱 Versão do iOS
- 📝 Passos para reproduzir
- 📷 Screenshots (se aplicável)
- 🔍 Logs de erro

---

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

```
MIT License

Copyright (c) 2024 Lucas Dal Prá Brascher

Permission is hereby granted, free of charge, to any person obtaining a copy...
```

---

<div align="center">

**⭐ Se este projeto te ajudou, deixe uma estrela!**

[![GitHub stars](https://img.shields.io/github/stars/DalPra0/StudyAssistant?style=social)](https://github.com/DalPra0/StudyAssistant/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/DalPra0/StudyAssistant?style=social)](https://github.com/DalPra0/StudyAssistant/network)

*Feito com ❤️ e muito ☕ por [Lucas Dal Prá](https://github.com/DalPra0)*

</div>
