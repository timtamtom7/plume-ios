import SwiftUI

struct CommunityFeedView: View {
    @State private var selectedTab: FeedTab = .popular
    @State private var quotes: [CommunityQuote] = CommunityQuote.samples
    @State private var showingShareQuote = false

    enum FeedTab: String, CaseIterable {
        case popular = "Popular"
        case recent = "Recent"
        case following = "Following"
    }

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab picker
                Picker("", selection: $selectedTab) {
                    ForEach(FeedTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(quotes) { quote in
                            CommunityQuoteCard(quote: quote) {
                                shareQuote(quote)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Community")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingShareQuote = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.plumeAccent)
                }
            }
        }
        .sheet(isPresented: $showingShareQuote) {
            SharePublicQuoteView()
        }
    }

    private func shareQuote(_ quote: CommunityQuote) {
        let text = "\"\(quote.quote)\"\n— \(quote.author), \(quote.bookTitle)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct CommunityQuoteCard: View {
    let quote: CommunityQuote
    let onShare: () -> Void

    @State private var isLiked = false
    @State private var likeCount: Int

    init(quote: CommunityQuote, onShare: @escaping () -> Void) {
        self.quote = quote
        self.onShare = onShare
        self._likeCount = State(initialValue: quote.likes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quote text
            Text(quote.quote)
                .font(.custom("Georgia-Italic", size: 15))
                .foregroundColor(.plumeTextPrimary)
                .lineSpacing(4)

            // Book attribution
            HStack(spacing: 6) {
                Text("—")
                Text(quote.bookTitle)
                    .fontWeight(.medium)
                Text("by")
                Text(quote.author)
            }
            .font(.system(size: 13))
            .foregroundColor(.plumeTextSecondary)

            Divider()

            // Actions row
            HStack(spacing: 24) {
                // Like button
                Button {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .plumeTextSecondary)
                        Text("\(likeCount)")
                            .foregroundColor(.plumeTextSecondary)
                    }
                    .font(.system(size: 13))
                }

                // Share button
                Button(action: onShare) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("\(quote.shares)")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.plumeTextSecondary)
                }

                Spacer()

                // Time ago
                Text(quote.timeAgo)
                    .font(.system(size: 12))
                    .foregroundColor(.plumeTextSecondary.opacity(0.7))
            }
        }
        .padding(16)
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct SharePublicQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var quoteStore: QuoteStore
    @State private var selectedQuote: Quote?
    @State private var showingShareSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                if quoteStore.allQuotes.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select a quote to share")
                                .font(.custom("Georgia-Bold", size: 13))
                                .foregroundColor(.plumeTextSecondary)
                                .textCase(.uppercase)
                                .tracking(1.2)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

                            ForEach(quoteStore.allQuotes) { quote in
                                SelectableQuoteCard(
                                    quote: quote,
                                    isSelected: selectedQuote == quote,
                                    onTap: {
                                        selectedQuote = quote
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Share to Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Share") {
                        shareQuote()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(selectedQuote != nil ? .plumeAccent : .plumeTextSecondary)
                    .disabled(selectedQuote == nil)
                }
            }
            .alert("Quote Shared!", isPresented: $showingShareSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your quote is now visible in the community feed.")
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "quote.bubble")
                .font(.system(size: 50))
                .foregroundColor(.plumeTextSecondary.opacity(0.5))

            Text("No Quotes Yet")
                .font(.custom("Georgia-Bold", size: 18))
                .foregroundColor(.plumeTextPrimary)

            Text("Save quotes from your books first, then share them to the community.")
                .font(.system(size: 14))
                .foregroundColor(.plumeTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func shareQuote() {
        guard let quote = selectedQuote else { return }
        quoteStore.togglePublic(quote)
        showingShareSuccess = true
    }
}

struct SelectableQuoteCard: View {
    let quote: Quote
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(quote.text)
                        .font(.custom("Georgia-Italic", size: 14))
                        .foregroundColor(.plumeTextPrimary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    Text("— \(quote.bookTitle) by \(quote.bookAuthor)")
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .plumeAccent : .plumeTextSecondary.opacity(0.3))
            }
            .padding(16)
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.plumeAccent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CommunityFeedView()
            .environmentObject(QuoteStore())
    }
}
