import Foundation
import SwiftUI

// MARK: - Book Recommendation Model
struct BookRecommendation: Identifiable, Equatable {
    let id: UUID
    let title: String
    let author: String
    let genre: String
    let reason: RecommendationReason
    let coverColorHex: String
    let pageCount: Int
    let description: String

    enum RecommendationReason: String {
        case genreMatch = "Because you read {genre}"
        case similarReaders = "Readers who liked {book} also read this"
        case curated = "Editor's pick"
        case popular = "Popular this week"
        case trending = "Trending now"

        func formatted(with values: [String: String] = [:]) -> String {
            var result = rawValue
            for (key, value) in values {
                result = result.replacingOccurrences(of: "{\(key)}", with: value)
            }
            return result
        }
    }

    var coverColor: Color {
        Color(hex: coverColorHex) ?? .brown
    }
}

// MARK: - Recommendation Service
final class RecommendationService: ObservableObject {
    @Published var personalizedRecommendations: [BookRecommendation] = []
    @Published var similarBooksRecommendations: [String: [BookRecommendation]] = [:]
    @Published var curatedLists: [CuratedList] = []

    private let genreColors: [String: String] = [
        "Fiction": "#4a3728",
        "Classic Fiction": "#8b4513",
        "Literary Fiction": "#2d5a3d",
        "Science Fiction": "#1e4d6b",
        "Fantasy": "#3d2c4a",
        "Non-Fiction": "#1e4d6b",
        "Self-Improvement": "#2c4a3e",
        "Biography": "#5c3d2e",
        "History": "#4a3728",
        "Philosophy": "#4a2c3d",
        "Poetry": "#4a2c3d",
        "Memoir": "#5c3d2e",
        "Science": "#1e4d6b",
        "Business": "#2c4a3e",
        "Technology": "#1e4d6b",
    ]

    // Sample recommendations database (would be from an API in production)
    let allRecommendations: [BookRecommendation] = [
        BookRecommendation(
            id: UUID(),
            title: "One Hundred Years of Solitude",
            author: "Gabriel García Márquez",
            genre: "Literary Fiction",
            reason: .curated,
            coverColorHex: "#4a3728",
            pageCount: 417,
            description: "A multi-generational story of the Buendía family."
        ),
        BookRecommendation(
            id: UUID(),
            title: "To Kill a Mockingbird",
            author: "Harper Lee",
            genre: "Classic Fiction",
            reason: .popular,
            coverColorHex: "#8b4513",
            pageCount: 324,
            description: "A gripping tale of racial injustice in the American South."
        ),
        BookRecommendation(
            id: UUID(),
            title: "Sapiens",
            author: "Yuval Noah Harari",
            genre: "Non-Fiction",
            reason: .genreMatch,
            coverColorHex: "#1e4d6b",
            pageCount: 443,
            description: "A brief history of humankind, from the Stone Age to the present."
        ),
        BookRecommendation(
            id: UUID(),
            title: "The Midnight Library",
            author: "Matt Haig",
            genre: "Fiction",
            reason: .trending,
            coverColorHex: "#2d5a3d",
            pageCount: 304,
            description: "Between life and death there is a library, and within that library, the shelves go on forever."
        ),
        BookRecommendation(
            id: UUID(),
            title: "Dune",
            author: "Frank Herbert",
            genre: "Science Fiction",
            reason: .similarReaders,
            coverColorHex: "#1e4d6b",
            pageCount: 688,
            description: "Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides."
        ),
        BookRecommendation(
            id: UUID(),
            title: "Thinking, Fast and Slow",
            author: "Daniel Kahneman",
            genre: "Non-Fiction",
            reason: .genreMatch,
            coverColorHex: "#2c4a3e",
            pageCount: 499,
            description: "A groundbreaking tour of the mind that explains the two systems that drive the way we think."
        ),
        BookRecommendation(
            id: UUID(),
            title: "The Alchemist",
            author: "Paulo Coelho",
            genre: "Fiction",
            reason: .curated,
            coverColorHex: "#8b4513",
            pageCount: 208,
            description: "A magical story about Santiago, an Andalusian shepherd boy who yearns to travel in search of treasure."
        ),
        BookRecommendation(
            id: UUID(),
            title: "Steve Jobs",
            author: "Walter Isaacson",
            genre: "Biography",
            reason: .genreMatch,
            coverColorHex: "#5c3d2e",
            pageCount: 656,
            description: "The exclusive biography based on three years of unrestricted access to Steve Jobs."
        ),
        BookRecommendation(
            id: UUID(),
            title: "The Name of the Wind",
            author: "Patrick Rothfuss",
            genre: "Fantasy",
            reason: .similarReaders,
            coverColorHex: "#3d2c4a",
            pageCount: 662,
            description: "The tale of Kvothe, from his childhood in a troupe of traveling players to his years as a near-legendary magician."
        ),
        BookRecommendation(
            id: UUID(),
            title: "Educated",
            author: "Tara Westover",
            genre: "Memoir",
            reason: .curated,
            coverColorHex: "#5c3d2e",
            pageCount: 352,
            description: "A memoir about a young girl who, kept out of school, leaves her survivalist family and goes on to earn a PhD from Cambridge."
        ),
        BookRecommendation(
            id: UUID(),
            title: "1984",
            author: "George Orwell",
            genre: "Classic Fiction",
            reason: .popular,
            coverColorHex: "#4a3728",
            pageCount: 328,
            description: "A dystopian social science fiction novel and cautionary tale about the dangers of totalitarianism."
        ),
        BookRecommendation(
            id: UUID(),
            title: "The Pragmatic Programmer",
            author: "David Thomas & Andrew Hunt",
            genre: "Technology",
            reason: .trending,
            coverColorHex: "#1e4d6b",
            pageCount: 352,
            description: "Your journey to mastery, examining the core processes of software development."
        ),
    ]

    init() {
        generateRecommendations()
        generateCuratedLists()
    }

    func generateRecommendations() {
        // In production, this would analyze the user's reading history
        // For now, we return a shuffled subset
        let shuffled = allRecommendations.shuffled()
        personalizedRecommendations = Array(shuffled.prefix(6))
    }

    func getSimilarBooks(for bookTitle: String) -> [BookRecommendation] {
        // In production, this would query a recommendation API
        // For now, return random recommendations
        let similar = allRecommendations
            .filter { $0.title != bookTitle }
            .shuffled()
            .prefix(3)
        let result = Array(similar)
        similarBooksRecommendations[bookTitle] = result
        return result
    }

    func generateCuratedLists() {
        curatedLists = [
            CuratedList(
                id: UUID(),
                title: "Books to Challenge Your Thinking",
                subtitle: "Expand your worldview",
                icon: "brain.head.profile",
                books: Array(allRecommendations.filter { $0.reason == .curated }.prefix(4))
            ),
            CuratedList(
                id: UUID(),
                title: "Page-Turners",
                subtitle: "Hard to put down",
                icon: "hand.raised.fill",
                books: Array(allRecommendations.filter { $0.reason == .trending }.prefix(4))
            ),
            CuratedList(
                id: UUID(),
                title: "Modern Classics",
                subtitle: "Timeless reads",
                icon: "star.fill",
                books: Array(allRecommendations.filter { $0.reason == .popular }.prefix(4))
            ),
        ]
    }

    func recommendationsForGenres(_ genres: [String]) -> [BookRecommendation] {
        allRecommendations
            .filter { genres.contains($0.genre) }
            .shuffled()
            .prefix(4)
            .map { $0 }
    }
}

// MARK: - Curated List
struct CuratedList: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let icon: String
    let books: [BookRecommendation]
}
