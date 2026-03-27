import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFImportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var ocrService = OCRService()
    @State private var showingPicker = false
    @State private var selectedPDF: PDFDocument?
    @State private var selectedPages: [Int] = []
    @State private var extractedText: [Int: String] = [:]
    @State private var bookTitle = ""
    @State private var bookAuthor = ""
    @State private var isProcessing = false
    @State private var processingPage: Int?
    @State private var showingSaveSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                if let pdf = selectedPDF {
                    pdfContent(pdf)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Import from PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .fileImporter(
                isPresented: $showingPicker,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .sheet(isPresented: $showingSaveSheet) {
                if !selectedPages.isEmpty {
                    SavePDFQuotesSheet(
                        bookTitle: bookTitle,
                        bookAuthor: bookAuthor,
                        pagesWithText: selectedPages.map { ($0, extractedText[$0] ?? "") },
                        onSave: saveQuotes
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.plumeAccent.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "doc.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.plumeAccent)
            }

            VStack(spacing: 8) {
                Text("Import from PDF")
                    .font(.custom("Georgia-Bold", size: 20))
                    .foregroundColor(.plumeTextPrimary)

                Text("Select a PDF of your book and extract text from any page.")
                    .font(.system(size: 14))
                    .foregroundColor(.plumeTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showingPicker = true
            } label: {
                HStack {
                    Image(systemName: "folder.fill")
                    Text("Select PDF")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.plumeAccent)
                .cornerRadius(10)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    @ViewBuilder
    private func pdfContent(_ pdf: PDFDocument) -> some View {
        VStack(spacing: 0) {
            // PDF info header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 40, height: 50)

                    Image(systemName: "doc.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(pdfAttributes(pdf).title ?? "Untitled PDF")
                        .font(.custom("Georgia-Bold", size: 14))
                        .foregroundColor(.plumeTextPrimary)
                        .lineLimit(1)

                    Text("\(pdf.pageCount) pages")
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)
                }

                Spacer()

                Button {
                    showingPicker = true
                } label: {
                    Text("Change")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plumeAccent)
                }
            }
            .padding(16)
            .background(Color.plumeSurface)

            Divider()

            // Instructions
            HStack {
                Image(systemName: "hand.tap")
                    .foregroundColor(.plumeAccent)
                Text("Tap pages to select them for text extraction")
                    .font(.system(size: 13))
                    .foregroundColor(.plumeTextSecondary)
                Spacer()
            }
            .padding(12)
            .background(Color.plumeAccent.opacity(0.05))

            // Page grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(0..<pdf.pageCount, id: \.self) { index in
                        PDFPageThumbnail(
                            pdf: pdf,
                            pageIndex: index,
                            isSelected: selectedPages.contains(index),
                            extractedText: extractedText[index],
                            isProcessing: processingPage == index
                        )
                        .onTapGesture {
                            togglePage(index)
                        }
                    }
                }
                .padding(16)
            }

            // Bottom bar
            if !selectedPages.isEmpty {
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(selectedPages.count) page\(selectedPages.count == 1 ? "" : "s") selected")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plumeTextPrimary)
                            Text("\(selectedPages.filter { extractedText[$0] != nil }.count) with text extracted")
                                .font(.system(size: 12))
                                .foregroundColor(.plumeTextSecondary)
                        }

                        Spacer()

                        Button {
                            showingSaveSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.plumeAccent)
                            .cornerRadius(10)
                        }
                    }
                    .padding(16)
                    .background(Color.plumeSurface)
                }
            }
        }
    }

    private func pdfAttributes(_ pdf: PDFDocument) -> (title: String?, author: String?) {
        // Access PDF document attributes
        if let attrs = pdf.documentAttributes {
            let title = attrs[PDFDocumentAttribute.titleAttribute] as? String
            let author = attrs[PDFDocumentAttribute.authorAttribute] as? String
            return (title, author)
        }
        return (nil, nil)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            if let pdf = PDFDocument(url: url) {
                selectedPDF = pdf
                let attrs = pdfAttributes(pdf)
                bookTitle = attrs.title ?? ""
                bookAuthor = attrs.author ?? ""
            }
        case .failure(let error):
            print("PDF import error: \(error)")
        }
    }

    private func togglePage(_ index: Int) {
        if selectedPages.contains(index) {
            selectedPages.removeAll { $0 == index }
        } else {
            selectedPages.append(index)
            extractTextFromPage(index)
        }
    }

    private func extractTextFromPage(_ index: Int) {
        guard let pdf = selectedPDF,
              let page = pdf.page(at: index) else { return }

        processingPage = index

        // Get text from PDF page directly first
        if let pageText = page.string, !pageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            extractedText[index] = pageText
            processingPage = nil
            return
        }

        // Fall back to OCR for image-based PDFs
        let image = page.thumbnail(of: CGSize(width: 600, height: 800), for: .mediaBox)
        ocrService.recognizeText(from: image) { result in
            processingPage = nil
            switch result {
            case .success(let text):
                extractedText[index] = text
            case .failure:
                extractedText[index] = "[No text could be extracted from this page]"
            }
        }
    }

    private func saveQuotes() {
        // In production, save to QuoteStore
        dismiss()
    }
}

