import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StudyAssistantViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Início")
                }
                .tag(0)
                .environmentObject(viewModel)
            
            CalendarView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "calendar" : "calendar")
                    Text("Calendário")
                }
                .tag(1)
                .environmentObject(viewModel)
            
            CoursesView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "books.vertical.fill" : "books.vertical")
                    Text("Matérias")
                }
                .tag(2)
                .environmentObject(viewModel)
            
            TasksView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "checklist" : "list.bullet")
                    Text("Tarefas")
                }
                .tag(3)
                .environmentObject(viewModel)
            
            AIAssistantView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "brain.filled.head.profile" : "brain.head.profile")
                    Text("IA")
                }
                .tag(4)
                .environmentObject(viewModel)
                .badge(shouldShowAIBadge ? "Novo" : nil)
            
            StudyPlanView()
                .tabItem {
                    Image(systemName: selectedTab == 5 ? "calendar.badge.clock" : "calendar.badge.clock")
                    Text("Plano")
                }
                .tag(5)
                .environmentObject(viewModel)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 6 ? "gearshape.fill" : "gearshape")
                    Text("Config")
                }
                .tag(6)
                .environmentObject(viewModel)
        }
        .tint(.blue)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private var shouldShowAIBadge: Bool {
        let geminiKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        let hasGeminiKey = !geminiKey.isEmpty
        let hasUsedAI = UserDefaults.standard.bool(forKey: "hasUsedAI")
        return hasGeminiKey && !hasUsedAI
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
