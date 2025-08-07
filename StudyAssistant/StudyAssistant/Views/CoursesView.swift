import SwiftUI

struct CoursesView: View {
    @EnvironmentObject var viewModel: StudyAssistantViewModel
    @State private var showingAddCourse = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.courses) { course in
                    NavigationLink(destination: CourseDetailView(course: course)) {
                        CourseRowView(course: course)
                            .listRowSeparator(.hidden)
                    }
                }
                .onDelete(perform: deleteCourses)
            }
            .listStyle(.plain)
            .navigationTitle("Matérias")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
            }
        }
    }
    
    private func deleteCourses(offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteCourse(viewModel.courses[index])
        }
    }
}

struct CourseRowView: View {
    let course: Course
    
    var body: some View {
        HStack {
            Circle()
                .fill(course.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(course.name.prefix(2)).uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.name)
                    .font(.headline)
                
                Text(course.code)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Prof. \(course.professor)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
