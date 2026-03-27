import SwiftUI
import AVFoundation

struct MultiPageScanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanSession = MultiPageScanSession()
    @StateObject private var ocrService = OCRService()
    @State private var showingCamera = false
    @State private var showingReview = false
    @State private var processedPages: [MultiPageScanSession.CapturedPage] = []
    @State private var bookTitle = ""
    @State private var bookAuthor = ""
    @State private var currentStep: ScanStep = .bookInfo

    enum ScanStep {
        case bookInfo
        case scanning
        case review
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Step indicator
                    HStack(spacing: 8) {
                        StepIndicator(title: "Book Info", active: currentStep == .bookInfo)
                        Rectangle().fill(stepColor(1)).frame(width: 40, height: 2)
                        StepIndicator(title: "Scan", active: currentStep == .scanning)
                        Rectangle().fill(stepColor(2)).frame(width: 40, height: 2)
                        StepIndicator(title: "Review", active: currentStep == .review)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    switch currentStep {
                    case .bookInfo:
                        bookInfoForm
                    case .scanning:
                        scanningView
                    case .review:
                        reviewView
                    }
                }
            }
            .navigationTitle("Multi-Page Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        scanSession.clear()
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                MultiPageCameraView(scanSession: scanSession) {
                    currentStep = .review
                    processedPages = scanSession.capturedPages
                }
            }
        }
    }

    private func stepColor(_ step: Int) -> Color {
        let currentIndex: Int = {
            switch currentStep {
            case .bookInfo: return 0
            case .scanning: return 1
            case .review: return 2
            }
        }()
        return step <= currentIndex ? Color.plumeAccent : Color.plumeTextSecondary.opacity(0.3)
    }

    @ViewBuilder
    private var bookInfoForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Link Pages to a Book")
                        .font(.custom("Georgia-Bold", size: 20))
                        .foregroundColor(.plumeTextPrimary)

                    Text("Enter the book details, then scan pages. You can scan multiple pages and link them all to this book.")
                        .font(.system(size: 14))
                        .foregroundColor(.plumeTextSecondary)
                }
                .padding(.horizontal, 16)

                VStack(spacing: 16) {
                    FormField(title: "Book Title", text: $bookTitle, placeholder: "The Great Gatsby")
                    FormField(title: "Author", text: $bookAuthor, placeholder: "F. Scott Fitzgerald")
                }
                .padding(.horizontal, 16)

                Spacer()

                Button {
                    scanSession.currentBookTitle = bookTitle
                    scanSession.currentBookAuthor = bookAuthor
                    currentStep = .scanning
                } label: {
                    Text("Start Scanning")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(bookTitle.isEmpty ? Color.plumeTextSecondary : Color.plumeAccent)
                        .cornerRadius(10)
                }
                .disabled(bookTitle.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var scanningView: some View {
        VStack(spacing: 24) {
            if scanSession.capturedPages.isEmpty {
                // Empty state - prompt to scan
                VStack(spacing: 20) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.plumeAccent.opacity(0.1))
                            .frame(width: 140, height: 140)

                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 50))
                            .foregroundColor(.plumeAccent)
                    }

                    VStack(spacing: 8) {
                        Text("Scan Book Pages")
                            .font(.custom("Georgia-Bold", size: 18))
                            .foregroundColor(.plumeTextPrimary)

                        Text("Photograph pages from your book to extract quotes and highlights.")
                            .font(.system(size: 14))
                            .foregroundColor(.plumeTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Button {
                        showingCamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Start Camera")
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
            } else {
                // Show captured pages
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Text("\(scanSession.pageCount) page\(scanSession.pageCount == 1 ? "" : "s") scanned")
                                .font(.custom("Georgia-Bold", size: 14))
                                .foregroundColor(.plumeTextPrimary)
                            Spacer()
                            Button {
                                showingCamera = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle")
                                    Text("Add Page")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plumeAccent)
                            }
                        }
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Array(scanSession.capturedPages.enumerated()), id: \.element.id) { index, page in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: page.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 100)
                                        .clipped()
                                        .cornerRadius(6)

                                    Text("\(index + 1)")
                                        .font(Theme.fontCaptionSemibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(Theme.cornerRadiusBadge)
                                        .padding(4)
                                }
                                .onTapGesture {
                                    scanSession.removePage(at: index)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        scanSession.currentBookTitle = bookTitle
                        scanSession.currentBookAuthor = bookAuthor
                        showingCamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera")
                            Text("Scan Another Page")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.plumeAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.plumeAccent.opacity(0.1))
                        .cornerRadius(10)
                    }

                    Button {
                        processedPages = scanSession.capturedPages
                        currentStep = .review
                    } label: {
                        Text("Review & Extract")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.plumeAccent)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private var reviewView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Book info header
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "#8b4513") ?? .brown)
                                .frame(width: 40, height: 60)

                            Image(systemName: "book.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(bookTitle)
                                .font(.custom("Georgia-Bold", size: 15))
                                .foregroundColor(.plumeTextPrimary)

                            Text(bookAuthor)
                                .font(.system(size: 13))
                                .foregroundColor(.plumeTextSecondary)
                        }

                        Spacer()

                        Button {
                            currentStep = .scanning
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.plumeAccent)
                        }
                    }
                    .padding(16)
                    .background(Color.plumeSurface)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)

                    // Pages with extracted text
                    ForEach(Array(processedPages.enumerated()), id: \.element.id) { index, page in
                        ExtractedPageCard(
                            pageNumber: index + 1,
                            image: page.image,
                            recognizedText: page.recognizedText,
                            bookTitle: bookTitle,
                            bookAuthor: bookAuthor,
                            onTextUpdated: { newText in
                                processedPages[index].recognizedText = newText
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
            }

            // Bottom save bar
            VStack(spacing: 0) {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(processedPages.count) pages")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plumeTextPrimary)
                        Text("\(processedPages.filter { !$0.recognizedText.isEmpty }.count) with text")
                            .font(.system(size: 12))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()

                    Button {
                        saveAllPages()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save All")
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

    private func saveAllPages() {
        // In a full implementation, this would save to the database
        // For now, just dismiss
        scanSession.clear()
        dismiss()
    }
}

struct StepIndicator: View {
    let title: String
    let active: Bool

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(active ? Color.plumeAccent : Color.plumeTextSecondary.opacity(0.3))
                .frame(width: 10, height: 10)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(active ? .plumeAccent : .plumeTextSecondary)
        }
    }
}

struct ExtractedPageCard: View {
    let pageNumber: Int
    let image: UIImage
    let recognizedText: String
    let bookTitle: String
    let bookAuthor: String
    let onTextUpdated: (String) -> Void

    @State private var editedText: String = ""
    @State private var showingShareSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Page header
            HStack {
                Text("Page \(pageNumber)")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)

                Spacer()

                if !recognizedText.isEmpty {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                            .foregroundColor(.plumeAccent)
                    }
                }
            }

            // Image thumbnail
            HStack(spacing: 12) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 80)
                    .clipped()
                    .cornerRadius(4)

                VStack(alignment: .leading, spacing: 8) {
                    if recognizedText.isEmpty {
                        Text("No text detected")
                            .font(.system(size: 13))
                            .foregroundColor(.plumeTextSecondary)
                            .italic()
                    } else {
                        Text(recognizedText)
                            .font(.system(size: 13))
                            .foregroundColor(.plumeTextPrimary)
                            .lineLimit(5)
                    }
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .sheet(isPresented: $showingShareSheet) {
            ShareQuoteSheet(
                text: recognizedText,
                bookTitle: bookTitle,
                bookAuthor: bookAuthor,
                pageNumber: pageNumber
            )
        }
        .onAppear {
            editedText = recognizedText
        }
    }
}

