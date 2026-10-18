import SwiftUI

struct CircularProgress: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var color: Color = .blue
    var backgroundColor: Color = Color.gray.opacity(0.2)
    var size: CGFloat = 200

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
        .frame(width: size, height: size)
    }
}

struct CircularProgress_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            CircularProgress(progress: 0.75, lineWidth: 8, color: .blue, size: 120)
            CircularProgress(progress: 0.3, lineWidth: 6, color: .green, size: 100)
            CircularProgress(progress: 1.0, lineWidth: 10, color: .red, size: 80)
        }
        .padding()
    }
}
