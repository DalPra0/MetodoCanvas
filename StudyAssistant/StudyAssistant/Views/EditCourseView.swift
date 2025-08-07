import SwiftUI

struct EditCourseView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    
    @State private var name: String
    @State private var code: String  
    @State private var professor: String
    @State private var selectedColor: String
    
    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#FF2D92", "#5AC8FA", "#FFCC00"
    ]
    
    init(course: Course) {
        self.course = course
        _name = State(initialValue: course.name)
        _code = State(initialValue: course.code)
        _professor = State(initialValue: course.professor)
        _selectedColor = State(initialValue: course.colorHex)
    }
    
    var body: some View {
        NavigationView {
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
                                .fill(Color.priorityColor(from: colorHex))
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
            .navigationTitle("Editar Matéria")
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
        var updatedCourse = course
        updatedCourse.name = name
        updatedCourse.code = code
        updatedCourse.professor = professor
        updatedCourse.colorHex = selectedColor
        
        viewModel.updateCourse(updatedCourse)
        dismiss()
    }
}

#Preview {
    EditCourseView(course: Course(
        name: "Matemática",
        code: "MAT101",
        professor: "Prof. Silva",
        colorHex: "#007AFF"
    ))
    .environmentObject(StudyAssistantViewModel())
}
