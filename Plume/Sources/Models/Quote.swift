import Foundation
import SQLite
import SwiftUI

// MARK: - Quote Model
struct Quote: Identifiable, Equatable, Codable {
    let id: Int64
    var bookId: Int64?
    var bookTitle: String
    var bookAuthor: String
    var text: String
    var pageNumber: Int?
    var isPublic: Bool
    var isFavorite: Bool
    var createdAt: Date

    var citation: String {
        var result = "\"\(text)\"\n— \(bookAuthor), \(bookTitle)"
        if let page = pageNumber {
            result += ", p. \(page)"
        }
        return result
    }
}

// MARK: - Quote Store
final class QuoteStore: ObservableObject {
    private var db: Connection?

    private let quotes = Table("quotes")
    private let id = Expression<Int64>("id")
    private let bookId = Expression<Int64?>("book_id")
    private let bookTitle = Expression<String>("book_title")
    private let bookAuthor = Expression<String>("book_author")
    private let text = Expression<String>("text")
    private let pageNumber = Expression<Int?>("page_number")
    private let isPublic = Expression<Bool>("is_public")
    private let isFavorite = Expression<Bool>("is_favorite")
    private let createdAt = Expression<Date>("created_at")

    @Published var allQuotes: [Quote] = []
    @Published var publicQuotes: [Quote] = []
    @Published var favoriteQuotes: [Quote] = []

    init() {
        setupDatabase()
        loadQuotes()
        generateSamplePublicQuotes()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = documentsPath.appendingPathComponent("plume.sqlite3").path
            db = try Connection(dbPath)
            try createTables()
        } catch {
            print("Quote database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(quotes.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(bookId)
            t.column(bookTitle)
            t.column(bookAuthor)
            t.column(text)
            t.column(pageNumber)
            t.column(isPublic)
            t.column(isFavorite)
            t.column(createdAt)
        })
    }

    func loadQuotes() {
        guard let db = db else { return }
        do {
            allQuotes = try db.prepare(quotes.order(createdAt.desc)).map { row in
                Quote(
                    id: row[id],
                    bookId: row[bookId],
                    bookTitle: row[bookTitle],
                    bookAuthor: row[bookAuthor],
                    text: row[text],
                    pageNumber: row[pageNumber],
                    isPublic: row[isPublic],
                    isFavorite: row[isFavorite],
                    createdAt: row[createdAt]
                )
            }
            publicQuotes = allQuotes.filter { $0.isPublic }
            favoriteQuotes = allQuotes.filter { $0.isFavorite }
        } catch {
            print("Load quotes error: \(error)")
        }
    }

    @discardableResult
    func addQuote(text t: String, bookTitle bt: String, bookAuthor ba: String, bookId bid: Int64? = nil, pageNumber pn: Int? = nil) -> Quote? {
        guard let db = db else { return nil }

        do {
            let insert = quotes.insert(
                bookId <- bid,
                bookTitle <- bt,
                bookAuthor <- ba,
                text <- t,
                pageNumber <- pn,
                isPublic <- false,
                isFavorite <- false,
                createdAt <- Date()
            )
            let rowId = try db.run(insert)
            let quote = Quote(
                id: rowId,
                bookId: bid,
                bookTitle: bt,
                bookAuthor: ba,
                text: t,
                pageNumber: pn,
                isPublic: false,
                isFavorite: false,
                createdAt: Date()
            )
            loadQuotes()
            return quote
        } catch {
            print("Add quote error: \(error)")
            return nil
        }
    }

    func togglePublic(_ quote: Quote) {
        guard let db = db else { return }
        let row = quotes.filter(id == quote.id)
        do {
            try db.run(row.update(isPublic <- !quote.isPublic))
            loadQuotes()
        } catch {
            print("Toggle public error: \(error)")
        }
    }

    func toggleFavorite(_ quote: Quote) {
        guard let db = db else { return }
        let row = quotes.filter(id == quote.id)
        do {
            try db.run(row.update(isFavorite <- !quote.isFavorite))
            loadQuotes()
        } catch {
            print("Toggle favorite error: \(error)")
        }
    }

    func deleteQuote(_ quote: Quote) {
        guard let db = db else { return }
        let row = quotes.filter(id == quote.id)
        do {
            try db.run(row.delete())
            loadQuotes()
        } catch {
            print("Delete quote error: \(error)")
        }
    }

    func quotesForBook(_ book: Book) -> [Quote] {
        allQuotes.filter { $0.bookId == book.id }
    }

    private func generateSamplePublicQuotes() {
        // Add some sample public quotes if empty
        guard allQuotes.isEmpty else { return }

        let samples: [(String, String, String, Int)] = [
            ("So we beat on, boats against the current, borne back ceaselessly into the past.", "The Great Gatsby", "F. Scott Fitzgerald", 180),
            ("And, when you want something, all the universe conspires in helping you to achieve it.", "The Alchemist", "Paulo Coelho", 208),
            ("You are what you do. Not what you say you'll do.", "Atomic Habits", "James Clear", 45),
            ("It is not in the stars to hold our destiny but in ourselves.", "Julius Caesar", "William Shakespeare", 42),
            ("The only way to do great work is to love what you do.", "Steve Jobs", "Walter Isaacson", 1),
        ]

        for (text, title, author, page) in samples {
            addQuote(text: text, bookTitle: title, bookAuthor: author, pageNumber: page)
            // Make them public for demo
            if let quote = allQuotes.first(where: { $0.text == text && $0.bookTitle == title }) {
                togglePublic(quote)
            }
        }
    }
}

// MARK: - Community Feed Quote (for display)
struct CommunityQuote: Identifiable {
    let id: UUID
    let quote: String
    let bookTitle: String
    let author: String
    let likes: Int
    let shares: Int
    let timeAgo: String

    static let samples: [CommunityQuote] = [
        CommunityQuote(id: UUID(), quote: "So we beat on, boats against the current, borne back ceaselessly into the past.", bookTitle: "The Great Gatsby", author: "F. Scott Fitzgerald", likes: 247, shares: 89, timeAgo: "2h ago"),
        CommunityQuote(id: UUID(), quote: "And, when you want something, all the universe conspires in helping you to achieve it.", bookTitle: "The Alchemist", author: "Paulo Coelho", likes: 312, shares: 104, timeAgo: "4h ago"),
        CommunityQuote(id: UUID(), quote: "You are what you do. Not what you say you'll do.", bookTitle: "Atomic Habits", author: "James Clear", likes: 189, shares: 67, timeAgo: "6h ago"),
        CommunityQuote(id: UUID(), quote: "It is not in the stars to hold our destiny but in ourselves.", bookTitle: "Julius Caesar", author: "William Shakespeare", likes: 156, shares: 45, timeAgo: "8h ago"),
        CommunityQuote(id: UUID(), quote: "The only way to do great work is to love what you do.", bookTitle: "Steve Jobs", author: "Walter Isaacson", likes: 423, shares: 156, timeAgo: "12h ago"),
    ]
}
