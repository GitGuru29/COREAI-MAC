import SwiftUI

struct PremiumSidebarView: View {
    @Binding var selection: AppRoute?
    let requiresInitialSettings: Bool
    @State private var logoRotation: Double = 0

    var body: some View {
        ZStack {
            sidebarBackground

            VStack(alignment: .leading, spacing: 0) {
                // Brand block
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        // Mini orb
                        ZStack {
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [Color.cyan, Color.blue, Color.indigo, Color.cyan],
                                        center: .center
                                    )
                                )
                                .frame(width: 26, height: 26)
                                .rotationEffect(.degrees(logoRotation))
                            Image(systemName: "sparkle")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: Color.cyan.opacity(0.28), radius: 6)
                        .onAppear {
                            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                                logoRotation = 360
                            }
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text("CoreAI")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue, Color.indigo],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("Local workspace")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 16)

                // New Chat button
                Button {
                    // Action: clear/new conversation
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("New Chat")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.85), Color.blue, Color.indigo.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Color.cyan.opacity(0.25), radius: 10, y: 3)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.bottom, 18)

                // Navigation items
                VStack(spacing: 2) {
                    ForEach(AppRoute.allCases) { route in
                        sidebarNavItem(for: route)
                    }
                }
                .padding(.horizontal, 8)

                Spacer()

                // Settings attention banner
                if requiresInitialSettings {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Settings need attention")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.orange.opacity(0.20), lineWidth: 1)
                    )
                    .padding(.horizontal, 10)
                    .padding(.bottom, 14)
                }
            }
        }
        .navigationTitle("")
    }

    private var sidebarBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.primary.opacity(0.06),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(.ultraThinMaterial)

            // Accent glow top-left
            Circle()
                .fill(Color.cyan.opacity(0.08))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -60, y: -80)
        }
    }

    private func sidebarNavItem(for route: AppRoute) -> some View {
        let isSelected = selection == route

        return Button {
            selection = route
        } label: {
            HStack(spacing: 10) {
                // Left active indicator bar
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(isSelected ? Color.cyan : Color.clear)
                    .frame(width: 3, height: 20)

                Image(systemName: route.systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.cyan : Color.secondary)
                    .frame(width: 18)

                Text(route.title)
                    .font(.system(.callout, design: .rounded, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.cyan.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}
