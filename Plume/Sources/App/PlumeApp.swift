import SwiftUI

@main
struct PlumeApp: App {
    @StateObject private var bookStore = BookStore()
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookStore)
                .environmentObject(subscriptionManager)
        }
    }
}
