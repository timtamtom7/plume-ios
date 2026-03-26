import SwiftUI

// MARK: - Quotes List View
struct QuotesListView: View {
    @EnvironmentObject var quoteStore: QuoteStore
    @EnvironmentObject var bookStore: BookStore
    @State private var selectedFilter: QuoteFilter = .all
    @State private var searchText: String = ""
    @State private var selectedQuote: Quote?
    @State private var showingQuoteDetail: Bool = false
    @State private var showingSaveQuote: Bool = false
    @State private var quoteToDelete: Quote?
    @State private var showingDeleteAlert: Bool = false

    enum QuoteFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case publicQuotes = "Shared"
    }

    private var filteredQuotes: [Quote] {
        let base: [Quote]
        switch selectedFilter {
        case .all: base = quoteStore.allQuotes
        case .favorites: base = quoteStore.favoriteQuotes
        case .publicQuotes: base = quoteStore.publicQuotes
        }

        if searchText.isEmpty {
            return base
        }
        return base.filter {
            $0.text.localizedCaseInsensitiveContains(searchText) ||
            $0.bookTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.bookAuthor.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            if quoteStore.allQuotes.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    // Search bar
                    searchBar

                    // Filter tabs
                    filterTabs

                    // Quotes list
                    quotesList
                }
            }
        }
        .navigationTitle("My Quotes")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSaveQuote = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.plumeAccent)
                }
                .accessibilityLabel("Add quote")
            }
        }
        .sheet(isPresented: $showingSaveQuote) {
            SaveQuoteSheet()
        }
        .sheet(item: $selectedQuote) { quote in
            QuoteDetailSheet(quote: quote)
        }
        .alert("Delete Quote?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let quote = quoteToDelete {
                    quoteStore.deleteQuote(quote)
                }
            }
        } message: {
            if let quote = quoteToDelete {
                Text("Delete \"\(String(quote.text.prefix(50)))...\"? This cannot be undone.")
            }
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(.plumeTextSecondary)

            TextField("Search quotes, books, authors...", text: $searchText)
                .font(.system(size: 15))
                .foregroundColor(.plumeTextPrimary)
                .accessibilityLabel("Search quotes")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.plumeTextSecondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(10)
        .background(Color.plumeSurface)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(QuoteFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight: selectedFilter == filter ? .semibold : .medium))
                            .foregroundColor(selectedFilter == filter ? .plumeAccent : .plumeTextSecondary)

                        Rectangle()
                            .fill(selectedFilter == filter ? Color.plumeAccent : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("\(filter.rawValue) quotes")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var quotesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredQuotes.isEmpty {
                    emptyFilteredState
                } else {
                    ForEach(filteredQuotes) { quote in
                        QuoteRowCard(quote: quote)
                            .onTapGesture {
                                selectedQuote = quote
                            }
                            .contextMenu {
                                Button {
                                    selectedQuote = quote
                                } label: {
                                    Label("View Details", systemImage: "eye")
                                }

                                Button {
                                    quoteStore.toggleFavorite(quote)
                                } label: {
                                    Label(quote.isFavorite ? "Unfavorite" : "Favorite", systemImage: quote.isFavorite ? "heart.slash" : "heart")
                                }

                                Button {
                                    copyQuote(quote)
                                } label: {
                                    Label("Copy Text", systemImage: "doc.on.doc")
                                }

                                Divider()

                                Button(role: .destructive) {
                                    quoteToDelete = quote
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.plumeAccentSecondary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "quote.bubble")
                    .font(.system(size: 48))
                    .foregroundColor(.plumeAccentSecondary)
            }

            VStack(spacing: 8) {
                Text("No quotes yet")
                    .font(.custom("Georgia-Bold", size: 20))
                    .foregroundColor(.plumeTextPrimary)

                Text("Save memorable passages from your books.\nThey'll appear here, ready to share.")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Button {
                showingSaveQuote = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Save Your First Quote")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.plumeAccent)
                .cornerRadius(10)
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    @ViewBuilder
    private var emptyFilteredState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.plumeTextSecondary.opacity(0.5))

            Text("No \(selectedFilter.rawValue.lowercased()) quotes")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.plumeTextPrimary)

            if !searchText.isEmpty {
                Text("Try a different search term")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary)
            }
        }
        .padding(.vertical, 48)
    }

    private func copyQuote(_ quote: Quote) {
        UIPasteboard.general.string = quote.citation
    }
}

