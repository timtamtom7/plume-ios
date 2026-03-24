import SwiftUI

struct UpdateProgressSheet: View {
    @EnvironmentObject var bookStore: BookStore
    @Environment(\.dismiss) private var dismiss

    let book: Book
    @State private var pageInput = ""
    @FocusState private var isInputFocused: Bool

    private var currentPage: Int { book.currentPage }
    private var totalPages: Int { book.totalPages }

    private var enteredPage: Int? {
        Int(pageInput)
    }

    private var newProgress: Double {
        guard let page = enteredPage else { return book.progressPercent }
        return min(Double(page) / Double(totalPages), 1.0)
    }

    private var newDaysToFinish: Int {
        let pagesPerDay = book.pagesPerDay
        guard pagesPerDay > 0, let page = enteredPage else { return book.daysToFinish }
        let remaining = max(totalPages - page, 0)
        return max(Int(ceil(Double(remaining) / pagesPerDay)), 0)
    }

    private var newEstimatedFinish: Date? {
        let pace = book.pagesPerDay
        guard pace > 0, let page = enteredPage else { return book.estimatedFinishDate }
        let remaining = max(totalPages - page, 0)
        guard remaining > 0 else { return Date() }
        let days = Int(ceil(Double(remaining) / pace))
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Book info
                    HStack(spacing: 12) {
                        CoverImageView(book: book, size: CGSize(width: 50, height: 75))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.custom("Georgia-Bold", size: 15))
                                .foregroundColor(.plumeTextPrimary)
                                .lineLimit(1)

                            Text("Page \(currentPage) of \(totalPages)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.plumeTextSecondary)
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(Color.plumeSurface)
                    .cornerRadius(12)

                    // Numpad
                    VStack(spacing: 12) {
                        // Display
                        HStack {
                            Text("Current page:")
                                .font(.system(size: 14))
                                .foregroundColor(.plumeTextSecondary)
                            Spacer()
                            TextField("\(currentPage)", text: $pageInput)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.plumeTextPrimary)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 120)
                                .focused($isInputFocused)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.plumeSurface)
                        .cornerRadius(12)

                        // Quick buttons
                        HStack(spacing: 8) {
                            QuickPageButton(label: "+10") {
                                addToPage(10)
                            }
                            QuickPageButton(label: "+25") {
                                addToPage(25)
                            }
                            QuickPageButton(label: "+50") {
                                addToPage(50)
                            }
                            QuickPageButton(label: "Last") {
                                setPage(totalPages)
                            }
                        }

                        // Numpad grid
                        VStack(spacing: 8) {
                            ForEach(numpadRows, id: \.self) { row in
                                HStack(spacing: 8) {
                                    ForEach(row, id: \.self) { num in
                                        NumpadButton(label: "\(num)") {
                                            pageInput += "\(num)"
                                        }
                                    }
                                }
                            }
                            HStack(spacing: 8) {
                                NumpadButton(label: "C", color: .plumeTextSecondary) {
                                    pageInput = ""
                                }
                                .frame(width: 72, height: 56)
                                NumpadButton(label: "⌫") {
                                    if !pageInput.isEmpty {
                                        pageInput.removeLast()
                                    }
                                }
                                .frame(width: 72, height: 56)
                                NumpadButton(label: "✓", color: .plumeCurrentlyReading) {
                                    saveProgress()
                                }
                                .frame(width: 72, height: 56)
                            }
                        }
                    }

                    // Preview
                    if let page = enteredPage, page != currentPage {
                        VStack(spacing: 12) {
                            ProgressBar(progress: newProgress)
                                .frame(height: 8)

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(Int(newProgress * 100))%")
                                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.plumeCurrentlyReading)
                                    Text("of \(totalPages) pages")
                                        .font(.system(size: 11))
                                        .foregroundColor(.plumeTextSecondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(newEstimatedFinish?.formatted(date: .abbreviated, time: .omitted) ?? "—")
                                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.plumeAccent)
                                    Text("\(newDaysToFinish) days remaining")
                                        .font(.system(size: 11))
                                        .foregroundColor(.plumeTextSecondary)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.plumeSurface)
                        .cornerRadius(12)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .onAppear {
                isInputFocused = true
            }
        }
    }

    private var numpadRows: [[Int]] {
        [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    }

    private func addToPage(_ amount: Int) {
        let current = Int(pageInput) ?? currentPage
        let next = min(current + amount, totalPages)
        pageInput = "\(next)"
    }

    private func setPage(_ page: Int) {
        pageInput = "\(page)"
    }

    private func saveProgress() {
        guard let page = enteredPage, page >= currentPage, page <= totalPages else { return }
        bookStore.updateProgress(bookId: book.id, newPage: page)
        dismiss()
    }
}

struct NumpadButton: View {
    let label: String
    var color: Color = .plumeTextPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(color)
                .frame(width: 72, height: 56)
                .background(Color.plumeSurface)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct QuickPageButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plumeAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.plumeAccent.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

#Preview {
    UpdateProgressSheet(book: .sample)
        .environmentObject(BookStore())
}
