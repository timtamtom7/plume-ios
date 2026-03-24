import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var bookStore: BookStore
    @State private var showingAddBook = false
    @State private var selectedBook: Book?

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    if !bookStore.currentlyReading.isEmpty {
                        librarySection(
                            title: "Currently Reading",
                            books: bookStore.currentlyReading,
                            accent: .plumeCurrentlyReading
                        )
                    }

                    if !bookStore.finishedBooks.isEmpty {
                        librarySection(
                            title: "Finished",
                            books: bookStore.finishedBooks,
                            accent: .plumeFinished
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddBook = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.plumeAccent)
                }
            }
        }
        .sheet(isPresented: $showingAddBook) {
            AddBookSheet()
        }
        .sheet(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
    }

    @ViewBuilder
    private func librarySection(title: String, books: [Book], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text("(\(books.count))")
                    .font(.system(size: 12))
                    .foregroundColor(.plumeTextSecondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                    BookRowView(book: book)
                        .onTapGesture {
                            selectedBook = book
                        }

                    if index < books.count - 1 {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }
}

struct BookRowView: View {
    let book: Book

    var body: some View {
        HStack(spacing: 12) {
            CoverImageView(book: book, size: CGSize(width: 50, height: 75))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.custom("Georgia-Bold", size: 15))
                    .foregroundColor(.plumeTextPrimary)
                    .lineLimit(1)

                Text(book.author)
                    .font(.custom("Georgia", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if book.isFinished {
                        Label("Finished", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.plumeFinished)
                    } else {
                        Text("Page \(book.currentPage) / \(book.totalPages)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.plumeTextSecondary)

                        Text("·")
                            .foregroundColor(.plumeTextSecondary)

                        Text("\(Int(book.pagesPerDay)) p/day")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.plumeCurrentlyReading)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.plumeTextSecondary.opacity(0.5))
        }
        .padding(12)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        LibraryView()
            .environmentObject(BookStore())
    }
}
