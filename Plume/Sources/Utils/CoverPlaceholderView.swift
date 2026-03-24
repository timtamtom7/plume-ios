import SwiftUI

struct CoverPlaceholderView: View {
    let book: Book
    let size: CGSize

    var body: some View {
        ZStack {
            Rectangle()
                .fill(book.placeholderColor)

            VStack(spacing: 8) {
                Text(book.title)
                    .font(.custom("Georgia-Bold", size: fontSize(for: size.height, title: true)))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 8)

                Text(book.author)
                    .font(.custom("Georgia", size: fontSize(for: size.height, title: false)))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func fontSize(for height: CGFloat, title: Bool) -> CGFloat {
        let scale = height / 200.0
        if title {
            return max(12, min(18, 14 * scale))
        } else {
            return max(10, min(14, 11 * scale))
        }
    }
}

struct CoverImageView: View {
    let book: Book
    let size: CGSize

    var body: some View {
        Group {
            if let path = book.coverImagePath,
               let image = ImageStorage.shared.loadCoverImage(atPath: path) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipped()
            } else {
                CoverPlaceholderView(book: book, size: size)
            }
        }
        .frame(width: size.width, height: size.height)
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let book = Book(
        id: 1,
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        totalPages: 180,
        currentPage: 142,
        coverImagePath: nil,
        placeholderColorHex: "#8b4513",
        startDate: Date(),
        finishDate: nil,
        isFinished: false
    )
    return VStack {
        CoverPlaceholderView(book: book, size: CGSize(width: 120, height: 180))
        CoverPlaceholderView(book: book, size: CGSize(width: 60, height: 90))
    }
    .padding()
    .background(Color.plumeBackground)
}
