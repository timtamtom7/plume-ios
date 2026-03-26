import Foundation
import Combine

final class PlumeR12R20Service: ObservableObject, @unchecked Sendable {
    static let shared = PlumeR12R20Service()
    
    @Published var reviews: [PublicReview] = []
    @Published var sharedLists: [SharedReadingList] = []
    @Published var readingChallenges: [SocialReadingChallenge] = []
    @Published var bookClubs: [BookClub] = []
    @Published var currentTier: PlumeSubscriptionTier = .free
    @Published var crossPlatformDevices: [CrossPlatformDevice] = []
    @Published var awardSubmissions: [AwardSubmission] = []
    @Published var apiCredentials: PlumeAPI?
    
    private let userDefaults = UserDefaults.standard
    
    private init() { loadFromDisk() }
    
    func createReview(bookID: UUID, authorID: String, authorName: String, rating: Int, content: String) -> PublicReview {
        let review = PublicReview(bookID: bookID, authorID: authorID, authorName: authorName, rating: rating, content: content)
        reviews.append(review)
        saveToDisk()
        return review
    }
    
    func createSharedList(name: String, ownerID: String, isPublic: Bool = false) -> SharedReadingList {
        let list = SharedReadingList(name: name, ownerID: ownerID, isPublic: isPublic)
        sharedLists.append(list)
        saveToDisk()
        return list
    }
    
    func createReadingChallenge(name: String, targetBooks: Int, startDate: Date, endDate: Date) -> SocialReadingChallenge {
        let challenge = SocialReadingChallenge(name: name, targetBooks: targetBooks, startDate: startDate, endDate: endDate)
        readingChallenges.append(challenge)
        saveToDisk()
        return challenge
    }
    
    func createBookClub(name: String, description: String) -> BookClub {
        let club = BookClub(name: name, description: description)
        bookClubs.append(club)
        saveToDisk()
        return club
    }
    
    func subscribe(to tier: PlumeSubscriptionTier) async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run { currentTier = tier; saveToDisk() }
        return true
    }
    
    private func saveToDisk() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(reviews) { userDefaults.set(data, forKey: "plume_reviews") }
        if let data = try? encoder.encode(sharedLists) { userDefaults.set(data, forKey: "plume_lists") }
        if let data = try? encoder.encode(readingChallenges) { userDefaults.set(data, forKey: "plume_challenges") }
        if let data = try? encoder.encode(bookClubs) { userDefaults.set(data, forKey: "plume_clubs") }
        if let data = try? encoder.encode(crossPlatformDevices) { userDefaults.set(data, forKey: "plume_devices") }
        if let data = try? encoder.encode(awardSubmissions) { userDefaults.set(data, forKey: "plume_awards") }
    }
    
    private func loadFromDisk() {
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: "plume_reviews"),
           let decoded = try? decoder.decode([PublicReview].self, from: data) { reviews = decoded }
        if let data = userDefaults.data(forKey: "plume_lists"),
           let decoded = try? decoder.decode([SharedReadingList].self, from: data) { sharedLists = decoded }
        if let data = userDefaults.data(forKey: "plume_challenges"),
           let decoded = try? decoder.decode([SocialReadingChallenge].self, from: data) { readingChallenges = decoded }
        if let data = userDefaults.data(forKey: "plume_clubs"),
           let decoded = try? decoder.decode([BookClub].self, from: data) { bookClubs = decoded }
        if let data = userDefaults.data(forKey: "plume_devices"),
           let decoded = try? decoder.decode([CrossPlatformDevice].self, from: data) { crossPlatformDevices = decoded }
        if let data = userDefaults.data(forKey: "plume_awards"),
           let decoded = try? decoder.decode([AwardSubmission].self, from: data) { awardSubmissions = decoded }
    }
}
