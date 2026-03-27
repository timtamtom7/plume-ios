import SwiftUI

struct RecommendationsView: View {
    @StateObject private var recommendationService = RecommendationService()
    @State private var selectedBook: BookRecommendation?
    @State private var showingRecommendationsDetail = false

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection

                    // Curated Lists
                    curatedListsSection

                    // Personalized Recommendations
                    personalizedSection

                    // Similar Books
                    similarBooksSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Find Your Next Great Read")
                .font(.custom("Georgia-Bold", size: 20))
                .foregroundColor(.plumeTextPrimary)

            Text("Personalized recommendations based on your reading history")
                .font(.system(size: 14))
                .foregroundColor(.plumeTextSecondary)
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var curatedListsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Curated Lists")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            ForEach(recommendationService.curatedLists) { list in
                CuratedListCard(list: list) { book in
                    selectedBook = book
                    showingRecommendationsDetail = true
                }
            }
        }
    }

    @ViewBuilder
    private var personalizedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recommended For You")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(.plumeAccent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recommendationService.personalizedRecommendations) { book in
                        RecommendationBookCard(book: book)
                            .onTapGesture {
                                selectedBook = book
                                showingRecommendationsDetail = true
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private var similarBooksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Because You Read")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(spacing: 16) {
                ForEach(recommendationService.allRecommendations.prefix(3)) { book in
                    SimilarBookRow(book: book) {
                        selectedBook = book
                        showingRecommendationsDetail = true
                    }
                }
            }
            .padding(16)
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .sheet(isPresented: $showingRecommendationsDetail) {
            if let book = selectedBook {
                RecommendationDetailView(book: book)
            }
        }
    }
}

struct CuratedListCard: View {
    let list: CuratedList
    let onBookSelected: (BookRecommendation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.plumeAccent.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: list.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.plumeAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(list.title)
                        .font(.custom("Georgia-Bold", size: 16))
                        .foregroundColor(.plumeTextPrimary)

                    Text(list.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.plumeTextSecondary.opacity(0.5))
            }
            .padding(16)

            Divider()

            // Books
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(list.books) { book in
                        RecommendationBookCard(book: book, compact: true)
                            .onTapGesture {
                                onBookSelected(book)
                            }
                    }
                }
                .padding(16)
            }
        }
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct RecommendationBookCard: View {
    let book: BookRecommendation
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [book.coverColor, book.coverColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 4) {
                    Text(book.title)
                        .font(.custom("Georgia-Bold", size: compact ? 11 : 14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(compact ? 2 : 3)
                        .padding(.horizontal, 8)

                    Text(book.author)
                        .font(.system(size: compact ? 9 : 11))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .frame(width: compact ? 80 : 110, height: compact ? 120 : 160)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

            // Info
            if !compact {
                VStack(alignment: .leading, spacing: 2) {
                    Text(book.genre)
                        .font(Theme.fontCaption)
                        .foregroundColor(.plumeAccent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.plumeAccent.opacity(0.1))
                        .cornerRadius(Theme.cornerRadiusBadge)

                    Text("\(book.pageCount) pages")
                        .font(Theme.fontCaption)
                        .foregroundColor(.plumeTextSecondary)
                }
            }
        }
        .frame(width: compact ? 90 : 120)
    }
}

struct SimilarBookRow: View {
    let book: BookRecommendation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Cover
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [book.coverColor, book.coverColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 2) {
                        Text(book.title)
                            .font(.custom("Georgia-Bold", size: 11))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 6)

                        Text(book.author)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                .frame(width: 45, height: 68)

                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.custom("Georgia-Bold", size: 14))
                        .foregroundColor(.plumeTextPrimary)
                        .lineLimit(1)

                    Text(book.author)
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)
                        .lineLimit(1)

                    Text(book.reason.formatted(with: ["book": "this book", "genre": book.genre]))
                        .font(.system(size: 11))
                        .foregroundColor(.plumeAccent)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.plumeTextSecondary.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }
}

struct RecommendationDetailView: View {
    let book: BookRecommendation
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddToList = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Cover
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [book.coverColor, book.coverColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(spacing: 8) {
                                Spacer()

                                Text(book.title)
                                    .font(.custom("Georgia-Bold", size: 22))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)

                                Text(book.author)
                                    .font(.custom("Georgia", size: 16))
                                    .foregroundColor(.white.opacity(0.9))

                                Spacer()
                            }
                        }
                        .frame(height: 280)
                        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)

                        // Meta info
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(book.pageCount)")
                                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.plumeTextPrimary)
                                Text("pages")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                            }

                            Divider()
                                .frame(height: 40)

                            VStack(spacing: 4) {
                                Text(book.genre)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.plumeAccent)
                                Text("genre")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                            }

                            Divider()
                                .frame(height: 40)

                            VStack(spacing: 4) {
                                Image(systemName: book.reason == .curated ? "star.fill" : "sparkles")
                                    .font(.system(size: 20))
                                    .foregroundColor(.plumeAccentSecondary)
                                Text(book.reason.rawValue.replacingOccurrences(of: "{genre}", with: "").replacingOccurrences(of: "{book}", with: ""))
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, 40)

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About this book")
                                .font(.custom("Georgia-Bold", size: 14))
                                .foregroundColor(.plumeTextSecondary)

                            Text(book.description)
                                .font(.system(size: 15))
                                .foregroundColor(.plumeTextPrimary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 100)
                    }
                }

                // Bottom button
                VStack {
                    Spacer()

                    Button {
                        showingAddToList = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add to Reading List")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.plumeAccent)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.plumeTextSecondary)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecommendationsView()
    }
}
