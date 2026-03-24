import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bookStore: BookStore
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            Group {
                if bookStore.allBooks.isEmpty {
                    EmptyStateView {
                        // The empty state button will be handled by HomeView's sheet
                    }
                } else {
                    HomeView()
                }
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .onAppear {
                if !subscriptionManager.hasSeenOnboarding {
                    showOnboarding = true
                }
            }
        }
        .environmentObject(subscriptionManager)
    }
}

#Preview {
    ContentView()
        .environmentObject(BookStore())
}
