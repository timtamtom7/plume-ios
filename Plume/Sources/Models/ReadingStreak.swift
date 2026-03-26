import Foundation
import SQLite
import SwiftUI
import OSLog

// MARK: - Reading Streak Model
struct ReadingStreak: Identifiable, Equatable {
    let id: Int64
    var currentStreak: Int
    var longestStreak: Int
    var lastReadDate: Date?
    var totalDaysRead: Int

    var isStreakAlive: Bool {
        guard let lastRead = lastReadDate else { return false }
        return Calendar.current.isDateInToday(lastRead) || Calendar.current.isDateInYesterday(lastRead)
    }

    var streakMessage: String {
        if currentStreak == 0 {
            return "Start your streak today!"
        } else if currentStreak == 1 {
            return "1 day streak — keep it going!"
        } else {
            return "\(currentStreak)-day streak 🔥"
        }
    }
}

// MARK: - Daily Reading Log
struct DailyReadingLog: Identifiable, Equatable {
    let id: Int64
    var date: Date
    var pagesRead: Int
    var minutesRead: Int?
    var booksStarted: Int
    var booksFinished: Int
    var notesAdded: Int
    var quotesSaved: Int
}

// MARK: - Streak Store
final class StreakStore: ObservableObject {
    private var db: Connection?

    private let streakTable = Table("reading_streak")
    private let logTable = Table("daily_reading_log")

    // Streak columns
    private let id = Expression<Int64>("id")
    private let currentStreak = Expression<Int>("current_streak")
    private let longestStreak = Expression<Int>("longest_streak")
    private let lastReadDate = Expression<Date?>("last_read_date")
    private let totalDaysRead = Expression<Int>("total_days_read")

    // Log columns
    private let logId = Expression<Int64>("id")
    private let logDate = Expression<Date>("date")
    private let pagesRead = Expression<Int>("pages_read")
    private let minutesRead = Expression<Int?>("minutes_read")
    private let booksStarted = Expression<Int>("books_started")
    private let booksFinished = Expression<Int>("books_finished")
    private let notesAdded = Expression<Int>("notes_added")
    private let quotesSaved = Expression<Int>("quotes_saved")

    @Published var streak: ReadingStreak = ReadingStreak(id: 1, currentStreak: 0, longestStreak: 0, lastReadDate: nil, totalDaysRead: 0)
    @Published var recentLogs: [DailyReadingLog] = []
    @Published var isLoading = false

