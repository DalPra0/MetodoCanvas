
import SwiftUI


struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.8))
    }
}


struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct PriorityBadge: View {
    let priority: StudyTask.Priority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: priority.color).opacity(0.2))
            .foregroundColor(Color(hex: priority.color))
            .cornerRadius(6)
    }
}


struct CourseIcon: View {
    let course: Course
    let size: CGFloat
    
    init(course: Course, size: CGFloat = 40) {
        self.course = course
        self.size = size
    }
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [course.color, course.color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Text(String(course.name.prefix(2)).uppercased())
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            )
            .shadow(radius: 2)
    }
}


struct TaskProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    init(progress: Double, color: Color = .blue, lineWidth: CGFloat = 8, size: CGFloat = 60) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .semibold))
                .foregroundColor(color)
        }
    }
}


struct AnimatedButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    @State private var isPressed = false
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}


struct GradientCard<Content: View>: View {
    let colors: [Color]
    let content: Content
    
    init(colors: [Color], @ViewBuilder content: () -> Content) {
        self.colors = colors
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(16)
            )
            .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
    }
}


struct StatusIndicator: View {
    let status: Status
    
    enum Status {
        case online, offline, syncing, error
        
        var color: Color {
            switch self {
            case .online: return .green
            case .offline: return .gray
            case .syncing: return .blue
            case .error: return .red
            }
        }
        
        var text: String {
            switch self {
            case .online: return "Online"
            case .offline: return "Offline"
            case .syncing: return "Sincronizando"
            case .error: return "Erro"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.text)
                .font(.caption)
                .foregroundColor(status.color)
        }
    }
}


struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.blue)
                        .shadow(radius: 8)
                )
        }
        .buttonStyle(.plain)
    }
}


struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}


struct SuccessCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green)
                .scaleEffect(scale)
            
            Path { path in
                path.move(to: CGPoint(x: 20, y: 30))
                path.addLine(to: CGPoint(x: 30, y: 40))
                path.addLine(to: CGPoint(x: 50, y: 20))
            }
            .trim(from: 0, to: trimEnd)
            .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: 60, height: 60)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1
            }
            
            withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                trimEnd = 1
            }
        }
    }
}


struct ErrorAlert: ViewModifier {
    @Binding var error: Error?
    
    func body(content: Content) -> some View {
        content
            .alert("Erro", isPresented: .constant(error != nil)) {
                Button("OK") {
                    error = nil
                }
            } message: {
                Text(error?.localizedDescription ?? "Erro desconhecido")
            }
    }
}

extension View {
    func errorAlert(_ error: Binding<Error?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}


struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            Button {
                configuration.isOn.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color.blue : Color(.systemGray4))
                    .frame(width: 50, height: 30)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 26, height: 26)
                            .offset(x: configuration.isOn ? 10 : -10)
                            .animation(.spring(response: 0.3), value: configuration.isOn)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}


struct NotificationBadge: View {
    let count: Int
    
    var body: some View {
        if count > 0 {
            Text("\(count > 99 ? "99+" : "\(count)")")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, count > 9 ? 6 : 8)
                .padding(.vertical, 4)
                .background(Color.red)
                .cornerRadius(10)
        }
    }
}


struct PulseAnimation: ViewModifier {
    @State private var scale: CGFloat = 1
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseAnimation())
    }
}

#Preview {
    VStack(spacing: 20) {
        PriorityBadge(priority: .urgent)
        
        CourseIcon(course: Course(name: "Matemática", code: "MAT101", professor: "Prof. Silva", colorHex: "#007AFF"), size: 60)
        
        TaskProgressRing(progress: 0.7, color: .blue, size: 80)
        
        StatusIndicator(status: .online)
        
        SuccessCheckmark()
            .frame(width: 60, height: 60)
    }
    .padding()
}
