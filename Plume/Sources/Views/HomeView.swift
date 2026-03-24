import SwiftUI

struct HomeView: View {
    @EnvironmentObject var bookStore: BookStore
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var challengeStore: ChallengeStore
    @State private var showingAddBook = false
    @State private var showingUpdateProgress = false
    @State private var showingSettings = false
    @State private var showingPricing = false
    @State private var showingBookLimitAlert = false
    @State private var selectedBook: Book?

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            if bookStore.allBooks.isEmpty {
                EmptyStateView {
                    handleAddBookTap()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Reading Challenge Progress
                        if let challenge = challengeStore.currentChallenge {
                            challengeProgressSection(challenge)
                        }

                        // Currently Reading
                        if let current = bookStore.currentlyReading.first {
                            currentlyReadingSection(current)
                        }

                        // Library
                        librarySection

                        // Start a Book button
                        startBookButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Plume")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingPricing = true
                } label: {
                    Image(systemName: "crown")
                        .foregroundColor(.plumeAccentSecondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.plumeAccent)
                }
            }
        }
        .sheet(isPresented: $showingAddBook) {
            AddBookSheet()
        }
        .sheet(isPresented: $showingUpdateProgress) {
            if let book = bookStore.currentlyReading.first {
                UpdateProgressSheet(book: book)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingPricing) {
            PricingView()
        }
        .alert("Book Limit Reached", isPresented: $showingBookLimitAlert) {
            Button("Upgrade") {
                showingPricing = true
            }
            Button("Later", role: .cancel) {}
        } message: {
            Text("You've reached the \(subscriptionManager.currentTier.maxBooks)-book limit on your \(subscriptionManager.currentTier.displayName) plan. Upgrade to Reader for unlimited books.")
        }
    }

    private func handleAddBookTap() {
        if subscriptionManager.canAddBook(currentBookCount: bookStore.allBooks.count) {
            showingAddBook = true
        } else {
            showingBookLimitAlert = true
        }
    }

    @ViewBuilder
    private func currentlyReadingSection(_ book: Book) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Currently Reading")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 16) {
                    // Cover
                    CoverImageView(book: book, size: CGSize(width: 90, height: 135))
                        .onTapGesture {
                            selectedBook = book
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.title)
                            .font(.custom("Georgia-Bold", size: 17))
                            .foregroundColor(.plumeTextPrimary)
                            .lineLimit(2)

                        Text(book.author)
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(.plumeTextSecondary)
                            .lineLimit(1)

                        Spacer()

                        // Progress
                        HStack {
                            Text("Page \(book.currentPage) of \(book.totalPages)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.plumeTextSecondary)
                            Spacer()
                            Text("\(Int(book.progressPercent * 100))%")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.plumeAccent)
                        }

                        ProgressBar(progress: book.progressPercent)
                            .frame(height: 6)

                        Spacer()

                        // Stats
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(Int(book.pagesPerDay))")
                                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.plumeCurrentlyReading)
                                Text("pages/day")
                                    .font(.system(size: 10))
                                    .foregroundColor(.plumeTextSecondary)
                            }

                            Divider()
                                .frame(height: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(book.estimatedFinishDate?.formatted(date: .abbreviated, time: .omitted) ?? "—")
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.plumeAccent)
                                Text("finishes")
                                    .font(.system(size: 10))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                    }
                }
                .padding(16)

                Divider()

                Button {
                    showingUpdateProgress = true
                } label: {
                    HStack {
                        Image(systemName: "pencil.circle")
                        Text("Update Progress")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.plumeAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .sheet(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
    }

    @ViewBuilder
    private func challengeProgressSection(_ challenge: ReadingChallenge) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reading Challenge \(challenge.year)")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                if !challenge.isOnTrack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }

            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.plumeTextSecondary.opacity(0.1), lineWidth: 8)

                        Circle()
                            .trim(from: 0, to: CGFloat(challenge.progressPercent))
                            .stroke(
                                AngularGradient(
                                    colors: [.plumeAccent, .plumeAccentSecondary],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 0) {
                            Text("\(challenge.booksCompleted)")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.plumeTextPrimary)
                            Text("/\(challenge.annualGoal)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.plumeTextSecondary)
                        }
                    }
                    .frame(width: 70, height: 70)

                    VStack(alignment: .leading, spacing: 4) {
                        if let message = challenge.paceMessage {
                            Text(message)
                                .font(.system(size: 13))
                                .foregroundColor(challenge.isOnTrack ? .plumeAccent : .orange)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Text("\(challenge.booksRemaining) books to reach your goal")
                            .font(.system(size: 12))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()
                }
                .padding(16)
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Library")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                Text("\(bookStore.allBooks.count) books")
                    .font(.system(size: 12))
                    .foregroundColor(.plumeTextSecondary)
            }

            if bookStore.allBooks.count > 1 {
                NavigationLink {
                    LibraryView()
                } label: {
                    HStack(spacing: 12) {
                        ForEach(bookStore.allBooks.prefix(4)) { book in
                            CoverImageView(book: book, size: CGSize(width: 50, height: 75))
                        }
                        if bookStore.allBooks.count > 4 {
                            ZStack {
                                Rectangle()
                                    .fill(Color.plumeTextSecondary.opacity(0.2))
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(4)
                                Text("+\(bookStore.allBooks.count - 4)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.plumeTextSecondary)
                    }
                    .padding(16)
                    .background(Color.plumeSurface)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                }
            }
        }
    }

    @ViewBuilder
    private var startBookButton: some View {
        Button {
            handleAddBookTap()
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Start a Book")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.plumeAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.plumeAccent.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.plumeTextSecondary.opacity(0.15))
                    .cornerRadius(3)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.plumeCurrentlyReading, Color.plumeCurrentlyReading.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(progress))
                    .cornerRadius(3)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(BookStore())
            .environmentObject(SubscriptionManager.shared)
            .environmentObject(ChallengeStore())
    }
}
