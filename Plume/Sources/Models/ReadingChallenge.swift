import Foundation
import SQLite
import SwiftUI

// MARK: - Reading Challenge Model
struct ReadingChallenge: Identifiable, Equatable {
    let id: Int64
    var year: Int
    var annualGoal: Int
    var booksCompleted: Int
    var isActive: Bool

    var progressPercent: Double {
        guard annualGoal > 0 else { return 0 }
        return min(Double(booksCompleted) / Double(annualGoal), 1.0)
    }

    var booksRemaining: Int {
        max(annualGoal - booksCompleted, 0)
    }

    var isOnTrack: Bool {
        let calendar = Calendar.current
        let now = Date()
        // Check that we can construct a valid date for the year
        guard calendar.date(from: calendar.dateComponents([.year], from: now)) != nil else { return false }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let totalDaysInYear = calendar.range(of: .day, in: .year, for: now)?.count ?? 365
        let expectedProgress = Double(dayOfYear) / Double(totalDaysInYear)
        let expectedBooks = Int(Double(annualGoal) * expectedProgress)
        return booksCompleted >= expectedBooks
    }

    var paceMessage: String? {
        if booksRemaining == 0 {
            return "🎉 Challenge complete! You've read \(annualGoal) books this year!"
        }
        if isOnTrack {
            return "✅ You're on track! Keep the momentum."
        }
        let needed = booksRemaining
        return "📚 You're behind pace — read \(needed) more book\(needed == 1 ? "" : "s") to catch up."
    }
}

// MARK: - Monthly Mini Challenge
struct MonthlyChallenge: Identifiable, Equatable {
    let id: Int64
    var month: Int
    var year: Int
    var challengeType: ChallengeType
    var challengeText: String
    var isCompleted: Bool
    var completedDate: Date?

    enum ChallengeType: String, CaseIterable {
        case biography = "biography"
        case classic = "classic"
        case nonFiction = "non_fiction"
        case poetry = "poetry"
        case shortBook = "short_book"
        case translated = "translated"
        case memoir = "memoir"
        case sciFi = "science_fiction"
        case history = "history"
        case philosophy = "philosophy"

        var displayName: String {
            switch self {
            case .biography: return "Biography"
            case .classic: return "Classic"
            case .nonFiction: return "Non-Fiction"
            case .poetry: return "Poetry"
            case .shortBook: return "Short Book (<150 pages)"
            case .translated: return "Translated Work"
            case .memoir: return "Memoir"
            case .sciFi: return "Science Fiction"
            case .history: return "History"
            case .philosophy: return "Philosophy"
            }
        }

        var icon: String {
            switch self {
            case .biography: return "person.fill"
            case .classic: return "book.fill"
            case .nonFiction: return "doc.text.fill"
            case .poetry: return "text.quote"
            case .shortBook: return "book.circle"
            case .translated: return "globe"
            case .memoir: return "heart.fill"
            case .sciFi: return "sparkles"
            case .history: return "clock.fill"
            case .philosophy: return "brain.head.profile"
            }
        }
    }

    static let challengePrompts: [ChallengeType: [String]] = [
        .biography: ["Read a biography this month", "Dive into someone's life story", "Learn from a biography"],
        .classic: ["Tackle a literary classic", "Read a book published before 1960", "Explore timeless literature"],
        .nonFiction: ["Read a non-fiction book", "Learn something new", "Expand your knowledge"],
        .poetry: ["Read a poetry collection", "Enjoy some verse", "Experience poetry this month"],
        .shortBook: ["Finish a short book (under 150 pages)", "Quick read challenge", "Speed through a short book"],
        .translated: ["Read a translated work", "Explore international literature", "Read something originally in another language"],
        .memoir: ["Read a memoir", "Explore someone's life story", "Dive into personal history"],
        .sciFi: ["Read a science fiction book", "Explore futuristic worlds", "Dive into sci-fi"],
        .history: ["Read a history book", "Learn about the past", "Explore historical events"],
        .philosophy: ["Read philosophy this month", "Think deep thoughts", "Explore ideas and ethics"],
    ]

