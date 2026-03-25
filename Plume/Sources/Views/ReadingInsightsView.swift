import SwiftUI

/// R7: Deep Reading Insights view - AI-powered analysis and recommendations
struct ReadingInsightsView: View {
    @StateObject private var insightsService = ReadingInsightsService.shared
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                if insightsService.isAnalyzing {
                    analyzingView
                } else if insightsService.readingPatterns.isEmpty {
                    emptyState
                } else {
                    insightsContent
                }
            }
            .navigationTitle("Reading Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await insightsService.analyzeAll(books: [])
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color.plumeAccent)
                    }
                }
            }
            .task {
                if insightsService.readingPatterns.isEmpty {
                    await insightsService.analyzeAll(books: [])
                }
            }
        }
    }

    private var analyzingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(Color.plumeAccent)

            VStack(spacing: 6) {
                Text("Analyzing your library…")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.plumeTextPrimary)

                Text("Discovering your reading patterns")
                    .font(.system(size: 14))
                    .foregroundColor(Color.plumeTextSecondary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(Color.plumeTextSecondary)

            VStack(spacing: 6) {
                Text("No books to analyze")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.plumeTextPrimary)

                Text("Add books to your library to\nuncover reading insights.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.plumeTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await insightsService.analyzeAll(books: [])
                }
            } label: {
                Text("Analyze Now")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 160, height: 44)
                    .background(Color.plumeAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 8)
        }
        .padding(40)
    }

    private var insightsContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                statsSection
                patternsSection
                recommendationsSection
            }
            .padding(.vertical, 16)
        }
    }

    private var statsSection: some View {
        VStack(spacing: 12) {
            ForEach(insightsService.insights) { insight in
                insightCard(insight)
            }
        }
        .padding(.horizontal, 16)
    }

    private func insightCard(_ insight: ReadingInsightsService.ReadingInsight) -> some View {
        HStack(spacing: 16) {
            Image(systemName: insight.icon)
                .font(.system(size: 24))
                .foregroundColor(Color.plumeAccent)
                .frame(width: 48, height: 48)
                .background(Color.plumeAccent.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.system(size: 13))
                    .foregroundColor(Color.plumeTextSecondary)

                Text(insight.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.plumeTextPrimary)
            }

            Spacer()

            Text(insight.detail)
                .font(.system(size: 12))
                .foregroundColor(Color.plumeTextSecondary)
        }
        .padding(16)
        .background(Color.plumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Reading Patterns")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.plumeTextPrimary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insightsService.readingPatterns) { pattern in
                        patternCard(pattern)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func patternCard(_ pattern: ReadingInsightsService.ReadingPattern) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: patternIcon(pattern.type))
                    .font(.system(size: 24))
                    .foregroundColor(Color.plumeAccent)
                Spacer()
            }

            Text(pattern.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.plumeTextPrimary)

            Text(pattern.description)
                .font(.system(size: 13))
                .foregroundColor(Color.plumeTextSecondary)
                .lineLimit(3)
        }
        .frame(width: 160)
        .padding(16)
        .background(Color.plumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func patternIcon(_ type: ReadingInsightsService.ReadingPattern.PatternType) -> String {
        switch type {
        case .voracious: return "star.fill"
        case .nightOwl: return "moon.fill"
        case .morningReader: return "sunrise.fill"
        case .genreLover: return "books.vertical.fill"
        case .collector: return "archivebox.fill"
        case .socialReader: return "person.2.fill"
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended for You")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.plumeTextPrimary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                ForEach(insightsService.recommendations) { rec in
                    recommendationRow(rec)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func recommendationRow(_ rec: ReadingInsightsService.BookRecommendation) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(LinearGradient(colors: [Color.plumeAccent, Color.plumeAccentSecondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(rec.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.plumeTextPrimary)

                Text(rec.author)
                    .font(.system(size: 13))
                    .foregroundColor(Color.plumeTextSecondary)

                HStack(spacing: 4) {
                    Text(rec.genre)
                        .font(.system(size: 11))
                    Text("•")
                    Text("\(rec.matchScore)% match")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.plumeAccent)
                }
                .foregroundColor(Color.plumeTextSecondary)
            }

            Spacer()

            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.plumeAccent)
        }
        .padding(12)
        .background(Color.plumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
