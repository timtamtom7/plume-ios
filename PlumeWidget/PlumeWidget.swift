import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct PlumeWidgetEntry: TimelineEntry {
    let date: Date
    let bookTitle: String
    let bookAuthor: String
    let currentPage: Int
    let totalPages: Int
    let progressPercent: Double
    let estimatedFinishDate: String?
    let coverColorHex: String
}

// MARK: - Timeline Provider
struct PlumeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlumeWidgetEntry {
        PlumeWidgetEntry(
            date: Date(),
            bookTitle: "The Great Gatsby",
            bookAuthor: "F. Scott Fitzgerald",
            currentPage: 126,
            totalPages: 180,
            progressPercent: 0.70,
            estimatedFinishDate: "Apr 2",
            coverColorHex: "#8b4513"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PlumeWidgetEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlumeWidgetEntry>) -> Void) {
        let entry = loadCurrentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCurrentEntry() -> PlumeWidgetEntry {
        // Load from shared UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.plume.app") ?? .standard

        let title = defaults.string(forKey: "widget.currentBook.title") ?? "No book started"
        let author = defaults.string(forKey: "widget.currentBook.author") ?? ""
        let currentPage = defaults.integer(forKey: "widget.currentBook.currentPage")
        let totalPages = defaults.integer(forKey: "widget.currentBook.totalPages")
        let finishDateString = defaults.string(forKey: "widget.currentBook.finishDate")
        let colorHex = defaults.string(forKey: "widget.currentBook.color") ?? "#8b4513"

        let progress = totalPages > 0 ? Double(currentPage) / Double(totalPages) : 0

        return PlumeWidgetEntry(
            date: Date(),
            bookTitle: title,
            bookAuthor: author,
            currentPage: currentPage,
            totalPages: totalPages,
            progressPercent: progress,
            estimatedFinishDate: finishDateString,
            coverColorHex: colorHex
        )
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: PlumeWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: entry.coverColorHex) ?? .brown)
                Text("Plume")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            Spacer()

            // Book info
            if entry.totalPages > 0 {
                Text(entry.bookTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(entry.bookAuthor)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                // Progress
                ProgressView(value: entry.progressPercent)
                    .tint(Color(hex: entry.coverColorHex) ?? .brown)

                HStack {
                    Text("\(Int(entry.progressPercent * 100))%")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("p. \(entry.currentPage)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("No book started")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("Open Plume to start tracking")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: PlumeWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            // Cover placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: entry.coverColorHex) ?? .brown,
                                Color(hex: entry.coverColorHex)?.opacity(0.7) ?? .brown
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 4) {
                    Text(entry.bookTitle.prefix(1))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 60, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: entry.coverColorHex) ?? .brown)
                    Text("Currently Reading")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                if entry.totalPages > 0 {
                    // Title & Author
                    Text(entry.bookTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(entry.bookAuthor)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: entry.coverColorHex) ?? .brown)
                                .frame(width: geo.size.width * entry.progressPercent)
                        }
                    }
                    .frame(height: 4)

                    // Stats row
                    HStack {
                        Text("\(entry.currentPage) / \(entry.totalPages) pages")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)

                        Spacer()

                        if let finishDate = entry.estimatedFinishDate {
                            HStack(spacing: 2) {
                                Image(systemName: "clock")
                                    .font(.system(size: 9))
                                Text(finishDate)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(Color(hex: entry.coverColorHex) ?? .brown)
                        }
                    }
                } else {
                    Spacer()
                    Text("Start a book in Plume")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(12)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration
struct PlumeWidget: Widget {
    let kind: String = "PlumeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlumeWidgetProvider()) { entry in
            PlumeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Reading Progress")
        .description("Track your current book's progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PlumeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PlumeWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Color Extension for Widget
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        default:
            return nil
        }

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview
#Preview("Small", as: .systemSmall) {
    PlumeWidget()
} timeline: {
    PlumeWidgetEntry(
        date: Date(),
        bookTitle: "The Great Gatsby",
        bookAuthor: "F. Scott Fitzgerald",
        currentPage: 126,
        totalPages: 180,
        progressPercent: 0.70,
        estimatedFinishDate: "Apr 2",
        coverColorHex: "#8b4513"
    )
}

#Preview("Medium", as: .systemMedium) {
    PlumeWidget()
} timeline: {
    PlumeWidgetEntry(
        date: Date(),
        bookTitle: "The Great Gatsby",
        bookAuthor: "F. Scott Fitzgerald",
        currentPage: 126,
        totalPages: 180,
        progressPercent: 0.70,
        estimatedFinishDate: "Apr 2",
        coverColorHex: "#8b4513"
    )
}
