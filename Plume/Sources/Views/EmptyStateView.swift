import SwiftUI

// MARK: - Empty State View
struct EmptyStateView: View {
    let onAddBook: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Illustration
            EmptyBooksIllustration()
                .frame(height: 200)

            // Text
            VStack(spacing: 12) {
                Text("Your shelf is empty.")
                    .font(.custom("Georgia-Bold", size: 22))
                    .foregroundColor(.plumeTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Start your reading journey.\nAdd your first book and Plume will track every page.")
                    .font(.system(size: 15))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // CTA
            Button(action: onAddBook) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Book")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.plumeAccent)
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            // Reading quote
            VStack(spacing: 8) {
                Text("\"A reader lives a thousand lives before he dies.\"")
                    .font(.custom("Georgia-Italic", size: 14))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("— George R.R. Martin")
                    .font(.system(size: 12))
                    .foregroundColor(.plumeTextSecondary.opacity(0.7))
            }

            Spacer()
            Spacer()
        }
        .padding(.top, 40)
    }
}

struct EmptyBooksIllustration: View {
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.plumeAccentSecondary.opacity(0.1))
                .frame(width: 180, height: 180)

            // Books stack
            VStack(spacing: -20) {
                // Book 1 - angled left
                EmptyBookShape(color: Color(hex: "#2d5a3d")!, angle: -8)
                    .frame(width: 70, height: 100)

                // Book 2 - slightly less angled
                EmptyBookShape(color: Color(hex: "#8b4513")!, angle: -4)
                    .frame(width: 75, height: 105)

                // Book 3 - mostly upright
                EmptyBookShape(color: Color(hex: "#4a3728")!, angle: 2)
                    .frame(width: 68, height: 98)
            }
            .offset(y: -10)

            // Plus sign floating above
            ZStack {
                Circle()
                    .fill(Color.plumeAccent)
                    .frame(width: 40, height: 40)

                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(x: 60, y: -110)
            .shadow(color: .plumeAccent.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }
}

struct EmptyBookShape: View {
    let color: Color
    let angle: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 30, height: 2)
                        .padding(.top, 12)
                        .padding(.leading, 8)

                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 20, height: 1)
                        .padding(.leading, 8)

                    Spacer()

                    Rectangle()
                        .fill(Color.plumeAccentSecondary)
                        .frame(width: 25, height: 3)
                        .padding(.leading, 8)
                        .padding(.bottom, 12)
                }
            )
            .rotationEffect(.degrees(angle))
            .shadow(color: .black.opacity(0.15), radius: 4, x: 2, y: 3)
    }
}

// MARK: - Error State Views
struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.plumeAccent.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "camera.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.plumeAccent.opacity(0.6))
            }

            VStack(spacing: 10) {
                Text("Camera Access Needed")
                    .font(.custom("Georgia-Bold", size: 20))
                    .foregroundColor(.plumeTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Plume uses your camera to photograph book covers.\nPlease enable camera access in Settings.")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.plumeAccent)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding(24)
    }
}

struct BookLimitReachedView: View {
    let currentTier: SubscriptionTier
    let onUpgrade: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.plumeAccent.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.plumeAccent.opacity(0.6))
            }

            VStack(spacing: 10) {
                Text("Book Limit Reached")
                    .font(.custom("Georgia-Bold", size: 20))
                    .foregroundColor(.plumeTextPrimary)
                    .multilineTextAlignment(.center)

                Text("You've reached the \(currentTier.maxBooks)-book limit on your \(currentTier.displayName) plan.\nUpgrade to Reader for unlimited books.")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 12) {
                Button(action: onUpgrade) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Upgrade to Reader — $4.99/mo")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.plumeAccent)
                    .cornerRadius(10)
                }

                Button(action: onDismiss) {
                    Text("Maybe Later")
                        .font(.system(size: 14))
                        .foregroundColor(.plumeTextSecondary)
                }
            }

            Spacer()
        }
        .padding(24)
    }
}

struct ProgressSaveFailedView: View {
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.red.opacity(0.7))
            }

            VStack(spacing: 10) {
                Text("Couldn't Save Progress")
                    .font(.custom("Georgia-Bold", size: 20))
                    .foregroundColor(.plumeTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Something went wrong saving your reading progress.\nPlease try again.")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 12) {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.plumeAccent)
                    .cornerRadius(10)
                }

                Button(action: onDismiss) {
                    Text("Cancel")
                        .font(.system(size: 14))
                        .foregroundColor(.plumeTextSecondary)
                }
            }

            Spacer()
        }
        .padding(24)
    }
}

// MARK: - Preview
#Preview("Empty State") {
    EmptyStateView(onAddBook: {})
        .background(Color.plumeBackground)
}

#Preview("Camera Permission Denied") {
    CameraPermissionDeniedView()
        .background(Color.plumeBackground)
}

#Preview("Book Limit Reached") {
    BookLimitReachedView(
        currentTier: .free,
        onUpgrade: {},
        onDismiss: {}
    )
    .background(Color.plumeBackground)
}

#Preview("Progress Save Failed") {
    ProgressSaveFailedView(onRetry: {}, onDismiss: {})
        .background(Color.plumeBackground)
}
