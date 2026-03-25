import Foundation

/// R9: Community and social features service
@MainActor
final class PlumeCommunityService: ObservableObject {
    static let shared = PlumeCommunityService()

    @Published private(set) var publicReading: [PublicReadingUpdate] = []
    @Published private(set) var isLoading = false

    struct PublicReadingUpdate: Identifiable, Codable {
        let id: UUID
        let anonymousId: String
        let bookTitle: String
        let author: String
        let pagesRead: Int
        let progress: Int
        let timestamp: Date
        let likes: Int
    }

    private init() {}

    func loadPublicFeed() async {
        isLoading = true

        try? await Task.sleep(nanoseconds: 500_000_000)

        publicReading = [
            PublicReadingUpdate(id: UUID(), anonymousId: "reader_x7k2", bookTitle: "The Midnight Library", author: "Matt Haig", pagesRead: 45, progress: 78, timestamp: Date().addingTimeInterval(-3600), likes: 24),
            PublicReadingUpdate(id: UUID(), anonymousId: "bookworm_m3p9", bookTitle: "Atomic Habits", author: "James Clear", pagesRead: 30, progress: 65, timestamp: Date().addingTimeInterval(-7200), likes: 42),
            PublicReadingUpdate(id: UUID(), anonymousId: "literary_fan_b5n1", bookTitle: "Project Hail Mary", author: "Andy Weir", pagesRead: 60, progress: 45, timestamp: Date().addingTimeInterval(-10800), likes: 18),
            PublicReadingUpdate(id: UUID(), anonymousId: "page_turner_k8r4", bookTitle: "Lessons in Chemistry", author: "Bonnie Garmus", pagesRead: 25, progress: 55, timestamp: Date().addingTimeInterval(-14400), likes: 31),
            PublicReadingUpdate(id: UUID(), anonymousId: "story_seeker_c2t7", bookTitle: "Tomorrow, and Tomorrow, and Tomorrow", author: "Gabrielle Zevin", pagesRead: 50, progress: 80, timestamp: Date().addingTimeInterval(-18000), likes: 56)
        ]

        isLoading = false
    }
}
