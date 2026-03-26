import Foundation
import SQLite
import SwiftUI
import OSLog

// MARK: - Note Model
struct Note: Identifiable, Equatable, Codable {
    let id: Int64
    var bookId: Int64?
    var bookTitle: String
    var bookAuthor: String
    var text: String
    var pageNumber: Int?
    var chapterTitle: String?
    var createdAt: Date
    var updatedAt: Date
}

// MARK: - Note Store
final class NoteStore: ObservableObject {
    private var db: Connection?

    private let notes = Table("notes")
    private let id = Expression<Int64>("id")
    private let bookId = Expression<Int64?>("book_id")
    private let bookTitle = Expression<String>("book_title")
    private let bookAuthor = Expression<String>("book_author")
    private let text = Expression<String>("text")
    private let pageNumber = Expression<Int?>("page_number")
    private let chapterTitle = Expression<String?>("chapter_title")
    private let createdAt = Expression<Date>("created_at")
    private let updatedAt = Expression<Date>("updated_at")

    @Published var allNotes: [Note] = []

    init() {
        setupDatabase()
        loadNotes()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
            let dbPath = documentsPath.appendingPathComponent("plume.sqlite3").path
            db = try Connection(dbPath)
            try createTables()
        } catch {
            os_log("Note database setup error: %{public}@", log: .notes, type: .error, error.localizedDescription)
        }
    }

    private func createTables() throws {
        try db?.run(notes.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(bookId)
            t.column(bookTitle)
            t.column(bookAuthor)
            t.column(text)
            t.column(pageNumber)
            t.column(chapterTitle)
            t.column(createdAt)
            t.column(updatedAt)
        })
    }

    func loadNotes() {
        guard let db = db else { return }
        do {
            allNotes = try db.prepare(notes.order(updatedAt.desc)).compactMap { row -> Note? in
                let rawText = row[text]
                guard !rawText.isEmpty else { return nil }
                return Note(
                    id: row[id],
                    bookId: row[bookId],
                    bookTitle: row[bookTitle],
                    bookAuthor: row[bookAuthor],
                    text: rawText,
                    pageNumber: row[pageNumber],
                    chapterTitle: row[chapterTitle],
                    createdAt: row[createdAt],
                    updatedAt: row[updatedAt]
                )
            }
        } catch {
            os_log("Load notes error: %{public}@", log: .notes, type: .error, error.localizedDescription)
        }
    }

    @discardableResult
    func addNote(text t: String, bookTitle bt: String, bookAuthor ba: String, bookId bid: Int64? = nil, pageNumber pn: Int? = nil, chapterTitle ct: String? = nil) -> Note? {
        guard let db = db else { return nil }
        let now = Date()

        do {
            let insert = notes.insert(
                bookId <- bid,
                bookTitle <- bt,
                bookAuthor <- ba,
                text <- t,
                pageNumber <- pn,
                chapterTitle <- ct,
                createdAt <- now,
                updatedAt <- now
            )
            let rowId = try db.run(insert)
            let note = Note(
                id: rowId,
                bookId: bid,
                bookTitle: bt,
                bookAuthor: ba,
                text: t,
                pageNumber: pn,
                chapterTitle: ct,
                createdAt: now,
                updatedAt: now
            )
            loadNotes()
            os_log("Added note %{public}d for book %{public}@", log: .notes, type: .info, rowId, bt)
            return note
        } catch {
            os_log("Add note error: %{public}@", log: .notes, type: .error, error.localizedDescription)
            return nil
        }
    }

    func updateNote(_ note: Note, newText: String) {
        guard let db = db else { return }
        let row = notes.filter(id == note.id)
        do {
            try db.run(row.update(
                text <- newText,
                updatedAt <- Date()
            ))
            loadNotes()
            os_log("Updated note %{public}d", log: .notes, type: .info, note.id)
        } catch {
            os_log("Update note error: %{public}@", log: .notes, type: .error, error.localizedDescription)
        }
    }

    func deleteNote(_ note: Note) {
        guard let db = db else { return }
        let row = notes.filter(id == note.id)
        do {
            try db.run(row.delete())
            loadNotes()
            os_log("Deleted note %{public}d", log: .notes, type: .info, note.id)
        } catch {
            os_log("Delete note error: %{public}@", log: .notes, type: .error, error.localizedDescription)
        }
    }

    func notesForBook(_ book: Book) -> [Note] {
        allNotes.filter { $0.bookId == book.id }
    }
}

// MARK: - OSLog extension
private extension OSLog {
    static let notes = OSLog(subsystem: "com.plume.app", category: "Notes")
}
