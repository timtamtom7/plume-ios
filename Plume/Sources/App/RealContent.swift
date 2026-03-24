import Foundation

// MARK: - Real Book Examples for Previews and Sample Data

struct SampleBookData {
    static let books: [SampleBook] = [
        SampleBook(
            title: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            totalPages: 180,
            currentPage: 142,
            genre: "Classic Fiction",
            daysAgo: 5
        ),
        SampleBook(
            title: "Sapiens: A Brief History of Humankind",
            author: "Yuval Noah Harari",
            totalPages: 443,
            currentPage: 287,
            genre: "Non-Fiction",
            daysAgo: 12
        ),
        SampleBook(
            title: "The Alchemist",
            author: "Paulo Coelho",
            totalPages: 208,
            currentPage: 208,
            genre: "Fiction",
            daysAgo: 30
        ),
        SampleBook(
            title: "Atomic Habits",
            author: "James Clear",
            totalPages: 320,
            currentPage: 98,
            genre: "Self-Improvement",
            daysAgo: 3
        ),
        SampleBook(
            title: "Middlemarch",
            author: "George Eliot",
            totalPages: 880,
            currentPage: 340,
            genre: "Classic Fiction",
            daysAgo: 21
        ),
        SampleBook(
            title: "The Remains of the Day",
            author: "Kazuo Ishiguro",
            totalPages: 258,
            currentPage: 200,
            genre: "Literary Fiction",
            daysAgo: 8
        ),
    ]
}

struct SampleBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let totalPages: Int
    let currentPage: Int
    let genre: String
    let daysAgo: Int

    var progress: Double {
        Double(currentPage) / Double(totalPages)
    }

    var pagesPerDay: Double {
        let days = max(daysAgo, 1)
        return Double(currentPage) / Double(days)
    }

    var daysToFinish: Int {
        let remaining = totalPages - currentPage
        guard remaining > 0, pagesPerDay > 0 else { return 0 }
        return Int(ceil(Double(remaining) / pagesPerDay))
    }

    var estimatedFinishDate: Date {
        Calendar.current.date(byAdding: .day, value: daysToFinish, to: Date()) ?? Date()
    }
}

// MARK: - Compelling Reading Copy

struct ReadingQuotes {
    static let quotes: [ReadingQuote] = [
        ReadingQuote(
            text: "So we beat on, boats against the current, borne back ceaselessly into the past.",
            book: "The Great Gatsby",
            author: "F. Scott Fitzgerald"
        ),
        ReadingQuote(
            text: "And, when you want something, all the universe conspires in helping you to achieve it.",
            book: "The Alchemist",
            author: "Paulo Coelho"
        ),
        ReadingQuote(
            text: "You are what you do. Not what you say you'll do.",
            book: "Atomic Habits",
            author: "James Clear"
        ),
        ReadingQuote(
            text: "It is not in the stars to hold our destiny but in ourselves.",
            book: "Middlemarch",
            author: "George Eliot"
        ),
        ReadingQuote(
            text: "The only way to do great work is to love what you do.",
            book: "Steve Jobs",
            author: "Walter Isaacson"
        ),
    ]
}

struct ReadingQuote: Identifiable {
    let id = UUID()
    let text: String
    let book: String
    let author: String
}

// MARK: - Reading Pace Examples

struct ReadingPaceExample: Identifiable {
    let id = UUID()
    let readerName: String
    let bookTitle: String
    let pagesPerDay: Double
    let totalPages: Int
    let daysToFinish: Int

    var description: String {
        "Reading \(Int(pagesPerDay)) pages/day → finishes in \(daysToFinish) days"
    }
}

struct PaceExamples {
    static let examples: [ReadingPaceExample] = [
        ReadingPaceExample(
            readerName: "Sarah",
            bookTitle: "The Great Gatsby",
            pagesPerDay: 28,
            totalPages: 180,
            daysToFinish: 2
        ),
        ReadingPaceExample(
            readerName: "Marcus",
            bookTitle: "Sapiens",
            pagesPerDay: 24,
            totalPages: 443,
            daysToFinish: 7
        ),
        ReadingPaceExample(
            readerName: "Emma",
            bookTitle: "Middlemarch",
            pagesPerDay: 16,
            totalPages: 880,
            daysToFinish: 34
        ),
        ReadingPaceExample(
            readerName: "James",
            bookTitle: "Atomic Habits",
            pagesPerDay: 33,
            totalPages: 320,
            daysToFinish: 7
        ),
    ]
}