struct PDFPageThumbnail: View {
    let pdf: PDFDocument
    let pageIndex: Int
    let isSelected: Bool
    let extractedText: String?
    let isProcessing: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let page = pdf.page(at: pageIndex) {
                    let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 140), for: .mediaBox)
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .cornerRadius(4)
                } else {
                    Rectangle()
                        .fill(Color.plumeTextSecondary.opacity(0.1))
                        .frame(height: 120)
                        .cornerRadius(4)
                }

                // Selection overlay
                if isSelected {
                    Rectangle()
                        .fill(Color.plumeAccent.opacity(0.3))
                        .cornerRadius(4)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                // Processing indicator
                if isProcessing {
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .cornerRadius(4)

                    ProgressView()
                        .tint(.white)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.plumeAccent : Color.clear, lineWidth: 2)
            )

            Text("p. \(pageIndex + 1)")
                .font(.system(size: 11))
                .foregroundColor(extractedText != nil ? .plumeAccent : .plumeTextSecondary)

            if extractedText != nil {
                Image(systemName: "text.alignleft")
                    .font(Theme.fontCaption)
                    .foregroundColor(.plumeAccent)
            }
        }
    }
}

struct SavePDFQuotesSheet: View {
    let bookTitle: String
    let bookAuthor: String
    let pagesWithText: [(page: Int, text: String)]
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Summary
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: "#8b4513") ?? .brown)
                                    .frame(width: 35, height: 50)

                                Image(systemName: "book.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(bookTitle.isEmpty ? "Untitled" : bookTitle)
                                    .font(.custom("Georgia-Bold", size: 14))
                                    .foregroundColor(.plumeTextPrimary)

                                Text(bookAuthor.isEmpty ? "Unknown Author" : bookAuthor)
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Color.plumeSurface)
                        .cornerRadius(12)

                        // Extracted pages
                        ForEach(pagesWithText, id: \.page) { page, text in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Page \(page + 1)")
                                        .font(.custom("Georgia-Bold", size: 13))
                                        .foregroundColor(.plumeTextSecondary)

                                    Spacer()

                                    Text("\(text.count) chars")
                                        .font(.system(size: 11))
                                        .foregroundColor(.plumeTextSecondary)
                                }

                                Text(text)
                                    .font(.custom("Georgia-Italic", size: 13))
                                    .foregroundColor(.plumeTextPrimary)
                                    .lineLimit(6)
                            }
                            .padding(12)
                            .background(Color.plumeSurface)
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }

                // Bottom bar
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Divider()
                        Button {
                            onSave()
                        } label: {
                            Text("Save \(pagesWithText.count) Quote\(pagesWithText.count == 1 ? "" : "s")")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.plumeAccent)
                                .cornerRadius(12)
                        }
                        .padding(16)
                        .background(Color.plumeSurface)
                    }
                }
            }
            .navigationTitle("Save Extracted Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
        }
    }
}

#Preview {
    PDFImportView()
}
