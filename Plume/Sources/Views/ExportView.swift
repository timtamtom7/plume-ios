import SwiftUI

struct ExportView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var exportService = ExportService()
    @State private var selectedCitationStyle: CitationStyle = .plain
    @State private var readwiseAPIKey: String = ""
    @State private var notionAPIKey: String = ""
    @State private var notionDatabaseId: String = ""
    @State private var showingExportSuccess = false
    @State private var exportSuccessMessage = ""
    @State private var showingExportError = false
    @State private var exportErrorMessage = ""
    @State private var sampleQuotes: [ExportQuote] = []

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Citation Style Selector
                    citationStyleSection

                    // Export to PDF
                    pdfExportSection

                    // Export to Readwise
                    readwiseExportSection

                    // Export to Notion
                    notionExportSection

                    // Export to Obsidian
                    obsidianExportSection

                    // Copy All Citations
                    copyCitationsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Export & Citations")
        .navigationBarTitleDisplayMode(.large)
        .alert("Export Complete", isPresented: $showingExportSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportSuccessMessage)
        }
        .alert("Export Error", isPresented: $showingExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportErrorMessage)
        }
        .onAppear {
            loadSampleQuotes()
        }
    }

    private func loadSampleQuotes() {
        // In production, this would come from user's actual quotes
        sampleQuotes = [
            ExportQuote(
                text: "So we beat on, boats against the current, borne back ceaselessly into the past.",
                bookTitle: "The Great Gatsby",
                author: "F. Scott Fitzgerald",
                pageNumber: 180,
                dateAdded: Date()
            ),
            ExportQuote(
                text: "And, when you want something, all the universe conspires in helping you to achieve it.",
                bookTitle: "The Alchemist",
                author: "Paulo Coelho",
                pageNumber: 208,
                dateAdded: Date()
            ),
            ExportQuote(
                text: "You are what you do. Not what you say you'll do.",
                bookTitle: "Atomic Habits",
                author: "James Clear",
                pageNumber: 45,
                dateAdded: Date()
            ),
        ]
    }

    @ViewBuilder
    private var citationStyleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Citation Style")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(spacing: 0) {
                ForEach(CitationStyle.allCases) { style in
                    Button {
                        selectedCitationStyle = style
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(style.rawValue)
                                    .font(.system(size: 15))
                                    .foregroundColor(.plumeTextPrimary)

                                Text(citationExample(for: style))
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if selectedCitationStyle == style {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.plumeAccent)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.plumeTextSecondary.opacity(0.3))
                            }
                        }
                        .padding(16)
                    }

                    if style != CitationStyle.allCases.last {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }

    private func citationExample(for style: CitationStyle) -> String {
        style.format(
            bookTitle: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            quote: "So we beat on...",
            pageNumber: 180
        )
    }

    @ViewBuilder
    private var pdfExportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Export as PDF")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                if !subscriptionManager.currentTier.features.contains(where: { $0.text.contains("Export") && $0.included }) {
                    Image(systemName: "lock.fill")
                        .font(Theme.fontCaption)
                        .foregroundColor(.plumeTextSecondary)
                }
            }

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "doc.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("PDF Book of Quotes")
                            .font(.system(size: 15))
                            .foregroundColor(.plumeTextPrimary)

                        Text("Beautiful formatted document with all your quotes")
                            .font(.system(size: 12))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()
                }
                .padding(16)

                Divider()
                    .padding(.leading, 72)

                Button {
                    exportToPDF()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Generate PDF")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.plumeAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .disabled(exportService.isExporting)
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private var readwiseExportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Export to Readwise")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                if !subscriptionManager.currentTier.features.contains(where: { $0.text.contains("Export") && $0.included }) {
                    Image(systemName: "lock.fill")
                        .font(Theme.fontCaption)
                        .foregroundColor(.plumeTextSecondary)
                }
            }

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Readwise")
                            .font(.system(size: 15))
                            .foregroundColor(.plumeTextPrimary)

                        Text("Sync highlights to your Readwise library")
                            .font(.system(size: 12))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()
                }
                .padding(16)

                Divider()
                    .padding(.leading, 72)

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)

                    SecureField("Enter your Readwise API key", text: $readwiseAPIKey)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(Color.plumeBackground)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)

                Button {
                    exportToReadwise()
                } label: {
                    HStack {
                        if exportService.isExporting {
                            ProgressView()
                                .tint(.plumeAccent)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text("Export to Readwise")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.plumeAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .disabled(readwiseAPIKey.isEmpty || exportService.isExporting)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private var notionExportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Export to Notion")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                if !subscriptionManager.currentTier.features.contains(where: { $0.text.contains("Export") && $0.included }) {
                    Image(systemName: "lock.fill")
                        .font(Theme.fontCaption)
                        .foregroundColor(.plumeTextSecondary)
                }
            }

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notion")
                            .font(.system(size: 15))
                            .foregroundColor(.plumeTextPrimary)

                        Text("Add quotes to your Notion database")
                            .font(.system(size: 12))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()
                }
                .padding(16)

                Divider()
                    .padding(.leading, 72)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Integration Token")
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)

                    SecureField("Notion API Key", text: $notionAPIKey)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(Color.plumeBackground)
                        .cornerRadius(8)

                    Text("Database ID")
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)

                    TextField("Notion Database ID", text: $notionDatabaseId)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(Color.plumeBackground)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)

                Button {
                    exportToNotion()
                } label: {
                    HStack {
                        if exportService.isExporting {
                            ProgressView()
                                .tint(.plumeAccent)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text("Export to Notion")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.plumeAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .disabled(notionAPIKey.isEmpty || notionDatabaseId.isEmpty || exportService.isExporting)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private var obsidianExportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export to Obsidian")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.purple)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Obsidian Markdown")
                            .font(.system(size: 15))
                            .foregroundColor(.plumeTextPrimary)

                        Text("Generate markdown file with citations")
                            .font(.system(size: 12))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()
                }
                .padding(16)

                Divider()
                    .padding(.leading, 72)

                Button {
                    exportToObsidian()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Generate Markdown")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.plumeAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .disabled(exportService.isExporting)
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private var copyCitationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Copy Citations")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.plumeAccent.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.plumeAccent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Copy All Citations")
                            .font(.system(size: 15))
                            .foregroundColor(.plumeTextPrimary)

                        Text("Copy all quotes as formatted citations")
                            .font(.system(size: 12))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()
                }
                .padding(16)

                Divider()
                    .padding(.leading, 72)

                Button {
                    copyAllCitations()
                } label: {
                    HStack {
                        Image(systemName: "doc.on.clipboard")
                        Text("Copy Citations (\(selectedCitationStyle.rawValue))")
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
    }

    private func exportToPDF() {
        if let url = exportService.exportQuotesToPDF(
            quotes: sampleQuotes,
            title: "My Reading Quotes",
            citationStyle: selectedCitationStyle
        ) {
            exportSuccessMessage = "PDF saved to \(url.lastPathComponent)"
            showingExportSuccess = true
        } else if let error = exportService.exportError {
            exportErrorMessage = error
            showingExportError = true
        }
    }

    private func exportToReadwise() {
        exportService.exportToReadwise(apiKey: readwiseAPIKey, quotes: sampleQuotes) { result in
            switch result {
            case .success(let count):
                exportSuccessMessage = "Successfully exported \(count) quotes to Readwise!"
                showingExportSuccess = true
            case .failure(let error):
                exportErrorMessage = error.localizedDescription
                showingExportError = true
            }
        }
    }

    private func exportToNotion() {
        exportService.exportToNotion(
            apiKey: notionAPIKey,
            databaseId: notionDatabaseId,
            quotes: sampleQuotes
        ) { result in
            switch result {
            case .success(let count):
                exportSuccessMessage = "Successfully exported \(count) quotes to Notion!"
                showingExportSuccess = true
            case .failure(let error):
                exportErrorMessage = error.localizedDescription
                showingExportError = true
            }
        }
    }

    private func exportToObsidian() {
        if let url = exportService.exportToObsidian(quotes: sampleQuotes, citationStyle: selectedCitationStyle) {
            exportSuccessMessage = "Markdown saved to \(url.lastPathComponent)"
            showingExportSuccess = true
        } else if let error = exportService.exportError {
            exportErrorMessage = error
            showingExportError = true
        }
    }

    private func copyAllCitations() {
        let citations = exportService.copyCitations(for: sampleQuotes, style: selectedCitationStyle)
        UIPasteboard.general.string = citations
        exportSuccessMessage = "Citations copied to clipboard!"
        showingExportSuccess = true
    }
}

#Preview {
    NavigationStack {
        ExportView()
            .environmentObject(SubscriptionManager.shared)
    }
}
