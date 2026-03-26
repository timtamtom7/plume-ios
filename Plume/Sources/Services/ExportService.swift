import Foundation
import SwiftUI
import PDFKit

// MARK: - Citation Style
enum CitationStyle: String, CaseIterable, Identifiable {
    case apa = "APA"
    case mla = "MLA"
    case chicago = "Chicago"
    case plain = "Plain Text"

    var id: String { rawValue }

    func format(bookTitle: String, author: String, quote: String, pageNumber: Int? = nil) -> String {
        switch self {
        case .apa:
            let lastName = author.split(separator: " ").last.map(String.init) ?? author
            var citation = "\(lastName). (\(bookTitle))."
            if let page = pageNumber {
                citation += " (p. \(page))."
            }
            return citation

        case .mla:
            var citation = "\"\(quote)\" \(bookTitle) by \(author)."
            if let page = pageNumber {
                citation += " \(page)."
            }
            return citation

        case .chicago:
            var citation = "\(author), \(bookTitle)."
            if let page = pageNumber {
                citation += " \(page)."
            }
            return citation

        case .plain:
            var citation = "\"\(quote)\"\n— \(author), \(bookTitle)"
            if let page = pageNumber {
                citation += ", p. \(page)"
            }
            return citation
        }
    }
}

// MARK: - Export Quote
struct ExportQuote: Identifiable {
    let id = UUID()
    let text: String
    let bookTitle: String
    let author: String
    let pageNumber: Int?
    let dateAdded: Date
}

// MARK: - Export Service
final class ExportService: ObservableObject {
    @Published var isExporting = false
    @Published var exportError: String?

    // MARK: - PDF Export
    func exportQuotesToPDF(quotes: [ExportQuote], title: String, citationStyle: CitationStyle) -> URL? {
        isExporting = true
        defer { isExporting = false }

        let pageWidth: CGFloat = 612 // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 72

        let pdfMetaData = [
            kCGPDFContextCreator: "Plume",
            kCGPDFContextAuthor: "Plume App",
            kCGPDFContextTitle: title
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            var currentY: CGFloat = margin
            let contentWidth = pageWidth - (margin * 2)

            // Title Page
            context.beginPage()
            currentY = pageHeight / 3

            let titleFont = UIFont(name: "Georgia-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            let titleString = title as NSString
            let titleSize = titleString.size(withAttributes: titleAttributes)
            titleString.draw(
                at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: currentY),
                withAttributes: titleAttributes
            )

            currentY += titleSize.height + 20

            let subtitleFont = UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16)
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: UIColor.darkGray
            ]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let subtitleString = "Exported from Plume on \(dateFormatter.string(from: Date()))" as NSString
            let subtitleSize = subtitleString.size(withAttributes: subtitleAttributes)
            subtitleString.draw(
                at: CGPoint(x: (pageWidth - subtitleSize.width) / 2, y: currentY),
                withAttributes: subtitleAttributes
            )

            currentY += subtitleSize.height + 10

            let countString = "\(quotes.count) quotes" as NSString
            let countSize = countString.size(withAttributes: subtitleAttributes)
            countString.draw(
                at: CGPoint(x: (pageWidth - countSize.width) / 2, y: currentY),
                withAttributes: subtitleAttributes
            )

            // Table of Contents
            currentY = pageHeight / 2 + 50
            let tocTitleFont = UIFont(name: "Georgia-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
            let tocAttributes: [NSAttributedString.Key: Any] = [
                .font: tocTitleFont,
                .foregroundColor: UIColor.black
            ]
            "Quotes".draw(at: CGPoint(x: margin, y: currentY), withAttributes: tocAttributes)
            currentY += 25

            let tocFont = UIFont(name: "Georgia", size: 11) ?? UIFont.systemFont(ofSize: 11)
            let tocTextAttributes: [NSAttributedString.Key: Any] = [
                .font: tocFont,
                .foregroundColor: UIColor.darkGray
            ]

            for (index, quote) in quotes.enumerated() {
                let tocEntry = "\(index + 1). \(quote.bookTitle)" as NSString
                tocEntry.draw(at: CGPoint(x: margin, y: currentY), withAttributes: tocTextAttributes)
                currentY += 16
            }

            // Quote Pages
            for quote in quotes {
                // Check if we need a new page
                if currentY > pageHeight - (margin * 2) - 100 {
                    context.beginPage()
                    currentY = margin
                } else {
                    context.beginPage()
                    currentY = margin
                }

                let quoteFont = UIFont(name: "Georgia-Italic", size: 12) ?? UIFont.italicSystemFont(ofSize: 12)
                let quoteAttributes: [NSAttributedString.Key: Any] = [
                    .font: quoteFont,
                    .foregroundColor: UIColor.black
                ]

                // Quote mark
                let quoteMark = "\u{201C}" as NSString
                quoteMark.draw(at: CGPoint(x: margin, y: currentY), withAttributes: quoteAttributes)
                currentY += 20

                // Quote text
                let quoteText = "\"\(quote.text)\"" as NSString
                let quoteRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 200)
                quoteText.draw(in: quoteRect, withAttributes: quoteAttributes)
                currentY += 45

                // Citation
                let citationFont = UIFont(name: "Georgia", size: 10) ?? UIFont.systemFont(ofSize: 10)
                let citationAttributes: [NSAttributedString.Key: Any] = [
                    .font: citationFont,
                    .foregroundColor: UIColor.gray
                ]

                let citation = citationStyle.format(
                    bookTitle: quote.bookTitle,
                    author: quote.author,
                    quote: quote.text,
                    pageNumber: quote.pageNumber
                )
                let citationText = "— \(citation)" as NSString
                citationText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: citationAttributes)
                currentY += 20

