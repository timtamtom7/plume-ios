import SwiftUI

// MARK: - Streak View (Detail)
struct StreakView: View {
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var bookStore: BookStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Hero streak card
                        streakHeroCard

                        // Heatmap
                        heatmapSection

                        // Recent activity
                        recentActivitySection

                        // Stats grid
                        statsGrid
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Reading Streak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
        }
    }

    @ViewBuilder
    private var streakHeroCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                // Flame icon
                ZStack {
                    Circle()
                        .fill(streakStore.streak.currentStreak > 0 ? Color.orange.opacity(0.15) : Color.plumeTextSecondary.opacity(0.1))
                        .frame(width: 70, height: 70)

                    Image(systemName: streakStore.streak.currentStreak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 32))
                        .foregroundColor(streakStore.streak.currentStreak > 0 ? .orange : .plumeTextSecondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(streakStore.streak.currentStreak)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.plumeTextPrimary)

                    Text("day streak")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.plumeTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Best")
                        .font(.system(size: 11))
                        .foregroundColor(.plumeTextSecondary)

                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.plumeAccentSecondary)

                        Text("\(streakStore.streak.longestStreak)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.plumeAccentSecondary)
                    }
                }
            }
            .padding(20)

            Divider()

            HStack {
                Text(streakStore.streak.streakMessage)
                    .font(.system(size: 14))
                    .foregroundColor(streakStore.streak.currentStreak > 0 ? .plumeAccent : .plumeTextSecondary)

                Spacer()

                if !streakStore.streak.isStreakAlive && streakStore.streak.currentStreak > 0 {
                    Text("Streak at risk!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                } else if streakStore.streak.currentStreak > 0 {
                    Text("Streak active 🔥")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                } else {
                    Text("Read today to start!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.plumeTextSecondary)
                }
            }
            .padding(16)
        }
        .background(Color.plumeSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    @ViewBuilder
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reading Activity")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                streakHeatmapLegend
            }

            StreakHeatmapView(streakStore: streakStore)
        }
    }

    @ViewBuilder
    private var streakHeatmapLegend: some View {
        HStack(spacing: 4) {
            Text("Less")
                .font(.system(size: 9))
                .foregroundColor(.plumeTextSecondary)

            ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                RoundedRectangle(cornerRadius: 2)
                    .fill(intensity == 0 ? Color.plumeTextSecondary.opacity(0.1) : Color.plumeAccent.opacity(intensity))
                    .frame(width: 10, height: 10)
            }

            Text("More")
                .font(.system(size: 9))
                .foregroundColor(.plumeTextSecondary)
        }
    }

    @ViewBuilder
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(last7DaysLogs, id: \.date) { log in
                    DailyLogRow(log: log)

                    if log.id != last7DaysLogs.last?.id {
                        Divider()
                            .padding(.leading, 48)
                    }
                }

                if last7DaysLogs.isEmpty {
                    Text("No reading activity in the last 7 days")
                        .font(.system(size: 14))
                        .foregroundColor(.plumeTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
            .padding(.vertical, 4)
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }

    private var last7DaysLogs: [DailyReadingLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { dayOffset -> DailyReadingLog? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            return streakStore.recentLogs.first { calendar.isDate($0.date, inSameDayAs: date) }
                ?? DailyReadingLog(id: Int64(dayOffset), date: date, pagesRead: 0, minutesRead: nil, booksStarted: 0, booksFinished: 0, notesAdded: 0, quotesSaved: 0)
        }
    }

    @ViewBuilder
    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All-Time Stats")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StreakStatCard(
                    title: "Total Days Read",
                    value: "\(streakStore.streak.totalDaysRead)",
                    icon: "calendar",
                    color: .plumeAccent
                )

                StreakStatCard(
                    title: "Longest Streak",
                    value: "\(streakStore.streak.longestStreak) days",
                    icon: "trophy.fill",
                    color: .plumeAccentSecondary
                )

                StreakStatCard(
                    title: "Books Finished",
                    value: "\(bookStore.finishedBooks.count)",
                    icon: "books.vertical.fill",
                    color: .plumeFinished
                )

                StreakStatCard(
                    title: "Notes Written",
                    value: "\(streakStore.recentLogs.reduce(0) { $0 + $1.notesAdded })",
                    icon: "note.text",
                    color: .orange
                )
            }
        }
    }
}