    init() {
        setupDatabase()
        loadStreak()
        loadRecentLogs()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
            let dbPath = documentsPath.appendingPathComponent("plume.sqlite3").path
            db = try Connection(dbPath)
            try createTables()
        } catch {
            os_log("Streak database setup error: %{public}@", log: .streak, type: .error, error.localizedDescription)
        }
    }

    private func createTables() throws {
        try db?.run(streakTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(currentStreak)
            t.column(longestStreak)
            t.column(lastReadDate)
            t.column(totalDaysRead)
        })

        try db?.run(logTable.create(ifNotExists: true) { t in
            t.column(logId, primaryKey: .autoincrement)
            t.column(logDate)
            t.column(pagesRead)
            t.column(minutesRead)
            t.column(booksStarted)
            t.column(booksFinished)
            t.column(notesAdded)
            t.column(quotesSaved)
        })
    }

    func loadStreak() {
        guard let db = db else { return }
        do {
            if let row = try db.pluck(streakTable) {
                var loadedStreak = ReadingStreak(
                    id: row[id],
                    currentStreak: row[currentStreak],
                    longestStreak: row[longestStreak],
                    lastReadDate: row[lastReadDate],
                    totalDaysRead: row[totalDaysRead]
                )
                // Check if streak needs to be reset (more than 1 day gap)
                if let lastRead = loadedStreak.lastReadDate {
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    let lastReadDay = calendar.startOfDay(for: lastRead)
                    let daysSince = calendar.dateComponents([.day], from: lastReadDay, to: today).day ?? 0
                    if daysSince > 1 {
                        loadedStreak = ReadingStreak(
                            id: loadedStreak.id,
                            currentStreak: 0,
                            longestStreak: loadedStreak.longestStreak,
                            lastReadDate: loadedStreak.lastReadDate,
                            totalDaysRead: loadedStreak.totalDaysRead
                        )
                        updateStreakRecord(loadedStreak)
                    }
                }
                streak = loadedStreak
            } else {
                // Create initial streak record
                let insert = streakTable.insert(
                    currentStreak <- 0,
                    longestStreak <- 0,
                    lastReadDate <- nil,
                    totalDaysRead <- 0
                )
                let rowId = try db.run(insert)
                streak = ReadingStreak(id: rowId, currentStreak: 0, longestStreak: 0, lastReadDate: nil, totalDaysRead: 0)
            }
        } catch {
            os_log("Load streak error: %{public}@", log: .streak, type: .error, error.localizedDescription)
        }
    }

    func loadRecentLogs() {
        guard let db = db else { return }
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        do {
            recentLogs = try db.prepare(
                logTable
                    .filter(logDate >= thirtyDaysAgo)
                    .order(logDate.desc)
            ).map { row in
                DailyReadingLog(
                    id: row[logId],
                    date: row[logDate],
                    pagesRead: row[pagesRead],
                    minutesRead: row[minutesRead],
                    booksStarted: row[booksStarted],
                    booksFinished: row[booksFinished],
                    notesAdded: row[notesAdded],
                    quotesSaved: row[quotesSaved]
                )
            }
        } catch {
            os_log("Load recent logs error: %{public}@", log: .streak, type: .error, error.localizedDescription)
        }
    }

    /// Call this when the user reads today (updates progress, adds quote, etc.)
    func recordReadingActivity(pagesRead delta: Int = 0, minutesRead m: Int? = nil, booksStarted started: Int = 0, booksFinished finished: Int = 0, notesAdded notes: Int = 0, quotesSaved quotes: Int = 0) {
        guard let db = db else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        do {
            // Check if today's log already exists
            let todayQuery = logTable.filter(logDate >= today && logDate < tomorrow)
            if let existingLog = try db.pluck(todayQuery) {
                // Update existing log
                let row = logTable.filter(logId == existingLog[logId])
                try db.run(row.update(
                    pagesRead <- existingLog[pagesRead] + delta,
                    minutesRead <- (existingLog[minutesRead] ?? 0) + (m ?? 0),
                    booksStarted <- existingLog[booksStarted] + started,
                    booksFinished <- existingLog[booksFinished] + finished,
                    notesAdded <- existingLog[notesAdded] + notes,
                    quotesSaved <- existingLog[quotesSaved] + quotes
                ))
            } else {
                // Create new log for today
                try db.run(logTable.insert(
                    logDate <- today,
                    pagesRead <- delta,
                    minutesRead <- m,
                    booksStarted <- started,
                    booksFinished <- finished,
                    notesAdded <- notes,
                    quotesSaved <- quotes
                ))
            }

            // Update streak if not already read today
            let alreadyReadToday = streak.lastReadDate.map { calendar.isDate($0, inSameDayAs: today) } ?? false
            if !alreadyReadToday {
                updateStreak()
            }

            loadRecentLogs()
            os_log("Recorded reading activity: +%d pages", log: .streak, type: .info, delta)
        } catch {
            os_log("Record reading activity error: %{public}@", log: .streak, type: .error, error.localizedDescription)
        }
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var newStreak = streak

        if let lastRead = newStreak.lastReadDate {
            let lastReadDay = calendar.startOfDay(for: lastRead)
            let daysSince = calendar.dateComponents([.day], from: lastReadDay, to: today).day ?? 0
            if daysSince == 1 {
                // Consecutive day — increment streak
                newStreak = ReadingStreak(
                    id: newStreak.id,
                    currentStreak: newStreak.currentStreak + 1,
                    longestStreak: max(newStreak.longestStreak, newStreak.currentStreak + 1),
                    lastReadDate: today,
                    totalDaysRead: newStreak.totalDaysRead + 1
                )
            } else {
                // Streak broken — reset
                newStreak = ReadingStreak(
                    id: newStreak.id,
                    currentStreak: 1,
                    longestStreak: max(newStreak.longestStreak, 1),
                    lastReadDate: today,
                    totalDaysRead: newStreak.totalDaysRead + 1
                )
            }
        } else {
            // First ever reading day
            newStreak = ReadingStreak(
                id: newStreak.id,
                currentStreak: 1,
                longestStreak: max(newStreak.longestStreak, 1),
                lastReadDate: today,
                totalDaysRead: newStreak.totalDaysRead + 1
            )
        }

        updateStreakRecord(newStreak)
        streak = newStreak
        os_log("Streak updated: current=%d, longest=%d", log: .streak, type: .info, newStreak.currentStreak, newStreak.longestStreak)
    }

    private func updateStreakRecord(_ updated: ReadingStreak) {
        guard let db = db else { return }
        do {
            let row = streakTable.filter(id == updated.id)
            try db.run(row.update(
                currentStreak <- updated.currentStreak,
                longestStreak <- updated.longestStreak,
                lastReadDate <- updated.lastReadDate,
                totalDaysRead <- updated.totalDaysRead
            ))
        } catch {
            os_log("Update streak record error: %{public}@", log: .streak, type: .error, error.localizedDescription)
        }
    }

    /// Returns true if the user has already logged reading activity today
    var hasReadToday: Bool {
        guard let lastRead = streak.lastReadDate else { return false }
        return Calendar.current.isDateInToday(lastRead)
    }

    /// Calendar data for the last 7 weeks (42 days) — for streak heatmap
    func readingHeatmap(days: Int = 42) -> [Date: Int] {
        var heatmap: [Date: Int] = [:]
        let calendar = Calendar.current
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                if let log = recentLogs.first(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
                    heatmap[startOfDay] = log.pagesRead
                }
            }
        }
        return heatmap
    }
}

// MARK: - OSLog extension
private extension OSLog {
    static let streak = OSLog(subsystem: "com.plume.app", category: "ReadingStreak")
}
