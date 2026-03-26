import Foundation

// MARK: - Plume R12-R20: Social Reading, Reviews, Platform

struct PublicReview: Identifiable, Codable, Equatable {
    let id: UUID
    var bookID: UUID
    var authorID: String
    var authorName: String
    var rating: Int
    var content: String
    var likes: Int
    var commentCount: Int
    var createdAt: Date
    var isFeatured: Bool
    
    init(id: UUID = UUID(), bookID: UUID, authorID: String, authorName: String, rating: Int, content: String, likes: Int = 0, commentCount: Int = 0, createdAt: Date = Date(), isFeatured: Bool = false) {
        self.id = id
        self.bookID = bookID
        self.authorID = authorID
        self.authorName = authorName
        self.rating = rating
        self.content = content
        self.likes = likes
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.isFeatured = isFeatured
    }
}

struct SharedReadingList: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var ownerID: String
    var collaboratorIDs: [String]
    var bookIDs: [UUID]
    var isPublic: Bool
    var description: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, ownerID: String, collaboratorIDs: [String] = [], bookIDs: [UUID] = [], isPublic: Bool = false, description: String = "", createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.ownerID = ownerID
        self.collaboratorIDs = collaboratorIDs
        self.bookIDs = bookIDs
        self.isPublic = isPublic
        self.description = description
        self.createdAt = createdAt
    }
}

struct SocialReadingChallenge: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var targetBooks: Int
    var startDate: Date
    var endDate: Date
    var participantIDs: [String]
    var progress: [String: Int] // userID: books read
    var isPublic: Bool
    
    init(id: UUID = UUID(), name: String, targetBooks: Int, startDate: Date, endDate: Date, participantIDs: [String] = [], progress: [String: Int] = [:], isPublic: Bool = true) {
        self.id = id
        self.name = name
        self.targetBooks = targetBooks
        self.startDate = startDate
        self.endDate = endDate
        self.participantIDs = participantIDs
        self.progress = progress
        self.isPublic = isPublic
    }
}

struct BookClub: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var memberIDs: [String]
    var currentBookID: UUID?
    var meetingSchedule: String
    var isPublic: Bool
    
    init(id: UUID = UUID(), name: String, description: String = "", memberIDs: [String] = [], currentBookID: UUID? = nil, meetingSchedule: String = "", isPublic: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.memberIDs = memberIDs
        self.currentBookID = currentBookID
        self.meetingSchedule = meetingSchedule
        self.isPublic = isPublic
    }
}

struct PlumeSubscriptionTier: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var displayName: String
    var monthlyPrice: Decimal
    var annualPrice: Decimal
    var lifetimePrice: Decimal
    var features: [String]
    var isMostPopular: Bool
    
    static let free = PlumeSubscriptionTier(id: UUID(), name: "free", displayName: "Free", monthlyPrice: 0, annualPrice: 0, lifetimePrice: 0, features: ["5 books/month", "Basic tracking", "Simple lists"], isMostPopular: false)
    static let premium = PlumeSubscriptionTier(id: UUID(), name: "premium", displayName: "Premium", monthlyPrice: 7.99, annualPrice: 79.99, lifetimePrice: 149, features: ["Unlimited books", "Social reading", "Reviews", "Book clubs", "Priority support"], isMostPopular: true)
    static let family = PlumeSubscriptionTier(id: UUID(), name: "family", displayName: "Family", monthlyPrice: 11.99, annualPrice: 119.99, lifetimePrice: 0, features: ["Up to 6 members", "Shared reading lists", "Family book clubs", "Priority support"], isMostPopular: false)
}

struct SupportedLocale: Identifiable, Codable, Equatable {
    let id: UUID
    var code: String
    var displayName: String
    
    static let supported: [SupportedLocale] = [
        SupportedLocale(id: UUID(), code: "en", displayName: "English"),
        SupportedLocale(id: UUID(), code: "es", displayName: "Spanish"),
        SupportedLocale(id: UUID(), code: "fr", displayName: "French"),
        SupportedLocale(id: UUID(), code: "de", displayName: "German"),
    ]
}

struct CrossPlatformDevice: Identifiable, Codable, Equatable {
    let id: UUID
    var deviceName: String
    var platform: Platform
    
    enum Platform: String, Codable { case ios, android, web }
    
    init(id: UUID = UUID(), deviceName: String, platform: Platform) {
        self.id = id
        self.deviceName = deviceName
        self.platform = platform
    }
}

struct AwardSubmission: Identifiable, Codable, Equatable {
    let id: UUID
    var awardName: String
    var category: String
    var status: Status
    
    enum Status: String, Codable { case draft, submitted, inReview, won, rejected }
    
    init(id: UUID = UUID(), awardName: String, category: String, status: Status = .draft) {
        self.id = id
        self.awardName = awardName
        self.category = category
        self.status = status
    }
}

struct PlatformIntegration: Identifiable, Codable, Equatable {
    let id: UUID
    var platform: String
    var isEnabled: Bool
    
    init(id: UUID = UUID(), platform: String, isEnabled: Bool = false) {
        self.id = id
        self.platform = platform
        self.isEnabled = isEnabled
    }
}

struct PlumeAPI: Codable, Equatable {
    var clientID: String
    var tier: APITier
    
    enum APITier: String, Codable { case free, paid }
    
    init(clientID: String = UUID().uuidString, tier: APITier = .free) {
        self.clientID = clientID
        self.tier = tier
    }
}