// MARK: - Quote Row Card
struct QuoteRowCard: View {
    let quote: Quote
    @EnvironmentObject var quoteStore: QuoteStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeAccentSecondary)
                    .padding(.top, 2)

                Text(quote.text)
                    .font(.custom("Georgia-Italic", size: 15))
                    .foregroundColor(.plumeTextPrimary)
                    .lineSpacing(3)
                    .lineLimit(4)
            }

            Divider()

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(quote.bookTitle)
                        .font(.custom("Georgia-Bold", size: 13))
                        .foregroundColor(.plumeTextPrimary)
                        .lineLimit(1)

                    Text(quote.bookAuthor)
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 12) {
                    if let page = quote.pageNumber {
                        Text("p. \(page)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.plumeTextSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.plumeTextSecondary.opacity(0.1))
                            .cornerRadius(4)
                    }

                    Button {
                        quoteStore.toggleFavorite(quote)
                    } label: {
                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(quote.isFavorite ? .red : .plumeTextSecondary)
                    }
                    .accessibilityLabel(quote.isFavorite ? "Remove from favorites" : "Add to favorites")

                    if quote.isPublic {
                        Image(systemName: "globe")
                            .font(.system(size: 11))
                            .foregroundColor(.plumeAccent)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Quote from \(quote.bookTitle) by \(quote.bookAuthor): \(quote.text)")
    }
}

// MARK: - Quote Detail Sheet
struct QuoteDetailSheet: View {
    let quote: Quote
    @EnvironmentObject var quoteStore: QuoteStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCitationStyle: CitationStyle = .plain
    @State private var showingCopied: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Quote card
                        QuoteCardView(
                            quote: quote.text,
                            bookTitle: quote.bookTitle,
                            author: quote.bookAuthor,
                            citationStyle: selectedCitationStyle
                        )

                        // Citation style picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Citation Style")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.plumeTextSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            HStack(spacing: 8) {
                                ForEach(CitationStyle.allCases) { style in
                                    Button {
                                        selectedCitationStyle = style
                                    } label: {
                                        Text(style.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(selectedCitationStyle == style ? .white : .plumeAccent)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(selectedCitationStyle == style ? Color.plumeAccent : Color.plumeAccent.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }

                        // Actions
                        VStack(spacing: 12) {
                            Button {
                                copyQuote()
                            } label: {
                                HStack {
                                    Image(systemName: showingCopied ? "checkmark" : "doc.on.doc")
                                    Text(showingCopied ? "Copied!" : "Copy Citation")
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.plumeAccent)
                                .cornerRadius(10)
                            }
                            .accessibilityLabel("Copy citation")

                            Button {
                                quoteStore.toggleFavorite(quote)
                            } label: {
                                HStack {
                                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                                    Text(quote.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(quote.isFavorite ? .red : .plumeAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(quote.isFavorite ? Color.red.opacity(0.1) : Color.plumeAccent.opacity(0.1))
                                .cornerRadius(10)
                            }

                            Button {
                                quoteStore.togglePublic(quote)
                            } label: {
                                HStack {
                                    Image(systemName: quote.isPublic ? "globe" : "globe")
                                    Text(quote.isPublic ? "Shared with Community" : "Share to Community")
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.plumeAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.plumeAccent.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
        }
    }

    private func copyQuote() {
        let citation = selectedCitationStyle.format(
            bookTitle: quote.bookTitle,
            author: quote.bookAuthor,
            quote: quote.text,
            pageNumber: quote.pageNumber
        )
        UIPasteboard.general.string = citation
        showingCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingCopied = false
        }
    }
}

// MARK: - Save Quote Sheet
struct SaveQuoteSheet: View {
    @EnvironmentObject var quoteStore: QuoteStore
    @EnvironmentObject var bookStore: BookStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) private var dismiss

    @State private var quoteText: String = ""
    @State private var selectedBook: Book?
    @State private var pageNumber: String = ""
    @State private var authorOverride: String = ""
    @State private var titleOverride: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    private var canSave: Bool {
        !quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Book picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Book")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.plumeTextSecondary)

                            if bookStore.allBooks.isEmpty {
                                Text("Add books to your library first")
                                    .font(.system(size: 14))
                                    .foregroundColor(.plumeTextSecondary)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.plumeSurface)
                                    .cornerRadius(8)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(bookStore.allBooks) { book in
                                            BookPickerChip(
                                                book: book,
                                                isSelected: selectedBook?.id == book.id
                                            ) {
                                                selectedBook = book
                                                authorOverride = book.author
                                                titleOverride = book.title
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Manual override (if no book selected or custom entry)
                        if selectedBook == nil {
                            VStack(spacing: 12) {
                                FormField(title: "Book Title (optional)", text: $titleOverride, placeholder: "The Great Gatsby")
                                FormField(title: "Author (optional)", text: $authorOverride, placeholder: "F. Scott Fitzgerald")
                            }
                        }

                        // Quote text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quote")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.plumeTextSecondary)

                            TextEditor(text: $quoteText)
                                .font(.custom("Georgia-Italic", size: 16))
                                .foregroundColor(.plumeTextPrimary)
                                .lineSpacing(4)
                                .frame(minHeight: 140)
                                .padding(12)
                                .background(Color.plumeSurface)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.plumeTextSecondary.opacity(0.15), lineWidth: 1)
                                )
                                .overlay(alignment: .topLeading) {
                                    if quoteText.isEmpty {
                                        Text("Enter the passage that moved you...")
                                            .font(.custom("Georgia-Italic", size: 16))
                                            .foregroundColor(.plumeTextSecondary.opacity(0.5))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .accessibilityLabel("Quote text")
                        }

                        // Page number
                        FormField(title: "Page Number (optional)", text: $pageNumber, placeholder: "42", keyboard: .numberPad)

                        Spacer(minLength: 32)

                        Button {
                            saveQuote()
                        } label: {
                            HStack {
                                Image(systemName: "quote.bubble.fill")
                                Text("Save Quote")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canSave ? Color.plumeAccent : Color.plumeTextSecondary)
                            .cornerRadius(10)
                        }
                        .disabled(!canSave)
                        .accessibilityLabel("Save quote")
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Save Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveQuote() {
        let trimmedQuote = quoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuote.isEmpty else {
            errorMessage = "Please enter a quote."
            showingError = true
            return
        }

        let page: Int? = Int(pageNumber)

        if let book = selectedBook {
            _ = quoteStore.addQuote(
                text: trimmedQuote,
                bookTitle: book.title,
                bookAuthor: book.author,
                bookId: book.id,
                pageNumber: page
            )
        } else {
            let title = titleOverride.isEmpty ? "Unknown Book" : titleOverride
            let author = authorOverride.isEmpty ? "Unknown Author" : authorOverride
            _ = quoteStore.addQuote(
                text: trimmedQuote,
                bookTitle: title,
                bookAuthor: author,
                bookId: nil,
                pageNumber: page
            )
        }

        // Record reading activity (streak)
        streakStore.recordReadingActivity(quotesSaved: 1)
        dismiss()
    }
}

// MARK: - Book Picker Chip
struct BookPickerChip: View {
    let book: Book
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                CoverImageView(book: book, size: CGSize(width: 28, height: 42))
                    .cornerRadius(3)

                Text(book.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .plumeTextPrimary)
                    .lineLimit(1)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color.plumeAccent : Color.plumeSurface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.plumeTextSecondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(book.title) by \(book.author), \(isSelected ? "selected" : "not selected")")
    }
}

#Preview {
    NavigationStack {
        QuotesListView()
            .environmentObject(QuoteStore())
            .environmentObject(BookStore())
            .environmentObject(StreakStore())
    }
}
