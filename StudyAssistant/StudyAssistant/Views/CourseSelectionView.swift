import SwiftUI

struct CourseSelectionView: View {
    let canvasCourses: [CanvasCourse]
    @State private var selectedCourses: Set<Int> = []
    @Environment(\.dismiss) var dismiss
    let onCoursesSelected: ([CanvasCourse]) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("📚 Selecionar Matérias")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Escolha quais matérias você quer adicionar ao app")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                HStack {
                    Button("Selecionar Todas") {
                        selectedCourses = Set(canvasCourses.map { $0.id })
                    }
                    
                    Spacer()
                    
                    Button("Limpar Seleção") {
                        selectedCourses.removeAll()
                    }
                    
                    Spacer()
                    
                    Text("\(selectedCourses.count) selecionadas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(canvasCourses) { course in
                        CourseSelectionRow(
                            course: course,
                            isSelected: selectedCourses.contains(course.id)
                        ) { isSelected in
                            if isSelected {
                                selectedCourses.insert(course.id)
                            } else {
                                selectedCourses.remove(course.id)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                
                VStack(spacing: 12) {
                    Button(action: confirmSelection) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Adicionar \(selectedCourses.count) Matérias")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCourses.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedCourses.isEmpty)
                    
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func confirmSelection() {
        let selectedCourseObjects = canvasCourses.filter { selectedCourses.contains($0.id) }
        onCoursesSelected(selectedCourseObjects)
        dismiss()
    }
}

struct CourseSelectionRow: View {
    let course: CanvasCourse
    let isSelected: Bool
    let onSelectionChanged: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { onSelectionChanged(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.name ?? "Curso Sem Nome")
                    .font(.headline)
                    .lineLimit(2)
                
                if let code = course.courseCode {
                    Text(code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text("ID: \(course.id)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            onSelectionChanged(!isSelected)
        }
    }
}

#Preview {
    CourseSelectionView(
        canvasCourses: [
            CanvasCourse(
                id: 1,
                name: "Banco de Dados",
                courseCode: "BD-2024",
                term: nil,
                syllabusBody: nil,
                accessRestrictedByDate: nil
            ),
            CanvasCourse(
                id: 2,
                name: "Engenharia de Software",
                courseCode: "ES-2024",
                term: nil,
                syllabusBody: nil,
                accessRestrictedByDate: nil
            )
        ]
    ) { selectedCourses in
        print("Selected: \(selectedCourses)")
    }
}
