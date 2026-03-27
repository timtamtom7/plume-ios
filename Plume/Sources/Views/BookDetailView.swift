import SwiftUI
import Charts

struct BookDetailView: View {
    @EnvironmentObject var bookStore: BookStore
    @EnvironmentObject var quoteStore: QuoteStore
    @EnvironmentObject var noteStore: NoteStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingUpdateProgress = false
    @State private var showingDeleteAlert = false
    @State private var showingNotes = false
    @State private var showingSaveQuote = false

    let book: Book

    private var progressEntries: [ProgressEntry] {
        bookStore.getProgressEntries(forBookId: book.id)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Cover and basic info
                        VStack(spacing: 16) {
                            CoverImageView(book: book, size: CGSize(width: 140, height: 210))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                            VStack(spacing: 6) {
                                Text(book.title)
                                    .font(.custom("Georgia-Bold", size: 20))
                                    .foregroundColor(.plumeTextPrimary)
                                    .multilineTextAlignment(.center)

                                Text(book.author)
                                    .font(.custom("Georgia", size: 16))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                        .padding(.top, 8)

                        // Progress bar
                        VStack(spacing: 8) {
                            HStack {
                                Text("Page \(book.currentPage)")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.plumeTextSecondary)
                                Spacer()
                                Text("\(Int(book.progressPercent * 100))%")
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.plumeAccent)
                            }

                            ProgressBar(progress: book.progressPercent)
                                .frame(height: 8)
                        }
                        .padding(16)
                        .background(Color.plumeSurface)
                        .cornerRadius(12)

                        // Stats grid
                        statsGrid

                        // Pace chart
                        if progressEntries.count > 1 {
                            paceChartSection
                        }

                        // Update progress button
                        if !book.isFinished {
                            Button {
                                showingUpdateProgress = true
                            } label: {
                                HStack {
                                    Image(systemName: "pencil.circle")
                                    Text("Update Progress")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.plumeAccent)
                                .cornerRadius(10)
                            }
                        }

                        // Notes & Quote buttons
                        HStack(spacing: 12) {
                            Button {
                                showingNotes = true
                            } label: {
                                HStack {
                                    Image(systemName: "note.text")
                                    Text("Notes")
                                    if noteStore.notesForBook(book).count > 0 {
                                        Text("(\(noteStore.notesForBook(book).count))")
                                            .font(.system(size: 12, design: .monospaced))
                                    }
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plumeAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.plumeAccent.opacity(0.1))
                                .cornerRadius(10)
                            }

                            Button {
                                showingSaveQuote = true
                            } label: {
                                HStack {
                                    Image(systemName: "quote.opening")
                                    Text("Quote")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plumeAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.plumeAccent.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }

                        // Delete button
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Book")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Book Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .sheet(isPresented: $showingUpdateProgress) {
                UpdateProgressSheet(book: book)
            }
            .sheet(isPresented: $showingNotes) {
                BookNotesView(book: book)
            }
            .sheet(isPresented: $showingSaveQuote) {
                SaveQuoteSheetForBook(book: book)
            }
            .alert("Delete Book?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    bookStore.deleteBook(book)
                    dismiss()
                }
            } message: {
                Text("This will permanently delete \"\(book.title)\" and all reading history.")
            }
        }
    }

    @ViewBuilder
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(title: "Pages/Day", value: String(format: "%.1f", book.pagesPerDay), icon: "book", color: .plumeCurrentlyReading)
            StatCard(title: "Days Reading", value: "\(book.daysReading)", icon: "calendar", color: .plumeAccentSecondary)
            StatCard(title: "Started", value: book.startDate.formatted(date: .abbreviated, time: .omitted), icon: "flag", color: .plumeAccent)

            if let finishDate = book.finishDate {
                StatCard(title: "Finished", value: finishDate.formatted(date: .abbreviated, time: .omitted), icon: "checkmark.circle", color: .plumeFinished)
            } else {
                StatCard(title: "Est. Finish", value: book.estimatedFinishDate?.formatted(date: .abbreviated, time: .omitted) ?? "—", icon: "clock", color: .plumeAccentSecondary)
            }

            StatCard(title: "Pages Read", value: "\(book.pagesRead)", icon: "bookmark", color: .plumeCurrentlyReading)
            StatCard(title: "Remaining", value: "\(book.remainingPages)", icon: "book.closed", color: .plumeTextSecondary)
        }
    }

    @ViewBuilder
    private var paceChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reading Pace")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            Chart {
                ForEach(Array(progressEntries.enumerated()), id: \.element.id) { index, entry in
                    let dayOffset = Calendar.current.dateComponents([.day], from: book.startDate, to: entry.date).day ?? 0
                    LineMark(
                        x: .value("Day", dayOffset),
                        y: .value("Page", entry.page)
                    )
                    .foregroundStyle(Color.plumeAccent)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Day", dayOffset),
                        y: .value("Page", entry.page)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.plumeAccent.opacity(0.3), Color.plumeAccent.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let day = value.as(Int.self) {
                            Text("D\(day)")
                                .font(Theme.fontCaption)
                                .foregroundColor(.plumeTextSecondary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let page = value.as(Int.self) {
                            Text("\(page)")
                                .font(Theme.fontCaption)
                                .foregroundColor(.plumeTextSecondary)
                        }
                    }
                }
            }
            .frame(height: 160)
            .padding(16)
            .background(Color.plumeSurface)
            .cornerRadius(Theme.cornerRadiusLarge)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.plumeTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.plumeTextSecondary)
        }
        .padding(12)
        .background(Color.plumeSurface)
        .cornerRadius(10)
    }
}

#Preview {
    BookDetailView(book: .sample)
        .environmentObject(BookStore())
}