struct ShareQuoteSheet: View {
    let text: String
    let bookTitle: String
    let bookAuthor: String
    let pageNumber: Int

    @Environment(\.dismiss) private var dismiss
    @State private var selectedQuote: String = ""
    @State private var makePublic = false
    @State private var shareDestination: ShareDestination = .system

    enum ShareDestination {
        case system
        case community
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Quote preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quote to Share")
                                .font(.custom("Georgia-Bold", size: 13))
                                .foregroundColor(.plumeTextSecondary)
                                .textCase(.uppercase)
                                .tracking(1.2)

                            TextEditor(text: $selectedQuote)
                                .font(.custom("Georgia-Italic", size: 15))
                                .foregroundColor(.plumeTextPrimary)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.plumeSurface)
                                .cornerRadius(8)
                        }

                        // Book info
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: "#8b4513") ?? .brown)
                                    .frame(width: 35, height: 50)

                                Image(systemName: "book.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(bookTitle)
                                    .font(.custom("Georgia-Bold", size: 14))
                                    .foregroundColor(.plumeTextPrimary)

                                Text(bookAuthor)
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)

                                Text("Page \(pageNumber)")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                        .padding(12)
                        .background(Color.plumeSurface)
                        .cornerRadius(8)

                        // Public toggle
                        Toggle(isOn: $makePublic) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Share to Community")
                                    .font(.system(size: 15))
                                    .foregroundColor(.plumeTextPrimary)
                                Text("Others may see this quote in the community feed")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                        .tint(.plumeAccent)
                        .padding(16)
                        .background(Color.plumeSurface)
                        .cornerRadius(12)

                        // Attribution notice
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.plumeAccent)
                            Text("Quote will always include book attribution")
                                .font(.system(size: 12))
                                .foregroundColor(.plumeTextSecondary)
                        }
                    }
                    .padding(16)
                }

                // Bottom bar
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 12) {
                            Button {
                                shareToSystem()
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.plumeAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.plumeAccent.opacity(0.1))
                                .cornerRadius(10)
                            }

                            Button {
                                shareToCommunity()
                            } label: {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("Post")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(makePublic ? Color.plumeAccent : Color.plumeTextSecondary)
                                .cornerRadius(10)
                            }
                            .disabled(!makePublic)
                        }
                        .padding(16)
                        .background(Color.plumeSurface)
                    }
                }
            }
            .navigationTitle("Share Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .onAppear {
                selectedQuote = text
            }
        }
    }

    private func shareToSystem() {
        let citation = "\"\(selectedQuote)\"\n— \(bookAuthor), \(bookTitle), p. \(pageNumber)"
        let activityVC = UIActivityViewController(activityItems: [citation], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        dismiss()
    }

    private func shareToCommunity() {
        // In production, this would post to a backend
        // For now, just show success and dismiss
        dismiss()
    }
}

