import SwiftUI

@main
struct PlumeApp: App {
    @StateObject private var bookStore = BookStore()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var challengeStore = ChallengeStore()
    @StateObject private var quoteStore = QuoteStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookStore)
                .environmentObject(subscriptionManager)
                .environmentObject(challengeStore)
                .environmentObject(quoteStore)
        }
    }
}