// MARK: - Daily Log Row
struct DailyLogRow: View {
    let log: DailyReadingLog

    private var isToday: Bool {
        Calendar.current.isDateInToday(log.date)
    }

    private var hasActivity: Bool {
        log.pagesRead > 0 || log.booksStarted > 0 || log.booksFinished > 0 || log.notesAdded > 0 || log.quotesSaved > 0
    }

    var body: some View {
        HStack(spacing: 12) {
            // Day indicator
            VStack(spacing: 2) {
                Text(dayOfWeek)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.plumeTextSecondary)

                Text(dayNumber)
                    .font(.system(size: 16, weight: isToday ? .bold : .semibold))
                    .foregroundColor(isToday ? .plumeAccent : .plumeTextPrimary)
            }
            .frame(width: 36)

            // Activity summary
            VStack(alignment: .leading, spacing: 2) {
                if hasActivity {
                    Text(activitySummary)
                        .font(.system(size: 13))
                        .foregroundColor(.plumeTextPrimary)
                        .lineLimit(1)
                } else {
                    Text("No reading activity")
                        .font(.system(size: 13))
                        .foregroundColor(.plumeTextSecondary.opacity(0.6))
                }
            }

            Spacer()

            // Status icon
            if hasActivity {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeAccent)
            } else {
                Image(systemName: "minus.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary.opacity(0.3))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .accessibilityLabel("\(dayOfWeek) \(dayNumber): \(hasActivity ? activitySummary : "no activity")")
    }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: log.date).uppercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: log.date)
    }

    private var activitySummary: String {
        var parts: [String] = []
        if log.pagesRead > 0 { parts.append("\(log.pagesRead) pages") }
        if log.booksStarted > 0 { parts.append("\(log.booksStarted) started") }
        if log.booksFinished > 0 { parts.append("\(log.booksFinished) finished") }
        if log.notesAdded > 0 { parts.append("\(log.notesAdded) notes") }
        if log.quotesSaved > 0 { parts.append("\(log.quotesSaved) quotes") }
        return parts.isEmpty ? "" : parts.joined(separator: " · ")
    }
}

// MARK: - Streak Stat Card
struct StreakStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.plumeTextPrimary)

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.plumeTextSecondary)
        }
        .padding(14)
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Streak Heatmap View
struct StreakHeatmapView: View {
    @ObservedObject var streakStore: StreakStore

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weeks = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Day labels
            HStack(spacing: 4) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.plumeTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Heatmap grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<(weeks * 7), id: \.self) { index in
                    let date = heatmapDate(for: index)
                    let pages = pagesForDate(date)
                    let intensity = intensityForPages(pages)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(intensity == 0 ? Color.plumeTextSecondary.opacity(0.1) : Color.plumeAccent.opacity(intensity))
                        .aspectRatio(1, contentMode: .fit)
                        .accessibilityLabel("\(formattedDate(date)): \(pages > 0 ? "\(pages) pages" : "no activity")")
                }
            }
        }
        .padding(16)
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func heatmapDate(for index: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today) - 1
        let daysFromStart = (weeks * 7) - 1 - index
        return calendar.date(byAdding: .day, value: -daysFromStart, to: today) ?? today
    }

    private func pagesForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        return streakStore.recentLogs.first { calendar.isDate($0.date, inSameDayAs: date) }?.pagesRead ?? 0
    }

    private func intensityForPages(_ pages: Int) -> Double {
        if pages == 0 { return 0 }
        if pages < 10 { return 0.25 }
        if pages < 30 { return 0.5 }
        if pages < 60 { return 0.75 }
        return 1.0
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    StreakView()
        .environmentObject(StreakStore())
        .environmentObject(BookStore())
}
