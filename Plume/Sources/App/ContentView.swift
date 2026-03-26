import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bookStore: BookStore
    @EnvironmentObject var quoteStore: QuoteStore
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var streakStore: StreakStore
    @StateObject private var subscriptionManager = SubscriptionManager.shared
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
                QuotesListView()
            }
            .tabItem {
                Label("Quotes", systemImage: "quote.opening")
            }
            .tag(2)

            NavigationStack {
                RecommendationsView()
            }
            .tabItem {
                Label("Discover", systemImage: "sparkles")
            }
            .tag(3)

            NavigationStack {
                CommunityFeedView()
            }
            .tabItem {
                Label("Community", systemImage: "person.2.fill")
            }
            .tag(4)

            NavigationStack {
                ExportView()
            }
            .tabItem {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .tag(5)
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
    }
}

#Preview {
    ContentView()
        .environmentObject(BookStore())
        .environmentObject(QuoteStore())
        .environmentObject(NoteStore())
        .environmentObject(StreakStore())
}

