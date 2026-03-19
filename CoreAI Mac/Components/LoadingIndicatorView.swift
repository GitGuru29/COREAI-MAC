import SwiftUI

struct LoadingIndicatorView: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
                .controlSize(.small)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: Capsule())
    }
}
