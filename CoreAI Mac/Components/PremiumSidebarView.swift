import SwiftUI

struct PremiumSidebarView: View {
    @Binding var selection: AppRoute?
    let requiresInitialSettings: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.primary.opacity(0.08),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(.ultraThinMaterial)

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CoreAI")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Local intelligence workspace")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                VStack(spacing: 8) {
                    ForEach(AppRoute.allCases) { route in
                        sidebarButton(for: route)
                    }
                }
                .padding(.horizontal, 10)

                if requiresInitialSettings {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Settings need attention")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 10)
                }

                Spacer()
            }
        }
        .navigationTitle("")
    }

    private func sidebarButton(for route: AppRoute) -> some View {
        Button {
            selection = route
        } label: {
            HStack(spacing: 12) {
                Image(systemName: route.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 18)
                Text(route.title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(selection == route ? selectedBackground : AnyShapeStyle(.clear), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(selection == route ? .primary : .secondary)
    }

    private var selectedBackground: AnyShapeStyle {
        AnyShapeStyle(.regularMaterial)
    }
}
