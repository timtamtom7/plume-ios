import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var capturedImage: UIImage?
    @StateObject private var cameraModel = CameraModel()
    @State private var frameRect: CGRect = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Camera preview
            CameraPreviewView(session: cameraModel.session)
                .ignoresSafeArea()

            // Overlay
            VStack {
                Spacer()

                // Book frame guide
                GeometryReader { geo in
                    let frameWidth: CGFloat = geo.size.width * 0.65
                    let frameHeight = frameWidth * 1.5

                    ZStack {
                        // Dark overlay with cutout
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .mask(
                                Rectangle()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .frame(width: frameWidth, height: frameHeight)
                                            .blendMode(.destinationOut)
                                    )
                            )
                            .compositingGroup()

                        // Frame border
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: frameWidth, height: frameHeight)

                        // Corner accents
                        FrameCorners(width: frameWidth, height: frameHeight)
                    }
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .onAppear {
                        frameRect = CGRect(
                            x: (geo.size.width - frameWidth) / 2,
                            y: (geo.size.height - frameHeight) / 2,
                            width: frameWidth,
                            height: frameHeight
                        )
                    }
                }

                Spacer()

                // Instructions
                Text("Align book cover within the frame")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 16)

                // Capture button
                HStack(spacing: 32) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }

                    Button {
                        cameraModel.capturePhoto { image in
                            if let image = image {
                                self.capturedImage = cropToFrame(image)
                                dismiss()
                            }
                        }
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

                    // Placeholder for alignment
                    Color.clear
                        .frame(width: 60, height: 44)
                }
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

    private func cropToFrame(_ image: UIImage) -> UIImage {
        let aspectRatio: CGFloat = 2.0 / 3.0 // book cover ratio
        let imgSize = image.size

        let visibleWidth: CGFloat
        let visibleHeight: CGFloat

        if imgSize.width / imgSize.height > aspectRatio {
            visibleHeight = imgSize.height
            visibleWidth = visibleHeight * aspectRatio
        } else {
            visibleWidth = imgSize.width
            visibleHeight = visibleWidth / aspectRatio
        }

        let x = (imgSize.width - visibleWidth) / 2
        let y = (imgSize.height - visibleHeight) / 2

        let cropRect = CGRect(x: x, y: y, width: visibleWidth, height: visibleHeight)

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

struct FrameCorners: View {
    let width: CGFloat
    let height: CGFloat
    let cornerLength: CGFloat = 24
    let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // Top-left
            CornerShape(corner: .topLeft)
                .stroke(Color.plumeAccentSecondary, lineWidth: lineWidth)
                .frame(width: cornerLength, height: cornerLength)
                .position(x: width / 2 - cornerLength / 2, y: height / 2 - cornerLength / 2)

            // Top-right
            CornerShape(corner: .topRight)
                .stroke(Color.plumeAccentSecondary, lineWidth: lineWidth)
                .frame(width: cornerLength, height: cornerLength)
                .position(x: width / 2 + cornerLength / 2, y: height / 2 - cornerLength / 2)

            // Bottom-left
            CornerShape(corner: .bottomLeft)
                .stroke(Color.plumeAccentSecondary, lineWidth: lineWidth)
                .frame(width: cornerLength, height: cornerLength)
                .position(x: width / 2 - cornerLength / 2, y: height / 2 + cornerLength / 2)

            // Bottom-right
            CornerShape(corner: .bottomRight)
                .stroke(Color.plumeAccentSecondary, lineWidth: lineWidth)
                .frame(width: cornerLength, height: cornerLength)
                .position(x: width / 2 + cornerLength / 2, y: height / 2 + cornerLength / 2)
        }
        .frame(width: width, height: height)
    }
}

struct CornerShape: Shape {
    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    let corner: Corner

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = rect.size.width

        switch corner {
        case .topLeft:
            path.move(to: CGPoint(x: 0, y: r))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: r, y: 0))
        case .topRight:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: r, y: 0))
            path.addLine(to: CGPoint(x: r, y: r))
        case .bottomLeft:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: r))
            path.addLine(to: CGPoint(x: r, y: r))
        case .bottomRight:
            path.move(to: CGPoint(x: 0, y: r))
            path.addLine(to: CGPoint(x: r, y: r))
            path.addLine(to: CGPoint(x: r, y: 0))
        }

        return path
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = UIScreen.main.bounds
        }
    }
}

final class CameraModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?

    var isCameraAvailable: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto

        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            captureCompletion?(nil)
            return
        }
        captureCompletion?(image)
    }
}

#Preview {
    CameraView(capturedImage: .constant(nil))
}
