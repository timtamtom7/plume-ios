import Foundation
import SwiftUI

struct Book: Identifiable, Equatable {
    let id: Int64
    var title: String
    var author: String
    var totalPages: Int
    var currentPage: Int
    var coverImagePath: String?
    var placeholderColorHex: String
    var startDate: Date
    var finishDate: Date?
    var isFinished: Bool

    var progressPercent: Double {
        guard totalPages > 0 else { return 0 }
        return min(Double(currentPage) / Double(totalPages), 1.0)
    }

    var remainingPages: Int {
        max(totalPages - currentPage, 0)
    }

    var pagesRead: Int {
        currentPage
    }

    var daysReading: Int {
        let calendar = Calendar.current
        let end = finishDate ?? Date()
        return max(calendar.dateComponents([.day], from: startDate, to: end).day ?? 0, 1)
    }

    var pagesPerDay: Double {
        let days = daysReading
        guard days > 0 else { return 0 }
        return Double(pagesRead) / Double(days)
    }

    var daysToFinish: Int {
        let pace = pagesPerDay
        guard pace > 0 else { return 0 }
        return max(Int(ceil(Double(remainingPages) / pace)), 0)
    }

    var estimatedFinishDate: Date? {
        let pace = pagesPerDay
        guard pace > 0, remainingPages > 0 else { return nil }
        let days = daysToFinish
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }

    var placeholderColor: Color {
        Color(hex: placeholderColorHex) ?? .brown
    }
}

extension Book {
    static let sample = Book(
        id: 1,
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        totalPages: 180,
        currentPage: 142,
        coverImagePath: nil,
        placeholderColorHex: "#8b4513",
        startDate: Date().addingTimeInterval(-86400 * 5),
        finishDate: nil,
        isFinished: false
    )
}