                // Separator
                let separator = "─" as NSString
                let separatorRect = CGRect(x: margin, y: currentY, width: 100, height: 1)
                separator.draw(in: separatorRect, withAttributes: citationAttributes)
                currentY += 30
            }
        }

        // Save to file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        let fileName = title.replacingOccurrences(of: " ", with: "_") + "_quotes.pdf"
        let fileURL = documentsPath.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            exportError = "Failed to save PDF: \(error.localizedDescription)"
            return nil
        }
    }

    // MARK: - Readwise Export
    func exportToReadwise(apiKey: String, quotes: [ExportQuote], completion: @escaping (Result<Int, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(ExportError.invalidAPIKey))
            return
        }

        isExporting = true

        // Readwise API endpoint
        guard let url = URL(string: "https://readwise.io/api/v2/highlights/") else {
            completion(.failure(ExportError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let readwiseHighlights = quotes.map { quote -> [String: Any] in
            [
                "text": quote.text,
                "title": quote.bookTitle,
                "author": quote.author,
                "source": "Plume",
                "location_type": quote.pageNumber != nil ? "page" : "chapter",
                "location": quote.pageNumber ?? 1,
                "highlighted_at": ISO8601DateFormatter().string(from: quote.dateAdded)
            ]
        }

        let payload: [String: Any] = ["highlights": readwiseHighlights]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            isExporting = false
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isExporting = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(ExportError.invalidResponse))
                    return
                }

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(.success(quotes.count))
                } else {
                    completion(.failure(ExportError.serverError(statusCode: httpResponse.statusCode)))
                }
            }
        }.resume()
    }

    // MARK: - Notion Export
    func exportToNotion(apiKey: String, databaseId: String, quotes: [ExportQuote], completion: @escaping (Result<Int, Error>) -> Void) {
        guard !apiKey.isEmpty, !databaseId.isEmpty else {
            completion(.failure(ExportError.invalidAPIKey))
            return
        }

        isExporting = true

        // Notion API endpoint
        guard let url = URL(string: "https://api.notion.com/v1/pages") else {
            completion(.failure(ExportError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let group = DispatchGroup()
        var successCount = 0
        var lastError: Error?

        for quote in quotes {
            let payload: [String: Any] = [
                "parent": ["database_id": databaseId],
                "properties": [
                    "Quote": ["title": [["text": ["content": quote.text]]]],
                    "Book": ["rich_text": [["text": ["content": quote.bookTitle]]]],
                    "Author": ["rich_text": [["text": ["content": quote.author]]]],
                ]
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            } catch {
                lastError = error
                continue
            }

            group.enter()
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    lastError = error
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    successCount += 1
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .main) {
            self.isExporting = false
            if successCount > 0 {
                completion(.success(successCount))
            } else if let error = lastError {
                completion(.failure(error))
            } else {
                completion(.failure(ExportError.exportFailed))
            }
        }
    }

    // MARK: - Obsidian Export
    func exportToObsidian(quotes: [ExportQuote], citationStyle: CitationStyle) -> URL? {
        isExporting = true
        defer { isExporting = false }

        var markdown = "# My Quotes\n\n"
        markdown += "_Exported from Plume on \(Date().formatted(date: .long, time: .omitted))_\n\n"

        // Group by book
        let groupedQuotes = Dictionary(grouping: quotes) { $0.bookTitle }

        for (bookTitle, bookQuotes) in groupedQuotes.sorted(by: { $0.key < $1.key }) {
            markdown += "## \(bookTitle)\n\n"

            if let firstQuote = bookQuotes.first {
                markdown += "_by \(firstQuote.author)_\n\n"
            }

            for quote in bookQuotes {
                markdown += "> \(quote.text)\n\n"
                markdown += "— Citation: `\(citationStyle.format(bookTitle: bookTitle, author: quote.author, quote: quote.text, pageNumber: quote.pageNumber))`\n\n"
                markdown += "---\n\n"
            }
        }

        // Save to file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        let fileName = "Plume_Quotes_\(Date().ISO8601Format()).md"
        let fileURL = documentsPath.appendingPathComponent(fileName)

        do {
            try markdown.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            exportError = "Failed to save markdown: \(error.localizedDescription)"
            return nil
        }
    }

    // MARK: - Copy Citations
    func copyCitations(for quotes: [ExportQuote], style: CitationStyle) -> String {
        quotes.map { quote in
            style.format(
                bookTitle: quote.bookTitle,
                author: quote.author,
                quote: quote.text,
                pageNumber: quote.pageNumber
            )
        }.joined(separator: "\n\n")
    }
}

// MARK: - Export Error
enum ExportError: LocalizedError {
    case invalidAPIKey
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your credentials."
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .invalidResponse:
            return "Invalid response from server."
        case .serverError(let statusCode):
            return "Server error (code: \(statusCode)). Please try again later."
        case .exportFailed:
            return "Export failed. Please try again."
        }
    }
}
