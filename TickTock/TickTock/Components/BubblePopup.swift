import SwiftUI

struct BubblePopup: View {
    let text: String
    let color: Color
    let isVisible: Bool

    var body: some View {
        if isVisible {
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(color)
                        .shadow(color: color.opacity(0.5), radius: 8, y: 4)
                )
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity).combined(with: .offset(y: -10)),
                        removal: .scale(scale: 0.3).combined(with: .opacity).combined(with: .offset(y: -5))
                    )
                )
        }
    }
}
