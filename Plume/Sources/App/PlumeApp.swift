import SwiftUI

@main
struct PlumeApp: App {
    @StateObject private var bookStore = BookStore()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var challengeStore = ChallengeStore()
    @StateObject private var quoteStore = QuoteStore()
    @StateObject private var noteStore = NoteStore()
    @StateObject private var streakStore = StreakStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookStore)
                .environmentObject(subscriptionManager)
                .environmentObject(challengeStore)
                .environmentObject(quoteStore)
                .environmentObject(noteStore)
                .environmentObject(streakStore)
        }
    }
}
