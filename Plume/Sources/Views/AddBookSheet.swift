import SwiftUI
import AVFoundation

struct AddBookSheet: View {
    @EnvironmentObject var bookStore: BookStore
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var totalPages = ""
    @State private var startPage = "1"
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var capturedImagePath: String?
    @State private var step: AddBookStep = .details
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingCameraPermissionDenied = false

    enum AddBookStep {
        case details
        case camera
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Step indicator
                    HStack(spacing: 8) {
                        StepDot(active: step == .details, label: "Details")
                        Rectangle()
                            .fill(step == .camera ? Color.plumeAccent : Color.plumeTextSecondary.opacity(0.3))
                            .frame(width: 40, height: 2)
                        StepDot(active: step == .camera, label: "Cover")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    if step == .details {
                        detailsForm
                    } else {
                        cameraSection
                    }
                }
            }
            .navigationTitle(step == .details ? "New Book" : "Capture Cover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(capturedImage: $capturedImage)
            }
            .onChange(of: capturedImage) { _, newImage in
                if newImage != nil {
                    capturedImagePath = saveImageTemporary(newImage!)
                    step = .camera
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingCameraPermissionDenied) {
                CameraPermissionDeniedView()
            }
        }
    }

    @ViewBuilder
    private var detailsForm: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Cover preview
                VStack(spacing: 8) {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(height: 160)
                            .cornerRadius(6)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.plumeTextSecondary.opacity(0.1))
                                .frame(width: 107, height: 160)
                            VStack(spacing: 4) {
                                Image(systemName: "camera")
                                    .font(.system(size: 24))
                                    .foregroundColor(.plumeTextSecondary)
                                Text("Cover photo")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                    }

                    Button("Add Cover Photo") {
                        checkCameraPermissionAndOpen()
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.plumeAccent)
                }

                VStack(spacing: 16) {
                    FormField(title: "Book Title", text: $title, placeholder: "The Great Gatsby")
                    FormField(title: "Author", text: $author, placeholder: "F. Scott Fitzgerald")
                    FormField(title: "Total Pages", text: $totalPages, placeholder: "180", keyboard: .numberPad)
                    FormField(title: "Starting Page", text: $startPage, placeholder: "1", keyboard: .numberPad)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 32)

                Button {
                    if validateDetails() {
                        step = .camera
                    }
                } label: {
                    Text("Next")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(title.isEmpty ? Color.plumeTextSecondary : Color.plumeAccent)
                        .cornerRadius(10)
                }
                .disabled(title.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private func checkCameraPermissionAndOpen() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    } else {
                        showingCameraPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            showingCameraPermissionDenied = true
        @unknown default:
            showingCameraPermissionDenied = true
        }
    }

    @ViewBuilder
    private var cameraSection: some View {
        VStack(spacing: 24) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .frame(height: 220)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }

            // Book info summary
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom("Georgia-Bold", size: 17))
                    .foregroundColor(.plumeTextPrimary)
                Text(author)
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(.plumeTextSecondary)
                Text("\(totalPages) pages")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.plumeTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    checkCameraPermissionAndOpen()
                } label: {
                    HStack {
                        Image(systemName: "camera")
                        Text("Retake")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.plumeAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.plumeAccent.opacity(0.1))
                    .cornerRadius(10)
                }

                Button {
                    saveBook()
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save Book")
                    }
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

    private func validateDetails() -> Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a book title."
            showingError = true
            return false
        }
        guard !totalPages.isEmpty, let pages = Int(totalPages), pages > 0 else {
            errorMessage = "Please enter a valid number of pages."
            showingError = true
            return false
        }

        // Check book limit
        if !subscriptionManager.canAddBook(currentBookCount: bookStore.allBooks.count) {
            errorMessage = "You've reached your book limit. Upgrade to Reader for unlimited books."
            showingError = true
            return false
        }

        return true
    }

    private func saveImageTemporary(_ image: UIImage) -> String? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "cover_temp_\(UUID().uuidString).jpg"
        let fileURL = tempDir.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            return nil
        }
    }

    private func saveBook() {
        let pages = Int(totalPages) ?? 0
        let start = Int(startPage) ?? 1

        var coverPath: String? = capturedImagePath

        if let book = bookStore.addBook(title: title, author: author, totalPages: pages, coverPath: coverPath, startPage: start) {
            // Save the cover image with the actual book ID
            if let img = capturedImage {
                if let savedPath = ImageStorage.shared.saveCoverImage(img, forBookId: book.id) {
                    // Cover saved successfully - in a full implementation we'd update the book record
                    _ = savedPath
                }
            }
        }

        dismiss()
    }
}

struct StepDot: View {
    let active: Bool
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(active ? Color.plumeAccent : Color.plumeTextSecondary.opacity(0.3))
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(active ? .plumeAccent : .plumeTextSecondary)
        }
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.plumeTextSecondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .keyboardType(keyboard)
                .padding(12)
                .background(Color.plumeSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.plumeTextSecondary.opacity(0.15), lineWidth: 1)
                )
        }
    }
}

#Preview {
    AddBookSheet()
        .environmentObject(BookStore())
        .environmentObject(SubscriptionManager.shared)
}
