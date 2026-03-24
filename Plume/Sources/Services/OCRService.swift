import Foundation
import Vision
import UIKit

// MARK: - OCR Service
final class OCRService: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isProcessing: Bool = false
    @Published var error: String?

    // MARK: - Recognize Text from Image
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        isProcessing = true
        error = nil

        guard let cgImage = image.cgImage else {
            isProcessing = false
            completion(.failure(OCRError.invalidImage))
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isProcessing = false

                if let error = error {
                    self?.error = error.localizedDescription
                    completion(.failure(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion(.failure(OCRError.noTextFound))
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                let fullText = recognizedStrings.joined(separator: "\n")
                self?.recognizedText = fullText
                completion(.success(fullText))
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.error = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Find Text Regions (for quote extraction)
    func findTextRegions(in image: UIImage, completion: @escaping ([CGRect]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }

            let regions = observations.map { observation -> CGRect in
                return observation.boundingBox
            }

            DispatchQueue.main.async {
                completion(regions)
            }
        }

        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

// MARK: - Multi-Page Scan Session
final class MultiPageScanSession: ObservableObject {
    @Published var capturedPages: [CapturedPage] = []
    @Published var currentBookTitle: String = ""
    @Published var currentBookAuthor: String = ""
    @Published var isProcessing: Bool = false

    struct CapturedPage: Identifiable {
        let id = UUID()
        let image: UIImage
        var recognizedText: String
        var selectedQuote: String?
        var pageNumber: Int?

        init(image: UIImage, recognizedText: String = "", selectedQuote: String? = nil, pageNumber: Int? = nil) {
            self.image = image
            self.recognizedText = recognizedText
            self.selectedQuote = selectedQuote
            self.pageNumber = pageNumber
        }
    }

    var pageCount: Int { capturedPages.count }

    func addPage(_ image: UIImage) {
        let page = CapturedPage(image: image)
        capturedPages.append(page)
    }

    func removePage(at index: Int) {
        guard index < capturedPages.count else { return }
        capturedPages.remove(at: index)
    }

    func clear() {
        capturedPages.removeAll()
        currentBookTitle = ""
        currentBookAuthor = ""
    }
}

// MARK: - OCR Error
enum OCRError: LocalizedError {
    case invalidImage
    case noTextFound
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the image."
        case .noTextFound:
            return "No text was found in the image."
        case .processingFailed:
            return "Text recognition failed."
        }
    }
}