    var formattedDate: String {
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: year, month: month)) else { return "\(month)/\(year)" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Challenge Store
final class ChallengeStore: ObservableObject {
    private var db: Connection?

    // Tables
    private let challenges = Table("reading_challenges")
    private let monthlyChallenges = Table("monthly_challenges")

    // Challenge columns
    private let id = Expression<Int64>("id")
    private let year = Expression<Int>("year")
    private let annualGoal = Expression<Int>("annual_goal")
    private let booksCompleted = Expression<Int>("books_completed")
    private let isActive = Expression<Bool>("is_active")

    // Monthly challenge columns
    private let monthCol = Expression<Int>("month")
    private let challengeType = Expression<String>("challenge_type")
    private let challengeText = Expression<String>("challenge_text")
    private let isCompleted = Expression<Bool>("is_completed")
    private let completedDate = Expression<Date?>("completed_date")

    @Published var currentChallenge: ReadingChallenge?
    @Published var currentMonthlyChallenge: MonthlyChallenge?
    @Published var monthlyChallengesHistory: [MonthlyChallenge] = []

    init() {
        setupDatabase()
        loadCurrentChallenge()
        loadCurrentMonthlyChallenge()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
            let dbPath = documentsPath.appendingPathComponent("plume.sqlite3").path
            db = try Connection(dbPath)
            try createTables()
        } catch {
            print("Challenge database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(challenges.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(year)
            t.column(annualGoal)
            t.column(booksCompleted)
            t.column(isActive)
        })

        try db?.run(monthlyChallenges.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(monthCol)
            t.column(year)
            t.column(challengeType)
            t.column(challengeText)
            t.column(isCompleted)
            t.column(completedDate)
        })
    }

    func loadCurrentChallenge() {
        guard let db = db else { return }
        let currentYear = Calendar.current.component(.year, from: Date())

        do {
            if let row = try db.pluck(challenges.filter(year == currentYear && isActive == true)) {
                currentChallenge = ReadingChallenge(
                    id: row[id],
                    year: row[year],
                    annualGoal: row[annualGoal],
                    booksCompleted: row[booksCompleted],
                    isActive: row[isActive]
                )
            }
        } catch {
            print("Load challenge error: \(error)")
        }
    }

    func loadCurrentMonthlyChallenge() {
        guard let db = db else { return }
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        do {
            if let row = try db.pluck(monthlyChallenges.filter(monthCol == currentMonth && year == currentYear)) {
                currentMonthlyChallenge = MonthlyChallenge(
                    id: row[id],
                    month: row[monthCol],
                    year: row[year],
                    challengeType: MonthlyChallenge.ChallengeType(rawValue: row[challengeType]) ?? .biography,
                    challengeText: row[challengeText],
                    isCompleted: row[isCompleted],
                    completedDate: row[completedDate]
                )
            } else {
                // Create a new monthly challenge
                createMonthlyChallenge()
            }
        } catch {
            print("Load monthly challenge error: \(error)")
        }
    }

    func loadMonthlyChallengesHistory() {
        guard let db = db else { return }
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())

        do {
            monthlyChallengesHistory = try db.prepare(monthlyChallenges.filter(year == currentYear).order(monthCol.desc)).map { row in
                MonthlyChallenge(
                    id: row[id],
                    month: row[monthCol],
                    year: row[year],
                    challengeType: MonthlyChallenge.ChallengeType(rawValue: row[challengeType]) ?? .biography,
                    challengeText: row[challengeText],
                    isCompleted: row[isCompleted],
                    completedDate: row[completedDate]
                )
            }
        } catch {
            print("Load monthly challenges history error: \(error)")
        }
    }

    func createChallenge(goal: Int) {
        guard let db = db else { return }
        let currentYear = Calendar.current.component(.year, from: Date())

        // Deactivate existing challenges for this year
        do {
            let existing = challenges.filter(year == currentYear && isActive == true)
            try db.run(existing.update(isActive <- false))
        } catch {
            print("Deactivate challenge error: \(error)")
        }

        // Create new challenge
        do {
            let insert = challenges.insert(
                year <- currentYear,
                annualGoal <- goal,
                booksCompleted <- 0,
                isActive <- true
            )
            let rowId = try db.run(insert)
            currentChallenge = ReadingChallenge(
                id: rowId,
                year: currentYear,
                annualGoal: goal,
                booksCompleted: 0,
                isActive: true
            )
        } catch {
            print("Create challenge error: \(error)")
        }
    }

    func updateAnnualGoal(_ newGoal: Int) {
        guard let db = db, let challenge = currentChallenge else { return }
        do {
            let challengeRow = challenges.filter(id == challenge.id)
            try db.run(challengeRow.update(annualGoal <- newGoal))
            loadCurrentChallenge()
        } catch {
            print("Update goal error: \(error)")
        }
    }

    func incrementBooksCompleted() {
        guard let db = db, let challenge = currentChallenge else { return }
        do {
            let challengeRow = challenges.filter(id == challenge.id)
            try db.run(challengeRow.update(booksCompleted <- challenge.booksCompleted + 1))
            loadCurrentChallenge()
        } catch {
            print("Increment books error: \(error)")
        }
    }

    private func createMonthlyChallenge() {
        guard let db = db else { return }
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        // Pick a random challenge type
        let allTypes = MonthlyChallenge.ChallengeType.allCases
        let randomType = allTypes.randomElement() ?? .biography
        let prompts = MonthlyChallenge.challengePrompts[randomType] ?? ["Read a book this month"]
        let randomPrompt = prompts.randomElement() ?? "Read a book this month"

        do {
            let insert = monthlyChallenges.insert(
                monthCol <- currentMonth,
                year <- currentYear,
                challengeType <- randomType.rawValue,
                challengeText <- randomPrompt,
                isCompleted <- false,
                completedDate <- nil
            )
            let rowId = try db.run(insert)
            currentMonthlyChallenge = MonthlyChallenge(
                id: rowId,
                month: currentMonth,
                year: currentYear,
                challengeType: randomType,
                challengeText: randomPrompt,
                isCompleted: false,
                completedDate: nil
            )
        } catch {
            print("Create monthly challenge error: \(error)")
        }
    }

    func markMonthlyChallengeComplete() {
        guard let db = db, let challenge = currentMonthlyChallenge else { return }
        do {
            let challengeRow = monthlyChallenges.filter(id == challenge.id)
            try db.run(challengeRow.update(
                isCompleted <- true,
                completedDate <- Date()
            ))
            loadCurrentMonthlyChallenge()
        } catch {
            print("Mark monthly complete error: \(error)")
        }
    }

    func generateNewMonthlyChallenge() {
        guard let db = db else { return }
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        // Delete current if exists
        do {
            let current = monthlyChallenges.filter(monthCol == currentMonth && year == currentYear)
            try db.run(current.delete())
        } catch {
            print("Delete current challenge error: \(error)")
        }

        // Create new
        createMonthlyChallenge()
    }
}