// MARK: - Multi-Page Camera View
struct MultiPageCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var scanSession: MultiPageScanSession
    @StateObject private var cameraModel = CameraModel()
    @State private var capturedImages: [UIImage] = []

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Text("\(capturedImages.count) captured")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    Button("Done") {
                        for image in capturedImages {
                            scanSession.addPage(image)
                        }
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
                .padding()

                Spacer()

                // Camera preview
                CameraPreviewView(session: cameraModel.session)
                    .ignoresSafeArea()

                Spacer()

                // Capture button
                HStack {
                    // Thumbnail of last capture
                    if let last = capturedImages.last {
                        Image(uiImage: last)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 70)
                            .clipped()
                            .cornerRadius(4)
                    } else {
                        Color.clear.frame(width: 50, height: 70)
                    }

                    Spacer()

                    Button {
                        capturePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 72, height: 72)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .disabled(!cameraModel.isCameraAvailable)

                    Spacer()

                    Color.clear.frame(width: 50, height: 70)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraModel.startSession()
        }
        .onDisappear {
            cameraModel.stopSession()
        }
    }

    private func capturePhoto() {
        cameraModel.capturePhoto { image in
            if let image = image {
                capturedImages.append(image)
            }
        }
    }
}

#Preview {
    MultiPageScanView()
}
