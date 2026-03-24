import SwiftUI

// MARK: - Quote Card View
struct QuoteCardView: View {
    let quote: String
    let bookTitle: String
    let author: String
    let citationStyle: CitationStyle

    enum CitationStyle: String, CaseIterable {
        case plain = "Plain Text"
        case apa = "APA"
        case mla = "MLA"
        case chicago = "Chicago"

        func format(quote: String, title: String, author: String) -> String {
            switch self {
            case .plain:
                return "\"\(quote)\"\n— \(author), \(title)"
            case .apa:
                let lastName = author.split(separator: " ").last.map(String.init) ?? author
                return "\(lastName). (\(title))."
            case .mla:
                return "\"\(quote)\" \(title) by \(author)."
            case .chicago:
                return "\(author), \(title)."
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Quote mark
            Image(systemName: "quote.opening")
                .font(.system(size: 28))
                .foregroundColor(.plumeAccentSecondary)

            // Quote text
            Text(quote)
                .font(.custom("Georgia-Italic", size: 16))
                .foregroundColor(.plumeTextPrimary)
                .lineSpacing(5)

            Divider()

            // Book info
            VStack(alignment: .leading, spacing: 4) {
                Text(bookTitle)
                    .font(.custom("Georgia-Bold", size: 14))
                    .foregroundColor(.plumeTextPrimary)

                Text(author)
                    .font(.custom("Georgia", size: 13))
                    .foregroundColor(.plumeTextSecondary)
            }

            // Citation
            HStack {
                Text(citationStyle.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.plumeAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.plumeAccent.opacity(0.1))
                    .cornerRadius(4)

                Spacer()

                Menu {
                    ForEach(CitationStyle.allCases, id: \.self) { style in
                        Button(style.rawValue) {}
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Copy Citation")
                            .font(.system(size: 12))
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.plumeSurface)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.plumeAccentSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Simple Quote Card (for display)
struct SimpleQuoteCard: View {
    let quote: String
    let bookTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 16))
                    .foregroundColor(.plumeAccentSecondary)
                    .padding(.top, 2)

                Text(quote)
                    .font(.custom("Georgia-Italic", size: 14))
                    .foregroundColor(.plumeTextPrimary)
                    .lineSpacing(3)
            }

            Text("— \(bookTitle)")
                .font(.system(size: 12))
                .foregroundColor(.plumeTextSecondary)
                .padding(.leading, 24)
        }
        .padding(14)
        .background(Color.plumeSurface)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.plumeAccentSecondary.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Reading Progress Visual
struct ReadingProgressVisual: View {
    let progress: Double
    let pagesRead: Int
    let totalPages: Int
    let daysReading: Int
    let pagesPerDay: Double

    var body: some View {
        VStack(spacing: 16) {
            // Circular progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.plumeTextSecondary.opacity(0.1), lineWidth: 12)

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            colors: [Color.plumeCurrentlyReading, Color.plumeAccentSecondary],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * progress)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)

                // Center text
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.plumeTextPrimary)

                    Text("complete")
                        .font(.system(size: 11))
                        .foregroundColor(.plumeTextSecondary)
                }
            }
            .frame(width: 140, height: 140)

            // Stats row
            HStack(spacing: 24) {
                StatItem(label: "Pages", value: "\(pagesRead)/\(totalPages)")
                StatItem(label: "Days", value: "\(daysReading)")
                StatItem(label: "Pace", value: String(format: "%.1f p/d", pagesPerDay))
            }
        }
        .padding(20)
        .background(Color.plumeSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.plumeTextPrimary)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.plumeTextSecondary)
        }
    }
}

// MARK: - Book Page Composition
struct BookPageComposition: View {
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(Color.plumeBackground)

            // Open book
            HStack(spacing: 2) {
                // Left page
                VStack(alignment: .leading, spacing: 8) {
                    // Chapter heading
                    Text("Chapter One")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.plumeTextSecondary)

                    // Text lines
                    ForEach(0..<8, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.plumeTextPrimary.opacity(0.6))
                            .frame(height: 2)
                            .cornerRadius(1)
                    }

                    Spacer()

                    // Page number
                    Text("12")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.plumeTextSecondary)

                    Spacer()

                    // More text lines
                    ForEach(0..<6, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.plumeTextPrimary.opacity(0.4))
                            .frame(height: 2)
                            .cornerRadius(1)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)

                // Spine
                Rectangle()
                    .fill(Color.plumeAccentSecondary)
                    .frame(width: 4)

                // Right page
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(0..<10, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.plumeTextPrimary.opacity(0.5))
                            .frame(height: 2)
                            .cornerRadius(1)
                    }

                    Spacer()

                    Text("13")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.plumeTextSecondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.9))
            }
            .frame(height: 200)
            .cornerRadius(4)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .padding(20)
        }
    }
}

// MARK: - Cover Placeholder Design
struct CoverPlaceholderDesignView: View {
    let bookTitle: String
    let author: String
    let colorHex: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: colorHex) ?? .brown, Color(hex: colorHex)?.opacity(0.7) ?? .brown],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Spacer()

                // Decorative line
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 40, height: 3)
                    .cornerRadius(2)

                Text(bookTitle)
                    .font(.custom("Georgia-Bold", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 12)

                Text(author)
                    .font(.custom("Georgia", size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 12)

                // Bottom decorative element
                Spacer()

                Rectangle()
                    .fill(Color.plumeAccentSecondary)
                    .frame(width: 50, height: 3)
                    .cornerRadius(2)
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 120, height: 180)
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Preview
#Preview("Quote Card") {
    QuoteCardView(
        quote: "So we beat on, boats against the current, borne back ceaselessly into the past.",
        bookTitle: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        citationStyle: .apa
    )
    .padding()
    .background(Color.plumeBackground)
}

#Preview("Reading Progress Visual") {
    ReadingProgressVisual(
        progress: 0.72,
        pagesRead: 130,
        totalPages: 180,
        daysReading: 12,
        pagesPerDay: 10.8
    )
    .padding()
    .background(Color.plumeBackground)
}

#Preview("Book Page Composition") {
    BookPageComposition()
        .frame(height: 240)
}

#Preview("Cover Placeholder Design") {
    HStack {
        CoverPlaceholderDesignView(
            bookTitle: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            colorHex: "#8b4513"
        )
        CoverPlaceholderDesignView(
            bookTitle: "Beloved",
            author: "Toni Morrison",
            colorHex: "#2d5a3d"
        )
    }
    .padding()
    .background(Color.plumeBackground)
}
