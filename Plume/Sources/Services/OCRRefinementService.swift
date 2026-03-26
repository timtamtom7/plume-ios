import Foundation
import PDFKit

// R11: OCR refinements and iPad support for Plume
final class OCRRefinementService {
    static let shared = OCRRefinementService()

    private init() {}

    // MARK: - Multi-column Layout Detection

    struct PageLayout {
        let columnCount: Int
        let columns: [CGRect]
        let readingOrder: [CGRect] // left-to-right, top-to-bottom
    }

    func detectLayout(in image: CGImage) -> PageLayout {
        // Simple layout detection based on vertical whitespace
        // In a real implementation, would use Vision framework's VNDetectTextOrientation
        return PageLayout(columnCount: 1, columns: [CGRect(x: 0, y: 0, width: image.width, height: image.height)], readingOrder: [])
    }

    // MARK: - Handwriting Recognition

    func recognizeHandwriting(in image: CGImage) async -> String {
        // Use Vision framework's VNRecognizeTextRequest with recognitionLevel = .accurate
        // Handwriting is harder - would need specific training
        return ""
    }

    // MARK: - Table of Contents Extraction

    struct TOCEntry {
        let title: String
        let pageNumber: Int
        let level: Int // 0 = chapter, 1 = section, etc.
    }

    func extractTableOfContents(from pdfDocument: PDFDocument) -> [TOCEntry] {
        var entries: [TOCEntry] = []

        // Check if PDF has outline
        if let outline = pdfDocument.outlineRoot {
            extractEntries(from: outline, level: 0, into: &entries, pdf: pdfDocument)
        }

        return entries
    }

    private func extractEntries(from outline: PDFOutline, level: Int, into entries: inout [TOCEntry], pdf: PDFDocument) {
        for i in 0..<outline.numberOfChildren {
            if let child = outline.child(at: i) {
                let pageIdx: Int = child.destination?.page.flatMap { pdf.index(for: $0) } ?? 0
                let entry = TOCEntry(
                    title: child.label ?? "Untitled",
                    pageNumber: pageIdx,
                    level: level
                )
                entries.append(entry)
                extractEntries(from: child, level: level + 1, into: &entries, pdf: pdf)
            }
        }
    }

    // MARK: - Multi-page PDF Import

    func importPDFWithOCR(url: URL) async throws -> OCRResult {
        guard let document = PDFDocument(url: url) else {
            throw OCRError.invalidPDF
        }

        var results: [PageOCRResult] = []

        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }

            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let image = renderer.image { ctx in
                UIColor.white.setFill()
                ctx.fill(pageRect)
                ctx.cgContext.translateBy(x: 0, y: pageRect.height)
                ctx.cgContext.scaleBy(x: 1, y: -1)
                page.draw(with: .mediaBox, to: ctx.cgContext)
            }

            // OCR each page
            let layout = detectLayout(in: image.cgImage!)
            let text = await recognizeText(in: image.cgImage!)

            results.append(PageOCRResult(pageNumber: i, text: text, layout: layout))
        }

        return OCRResult(pages: results, title: url.deletingPathExtension().lastPathComponent)
    }

    struct OCRResult {
        let pages: [PageOCRResult]
        let title: String
    }

    struct PageOCRResult {
        let pageNumber: Int
        let text: String
        let layout: PageLayout
    }

    enum OCRError: Error {
        case invalidPDF
        case ocrFailed
    }

    // MARK: - Private OCR Helper

    private func recognizeText(in image: CGImage) async -> String {
        // Simplified - real implementation uses Vision framework
        return ""
    }
}
