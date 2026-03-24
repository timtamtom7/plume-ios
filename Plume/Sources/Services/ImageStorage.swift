import Foundation
import UIKit

final class ImageStorage {
    static let shared = ImageStorage()

    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var coversDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("Covers", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    func saveCoverImage(_ image: UIImage, forBookId bookId: Int64) -> String? {
        let resized = resizeImage(image, targetWidth: 600)
        guard let data = resized.jpegData(compressionQuality: 0.8) else { return nil }

        let fileName = "cover_\(bookId).jpg"
        let fileURL = coversDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Save cover image error: \(error)")
            return nil
        }
    }

    func loadCoverImage(atPath path: String) -> UIImage? {
        guard fileManager.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }

    func generateThumbnail(from image: UIImage, size: CGFloat = 80) -> UIImage {
        resizeImage(image, targetWidth: size)
    }

    private func resizeImage(_ image: UIImage, targetWidth: CGFloat) -> UIImage {
        let scale = targetWidth / image.size.width
        let newHeight = image.size.height * scale
        let newSize = CGSize(width: targetWidth, height: newHeight)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
