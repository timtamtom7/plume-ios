import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var currentPage = 0
    @State private var isAnimating = false

    private let pages: [OnboardingPage] = OnboardingPage.allPages

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plumeTextSecondary)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.plumeAccent : Color.plumeTextSecondary.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)

                // CTA
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Start Reading")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.plumeAccent)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        subscriptionManager.isOnboardingComplete = true
        subscriptionManager.hasSeenOnboarding = true
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let image: OnboardingImage

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Every book deserves this.",
            subtitle: "Your reading companion",
            description: "Photograph the cover. Track your progress. Predict your finish date. Plume turns the simple act of reading into a rewarding, measurable journey.",
            image: .concept
        ),
        OnboardingPage(
            title: "Photograph your book.",
            subtitle: "Cover scanning",
            description: "Snap a photo of any book's cover. Plume crops it beautifully — no ISBN lookup needed, no barcode scanning. Works with any physical book.",
            image: .coverScan
        ),
        OnboardingPage(
            title: "Track your reading.",
            subtitle: "Progress & pace",
            description: "Log the last page you read. Plume calculates your pace, shows your progress bar, and tells you exactly when you'll finish at your current rate.",
            image: .progress
        ),
        OnboardingPage(
            title: "Finish more books.",
            subtitle: "Start reading",
            description: "There's a particular satisfaction in closing the last page. Plume helps you get there — one update at a time. Start your first book today.",
            image: .finish
        ),
    ]
}

enum OnboardingImage {
    case concept
    case coverScan
    case progress
    case finish
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration
            OnboardingIllustration(image: page.image)
                .frame(height: 280)

            // Text
            VStack(spacing: 12) {
                Text(page.subtitle.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.plumeAccent)
                    .tracking(2)

                Text(page.title)
                    .font(.custom("Georgia-Bold", size: 28))
                    .foregroundColor(.plumeTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct OnboardingIllustration: View {
    let image: OnboardingImage

    var body: some View {
        Group {
            switch image {
            case .concept:
                ConceptIllustration()
            case .coverScan:
                CoverScanIllustration()
            case .progress:
                ProgressIllustration()
            case .finish:
                FinishIllustration()
            }
        }
    }
}

// MARK: - Concept Illustration
struct ConceptIllustration: View {
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(Color.plumeAccentSecondary.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 40)

            // Stack of books
            VStack(spacing: -8) {
                BookSpineView(color: Color(hex: "#8b4513")!, width: 160, height: 20, title: "Anna Karenina")
                BookSpineView(color: Color(hex: "#2d5a3d")!, width: 155, height: 20, title: "Beloved")
                BookSpineView(color: Color(hex: "#4a3728")!, width: 165, height: 20, title: "Middlemarch")
            }

            // Feather/plume
            PlumeIcon()
                .offset(x: 80, y: -80)
                .scaleEffect(0.8)
        }
    }
}

// MARK: - Cover Scan Illustration
struct CoverScanIllustration: View {
    @State private var animating = false

    var body: some View {
        ZStack {
            // Camera frame
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.plumeAccentSecondary, lineWidth: 2)
                .frame(width: 200, height: 300)

            // Corner accents
            FrameCornersSimple()
                .stroke(Color.plumeAccent, lineWidth: 3)
                .frame(width: 200, height: 300)

            // Book cover inside
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#8b4513")!, Color(hex: "#6b3410")!],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 107, height: 160)

                VStack(spacing: 6) {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 60, height: 3)
                        .cornerRadius(2)
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 45, height: 2)
                        .cornerRadius(2)

                    Spacer()

                    Rectangle()
                        .fill(Color.plumeAccentSecondary)
                        .frame(width: 50, height: 4)
                        .cornerRadius(2)

                    Text("F. Scott Fitzgerald")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(16)
            }

            // Scanning line animation
            if animating {
                Rectangle()
                    .fill(Color.plumeAccentSecondary.opacity(0.6))
                    .frame(width: 200, height: 1)
                    .offset(y: -150)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animating = true
            }
        }
    }
}

