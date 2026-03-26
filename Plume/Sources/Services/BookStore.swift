import Foundation
import SQLite
import SwiftUI

final class BookStore: ObservableObject {
    private var db: Connection?

    // Tables
    private let books = Table("books")
    private let progressEntries = Table("progress_entries")

    // Book columns
    private let id = Expression<Int64>("id")
    private let title = Expression<String>("title")
    private let author = Expression<String>("author")
    private let totalPages = Expression<Int>("total_pages")
    private let currentPage = Expression<Int>("current_page")
    private let coverImagePath = Expression<String?>("cover_image_path")
    private let placeholderColorHex = Expression<String>("placeholder_color_hex")
    private let startDate = Expression<Date>("start_date")
    private let finishDate = Expression<Date?>("finish_date")
    private let isFinished = Expression<Bool>("is_finished")

    // Progress columns
    private let progressId = Expression<Int64>("id")
    private let progressBookId = Expression<Int64>("book_id")
    private let progressPage = Expression<Int>("page")
    private let progressDate = Expression<Date>("date")

    @Published var allBooks: [Book] = []

    init() {
        setupDatabase()
        loadBooks()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
            let dbPath = documentsPath.appendingPathComponent("plume.sqlite3").path
            db = try Connection(dbPath)
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(books.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(title)
            t.column(author)
            t.column(totalPages)
            t.column(currentPage)
            t.column(coverImagePath)
            t.column(placeholderColorHex)
            t.column(startDate)
            t.column(finishDate)
            t.column(isFinished)
        })

        try db?.run(progressEntries.create(ifNotExists: true) { t in
            t.column(progressId, primaryKey: .autoincrement)
            t.column(progressBookId)
            t.column(progressPage)
            t.column(progressDate)
        })
    }

    func loadBooks() {
        guard let db = db else { return }
        do {
            allBooks = try db.prepare(books.order(startDate.desc)).map { row in
                Book(
                    id: row[id],
                    title: row[title],
                    author: row[author],
                    totalPages: row[totalPages],
                    currentPage: row[currentPage],
                    coverImagePath: row[coverImagePath],
                    placeholderColorHex: row[placeholderColorHex],
                    startDate: row[startDate],
                    finishDate: row[finishDate],
                    isFinished: row[isFinished]
                )
            }
        } catch {
            print("Load books error: \(error)")
        }
    }

    func addBook(title t: String, author a: String, totalPages tp: Int, coverPath: String?, startPage: Int = 1) -> Book? {
        guard let db = db else { return nil }

        let colorHex = generatePlaceholderColor(for: t)
        let now = Date()

        do {
            let insert = books.insert(
                title <- t,
                author <- a,
                totalPages <- tp,
                currentPage <- startPage,
                coverImagePath <- coverPath,
                placeholderColorHex <- colorHex,
                startDate <- now,
                finishDate <- nil,
                isFinished <- false
            )
            let rowId = try db.run(insert)

            // Log initial progress entry
            let progressInsert = progressEntries.insert(
                progressBookId <- rowId,
                progressPage <- startPage,
                progressDate <- now
            )
            try db.run(progressInsert)

            let book = Book(
                id: rowId,
                title: t,
                author: a,
                totalPages: tp,
                currentPage: startPage,
                coverImagePath: coverPath,
                placeholderColorHex: colorHex,
                startDate: now,
                finishDate: nil,
                isFinished: false
            )
            loadBooks()
            return book
        } catch {
            print("Add book error: \(error)")
            return nil
        }
    }

    func updateProgress(bookId bid: Int64, newPage: Int) {
        guard let db = db else { return }

        let book = books.filter(id == bid)
        let now = Date()
        let finished = newPage >= (allBooks.first { $0.id == bid }?.totalPages ?? 0)

        do {
            try db.run(book.update(
                currentPage <- newPage,
                finishDate <- (finished ? now : nil),
                isFinished <- finished
            ))

            let progressInsert = progressEntries.insert(
                progressBookId <- bid,
                progressPage <- newPage,
                progressDate <- now
            )
            try db.run(progressInsert)

            loadBooks()
        } catch {
            print("Update progress error: \(error)")
        }
    }

    func getProgressEntries(forBookId bid: Int64) -> [ProgressEntry] {
        guard let db = db else { return [] }
        do {
            return try db.prepare(
                progressEntries
                    .filter(progressBookId == bid)
                    .order(progressDate.asc)
            ).map { row in
                ProgressEntry(
                    id: row[progressId],
                    bookId: row[progressBookId],
                    page: row[progressPage],
                    date: row[progressDate]
                )
            }
        } catch {
            print("Get progress entries error: \(error)")
            return []
        }
    }

    func deleteBook(_ book: Book) {
        guard let db = db else { return }
        do {
            let bookRow = books.filter(id == book.id)
            try db.run(bookRow.delete())
            let entries = progressEntries.filter(progressBookId == book.id)
            try db.run(entries.delete())

            if let path = book.coverImagePath {
                try? FileManager.default.removeItem(atPath: path)
            }
            loadBooks()
        } catch {
            print("Delete book error: \(error)")
        }
    }

    var currentlyReading: [Book] {
        allBooks.filter { !$0.isFinished }
    }

    var finishedBooks: [Book] {
        allBooks.filter { $0.isFinished }
    }

    private func generatePlaceholderColor(for text: String) -> String {
        let colors = [
            "#8b4513", "#2d5a3d", "#4a3728", "#1e4d6b",
            "#5c3d2e", "#2c4a3e", "#3d2c4a", "#4a2c3d"
        ]
        let hash = abs(text.hashValue)
        return colors[hash % colors.count]
    }
}
