import Foundation

// MARK: - Publication

struct Publication: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let url: URL?
    let isPublic: Bool
    let createdAt: Date
}

// MARK: - Contest

struct Contest: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let deadline: Date
    let wordLimitMin: Int?
    let wordLimitMax: Int?
    let entryFee: Double?
    let prizes: [String]
}

// MARK: - Publishing Service

final class PublishingService {
    static let shared = PublishingService()

    private init() {}

    // MARK: - Publishing

    func publishEntry(_ entry: WritingEntry, to publication: Publication) async throws {
        // Simulate async publishing operation
        try await Task.sleep(nanoseconds: 500_000_000)

        guard !entry.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PublishingError.emptyContent
        }

        // In production: POST to backend API, upload content, handle errors
        print("Published '\(entry.title)' to '\(publication.title)'")
    }

    func getPublications() -> [Publication] {
        // In production: fetch from API
        return [
            Publication(
                id: UUID(),
                title: "My Medium Blog",
                description: "Personal essays and reflections",
                url: URL(string: "https://medium.com/@writer"),
                isPublic: true,
                createdAt: Date()
            ),
            Publication(
                id: UUID(),
                title: "Substack Newsletter",
                description: "Weekly dispatches on writing and creativity",
                url: URL(string: "https://substack.com/@writer"),
                isPublic: true,
                createdAt: Date()
            ),
            Publication(
                id: UUID(),
                title: "Personal Portfolio",
                description: "Selected works and portfolio pieces",
                url: nil,
                isPublic: true,
                createdAt: Date()
            ),
        ]
    }

    // MARK: - Contests

    func submitToContest(_ entry: WritingEntry, contestId: UUID) {
        // In production: POST to contest submission API
        print("Submitted '\(entry.title)' to contest \(contestId)")
    }

    func getUpcomingContests() -> [Contest] {
        return [
            Contest(
                id: UUID(),
                name: "Spring Short Story Prize",
                description: "Submit your best short fiction, 2,000-5,000 words",
                deadline: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
                wordLimitMin: 2000,
                wordLimitMax: 5000,
                entryFee: 15.0,
                prizes: ["$1,000", "$500", "$250"]
            ),
            Contest(
                id: UUID(),
                name: "Flash Fiction Challenge",
                description: "100-word stories on the theme of 'Home'",
                deadline: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
                wordLimitMin: 100,
                wordLimitMax: 100,
                entryFee: 0,
                prizes: ["Publication", "Publication", "Publication"]
            ),
        ]
    }

    // MARK: - Export

    func exportEntry(_ entry: WritingEntry, format: ExportFormat) async throws -> URL {
        switch format {
        case .pdf:
            return try await exportToPDF(entry)
        case .markdown:
            return try await exportToMarkdown(entry)
        case .plainText:
            return try await exportToPlainText(entry)
        }
    }

    // MARK: - Private Helpers

    private func exportToPDF(_ entry: WritingEntry) async throws -> URL {
        // In production: use PDFKit or a rendering library
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(entry.title).pdf")
        try entry.content.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }

    private func exportToMarkdown(_ entry: WritingEntry) async throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(entry.title).md")
        try entry.content.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }

    private func exportToPlainText(_ entry: WritingEntry) async throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(entry.title).txt")
        try entry.content.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }
}

// MARK: - Export Format

enum ExportFormat {
    case pdf
    case markdown
    case plainText
}

// MARK: - Publishing Error

enum PublishingError: LocalizedError {
    case emptyContent
    case networkError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Cannot publish an empty entry."
        case .networkError:
            return "Network error. Please try again."
        case .unauthorized:
            return "You are not authorized to publish to this destination."
        }
    }
}
