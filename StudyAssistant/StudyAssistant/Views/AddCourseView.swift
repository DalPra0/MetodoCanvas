import SwiftUI

struct AddCourseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    @State private var name = ""
    @State private var code = ""
    @State private var professor = ""
    @State private var selectedColor = "#007AFF"
    
    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#FF2D92", "#5AC8FA", "#FFCC00"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações da Matéria") {
                    TextField("Nome da matéria", text: $name)
                    TextField("Código", text: $code)
                    TextField("Professor", text: $professor)
                }
                
                Section("Cor") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == colorHex ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = colorHex
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Nova Matéria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        saveCourse()
                    }
                    .disabled(name.isEmpty || code.isEmpty || professor.isEmpty)
                }
            }
        }
    }
    
    private func saveCourse() {
        let course = Course(
            name: name,
            code: code,
            professor: professor,
            colorHex: selectedColor
        )
        
        viewModel.addCourse(course)
        dismiss()
    }
}
