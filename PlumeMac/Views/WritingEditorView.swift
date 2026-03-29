import SwiftUI

struct WritingEditorView: View {
    @Environment(\.appTheme) var theme
    @ObservedObject var data: WritingData
    @Binding var isPresented: Bool
    let prompt: WritingPrompt?
    @State private var text: String = ""
    @State private var sessionTimer: Timer?
    @State private var elapsedSeconds: Int = 0
    @State private var autoSaveTimer: Timer?
    @State private var showingTimer: Bool = true

    private var wordCount: Int {
        text.split { $0.isWhitespace || $0.isNewline }.count
    }

    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            promptBanner
            writingArea
            footerBar
        }
        .background(theme.surface)
        .onAppear {
            data.startSession()
            startTimers()
        }
        .onDisappear {
            stopTimers()
            data.endSession()
        }
    }

    private var headerBar: some View {
        HStack {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.inkBlue.opacity(0.5))
                    .frame(width: 28, height: 28)
                    .background(theme.parchment)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            if showingTimer {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(theme.inkBlue.opacity(0.4))
                    Text(formattedTime)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.inkBlue.opacity(0.6))
                }
            }

            Spacer()

            Button(action: { showingTimer.toggle() }) {
                Image(systemName: showingTimer ? "clock.fill" : "clock")
                    .font(.system(size: 12))
                    .foregroundColor(theme.inkBlue.opacity(0.5))
                    .frame(width: 28, height: 28)
                    .background(theme.parchment)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var promptBanner: some View {
        Group {
            if let prompt = prompt {
                HStack(spacing: 8) {
                    Image(systemName: "feather.pointed")
                        .font(.system(size: 11))
                        .foregroundColor(theme.featherGold)
                    Text(prompt.text)
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundColor(theme.inkBlue.opacity(0.7))
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(theme.parchment.opacity(0.5))
            }
        }
    }

    private var writingArea: some View {
        TextEditor(text: $text)
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundColor(theme.inkBlue)
            .scrollContentBackground(.hidden)
            .background(theme.surface)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .onChange(of: text) { _, newValue in
                data.currentSessionWords = wordCount
            }
    }

    private var footerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(wordCount) words")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.inkBlue)
                Text("Auto-saving")
                    .font(.system(size: 11))
                    .foregroundColor(theme.inkBlue.opacity(0.4))
            }

            Spacer()

            goalProgress
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(theme.cardBg)
    }

    private var goalProgress: some View {
        HStack(spacing: 8) {
            Text("\(wordCount)/\(data.dailyGoal)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.inkBlue.opacity(0.6))

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.parchment)
                        .frame(width: geometry.size.width, height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.featherGold)
                        .frame(width: min(CGFloat(wordCount) / CGFloat(data.dailyGoal) * geometry.size.width, geometry.size.width), height: 6)
                }
            }
            .frame(width: 80, height: 6)
        }
    }

    private func startTimers() {
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
        }
    }

    private func stopTimers() {
        sessionTimer?.invalidate()
        autoSaveTimer?.invalidate()
    }
}
