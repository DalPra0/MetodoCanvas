import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tempo de Estudo (7 dias)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        StudyTimeChartView()
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Taxa de Conclusão")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TaskCompletionView()
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Performance por Matéria")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.courses) { course in
                            CoursePerformanceView(course: course)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }
}

struct StudyTimeChartView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .overlay(
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text("Gráfico de Tempo de Estudo")
                        .font(.headline)
                    Text("Integrar com Charts framework")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
    }
}

struct TaskCompletionView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var completionRate: Double {
        let total = viewModel.tasks.count
        let completed = viewModel.tasks.filter { $0.isCompleted }.count
        return total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Taxa geral de conclusão")
                    .font(.subheadline)
                Spacer()
                Text("\(Int(completionRate * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            ProgressView(value: completionRate)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CoursePerformanceView: View {
    let course: Course
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    var courseTasks: [StudyTask] {
        viewModel.tasks.filter { $0.course == course.name }
    }
    
    var completionRate: Double {
        let total = courseTasks.count
        let completed = courseTasks.filter { $0.isCompleted }.count
        return total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(course.color)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(courseTasks.filter { $0.isCompleted }.count)/\(courseTasks.count) tarefas")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(completionRate * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(completionRate > 0.8 ? .green : completionRate > 0.5 ? .orange : .red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
