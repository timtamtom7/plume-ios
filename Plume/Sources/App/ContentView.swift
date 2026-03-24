import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bookStore: BookStore
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var quoteStore = QuoteStore()
    @State private var selectedTab = 0
    @State private var showOnboarding = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                ChallengeView()
            }
            .tabItem {
                Label("Challenges", systemImage: "target")
            }
            .tag(1)

            NavigationStack {
                RecommendationsView()
            }
            .tabItem {
                Label("Discover", systemImage: "sparkles")
            }
            .tag(2)

            NavigationStack {
                CommunityFeedView()
            }
            .tabItem {
                Label("Community", systemImage: "person.2.fill")
            }
            .tag(3)

            NavigationStack {
                ExportView()
            }
            .tabItem {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .tag(4)
        }
        .tint(.plumeAccent)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
        .onAppear {
            if !subscriptionManager.hasSeenOnboarding {
                showOnboarding = true
            }
        }
        .environmentObject(quoteStore)
    }
}

#Preview {
    ContentView()
        .environmentObject(BookStore())
        .environmentObject(QuoteStore())
}