// MARK: - Progress Illustration
struct ProgressIllustration: View {
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Book with progress
            VStack {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#8b4513")!)
                        .frame(width: 90, height: 135)

                    // Pages effect
                    VStack(spacing: 1) {
                        ForEach(0..<5, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 82, height: 2)
                        }
                    }
                    .offset(y: -12)

                    // Progress overlay
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 90, height: 135 * 0.7)
                }

                Text("p. 126")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.plumeTextSecondary)
                    .padding(.top, 4)
            }

            VStack(alignment: .leading, spacing: 16) {
                // Progress bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("The Great Gatsby")
                            .font(.custom("Georgia-Bold", size: 12))
                            .foregroundColor(.plumeTextPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("70%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.plumeAccent)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.plumeTextSecondary.opacity(0.15))
                                .cornerRadius(3)
                            Rectangle()
                                .fill(Color.plumeCurrentlyReading)
                                .frame(width: geo.size.width * 0.7)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }

                // Stats
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("28")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.plumeCurrentlyReading)
                        Text("pages/day")
                            .font(Theme.fontCaption)
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Divider().frame(height: 30)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apr 2")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.plumeAccent)
                        Text("finishes")
                            .font(Theme.fontCaption)
                            .foregroundColor(.plumeTextSecondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.plumeSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Finish Illustration
struct FinishIllustration: View {
    var body: some View {
        ZStack {
            // Celebration circles
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color.plumeAccentSecondary.opacity(0.2))
                    .frame(width: CGFloat(60 + i * 30), height: CGFloat(60 + i * 30))
            }

            // Finished book stack
            VStack(spacing: -10) {
                BookSpineView(color: Color(hex: "#2d5a3d")!, width: 140, height: 18, title: "📖")
                BookSpineView(color: Color(hex: "#4a4a4a")!, width: 140, height: 18, title: "📖")
            }

            // Checkmark
            ZStack {
                Circle()
                    .fill(Color.plumeCurrentlyReading)
                    .frame(width: 56, height: 56)

                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(x: 70, y: -60)
            .shadow(color: .plumeCurrentlyReading.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Shared Components
struct BookSpineView: View {
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let title: String

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 3, height: height - 4)
                    .cornerRadius(1)

                VStack(alignment: .leading, spacing: 2) {
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: width * 0.5, height: 2)
                        .cornerRadius(1)
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: width * 0.35, height: 1)
                        .cornerRadius(1)
                }

                Spacer()
            }
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
            )
            .rotationEffect(.degrees(-3))
        }
    }
}

struct PlumeIcon: View {
    var body: some View {
        ZStack {
            // Feather shape
            Path { path in
                path.move(to: CGPoint(x: 20, y: 0))
                path.addQuadCurve(to: CGPoint(x: 40, y: 60), control: CGPoint(x: 5, y: 30))
                path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 35, y: 30))
            }
            .fill(
                LinearGradient(
                    colors: [Color.plumeAccent, Color.plumeAccentSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            // Quill
            Path { path in
                path.move(to: CGPoint(x: 20, y: 0))
                path.addLine(to: CGPoint(x: 20, y: 70))
            }
            .stroke(Color.plumeAccent, lineWidth: 1.5)
        }
        .frame(width: 40, height: 70)
    }
}

struct FrameCornersSimple: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c: CGFloat = 20

        // Top-left
        path.move(to: CGPoint(x: 0, y: c))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: c, y: 0))

        // Top-right
        path.move(to: CGPoint(x: rect.width - c, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: c))

        // Bottom-left
        path.move(to: CGPoint(x: 0, y: rect.height - c))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: c, y: rect.height))

        // Bottom-right
        path.move(to: CGPoint(x: rect.width - c, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - c))

        return path
    }
}

#Preview {
    OnboardingView()
        .environmentObject(SubscriptionManager())
}
