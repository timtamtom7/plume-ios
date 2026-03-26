import SwiftUI

// MARK: - Save Quote Sheet (for Book Detail — pre-selected book)
struct SaveQuoteSheetForBook: View {
    let book: Book
    @EnvironmentObject var quoteStore: QuoteStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) private var dismiss

    @State private var quoteText: String = ""
    @State private var pageNumber: String = ""
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
                        // Book context
                        HStack(spacing: 12) {
                            CoverImageView(book: book, size: CGSize(width: 40, height: 60))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(book.title)
                                    .font(.custom("Georgia-Bold", size: 14))
                                    .foregroundColor(.plumeTextPrimary)
                                    .lineLimit(1)

                                Text(book.author)
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(Color.plumeSurface)
                        .cornerRadius(10)

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

        _ = quoteStore.addQuote(
            text: trimmedQuote,
            bookTitle: book.title,
            bookAuthor: book.author,
            bookId: book.id,
            pageNumber: page
        )

        // Record reading activity
        streakStore.recordReadingActivity(quotesSaved: 1)
        dismiss()
    }
}
