import SwiftUI

@main
struct PlumeApp: App {
    @StateObject private var bookStore = BookStore()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var challengeStore = ChallengeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookStore)
                .environmentObject(subscriptionManager)
                .environmentObject(challengeStore)
        }
    }
}
