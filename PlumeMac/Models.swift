import Foundation

// MARK: - Writing Entry

struct WritingEntry: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var wordCount: Int { content.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count }
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var promptUsed: String?
    var isPublished: Bool = false
    var publishedTo: [Publication] = []
}

// MARK: - Writing Prompt

struct WritingPrompt: Identifiable {
    let id = UUID()
    let text: String
    let category: PromptCategory
}

enum PromptCategory: String, CaseIterable, Codable {
    case creative = "Creative"
    case journal = "Journal"
    case reflection = "Reflection"
    case fiction = "Fiction"

    var icon: String {
        switch self {
        case .creative: return "paintbrush"
        case .journal: return "book.closed"
        case .reflection: return "sparkles"
        case .fiction: return "character.book.closed"
        }
    }
}

struct WritingSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let wordCount: Int
    let duration: TimeInterval
    let promptUsed: String?

    init(id: UUID = UUID(), date: Date, wordCount: Int, duration: TimeInterval, promptUsed: String?) {
        self.id = id
        self.date = date
        self.wordCount = wordCount
        self.duration = duration
        self.promptUsed = promptUsed
    }
}

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let wordCount: Int
    let sessionsCount: Int
    let totalDuration: TimeInterval
}

class WritingData: ObservableObject {
    @Published var streak: Int = 0
    @Published var todayWordCount: Int = 0
    @Published var dailyGoal: Int = 500
    @Published var currentSessionStart: Date?
    @Published var currentSessionWords: Int = 0
    @Published var isWriting: Bool = false
    @Published var todayPrompt: WritingPrompt?

    static let prompts: [WritingPrompt] = [
        WritingPrompt(text: "Write about a door that leads somewhere unexpected.", category: .creative),
        WritingPrompt(text: "What are three things you're grateful for today?", category: .journal),
        WritingPrompt(text: "Describe a moment when you felt truly alive.", category: .reflection),
        WritingPrompt(text: "A stranger sits next to you on a long train ride...", category: .fiction),
        WritingPrompt(text: "If you could master any skill overnight, what would it be?", category: .reflection),
        WritingPrompt(text: "Write a letter to your younger self.", category: .journal),
        WritingPrompt(text: "The last thing you expected to find in your attic was...", category: .fiction),
        WritingPrompt(text: "Describe your perfect morning routine.", category: .creative),
        WritingPrompt(text: "What would you do if you knew you couldn't fail?", category: .reflection),
        WritingPrompt(text: "Write about a tradition that means something to you.", category: .journal),
        WritingPrompt(text: "The coffee shop was empty when the stranger walked in...", category: .fiction),
        WritingPrompt(text: "What's a small thing that recently made you smile?", category: .creative),
    ]

    static func todaysPrompt() -> WritingPrompt {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return prompts[dayOfYear % prompts.count]
    }

    static func prompts(for category: PromptCategory) -> [WritingPrompt] {
        prompts.filter { $0.category == category }
    }

    func startSession() {
        currentSessionStart = Date()
        currentSessionWords = 0
        isWriting = true
    }

    func endSession() {
        isWriting = false
        if let start = currentSessionStart {
            let duration = Date().timeIntervalSince(start)
            todayWordCount += currentSessionWords
            currentSessionStart = nil
        }
    }
}
