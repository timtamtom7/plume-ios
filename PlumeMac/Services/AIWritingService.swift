import Foundation
import NaturalLanguage

// MARK: - Writer Profile

struct WriterProfile: Codable {
    var preferredGenres: [PromptCategory]
    var promptsUsed: [String]
    var averageSessionLength: TimeInterval
    var preferredTimeOfDay: TimeOfDay
    var currentStreak: Int
    var lastSessionDate: Date?
    var totalWordsWritten: Int
    var writingDaysHistory: [Date]

    enum TimeOfDay: String, Codable {
        case morning, afternoon, evening, night
    }

    init() {
        self.preferredGenres = [.journal, .reflection]
        self.promptsUsed = []
        self.averageSessionLength = 1800
        self.preferredTimeOfDay = .morning
        self.currentStreak = 0
        self.lastSessionDate = nil
        self.totalWordsWritten = 0
        self.writingDaysHistory = []
    }

    static func currentTimeOfDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<21: return .evening
        default: return .night
        }
    }
}

// MARK: - Difficulty

enum Difficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var description: String {
        switch self {
        case .beginner: return "Start with something simple and personal"
        case .intermediate: return "Push yourself with a new perspective"
        case .advanced: return "Challenge yourself with something complex"
        }
    }
}

// MARK: - AI Writing Prompt

struct AIWritingPrompt: Identifiable {
    let id = UUID()
    let text: String
    let category: PromptCategory
    let difficulty: Difficulty
    let inspiration: String
}

// MARK: - AI Writing Service

@MainActor
final class AIWritingService {
    static let shared = AIWritingService()

    private let userDefaultsKey = "writerProfile"
    private var profile: WriterProfile

    private init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(WriterProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = WriterProfile()
        }
    }

    // MARK: - Prompt Generation

    func generatePrompt(for writer: WriterProfile? = nil) -> AIWritingPrompt {
        let effectiveProfile = writer ?? profile
        updateProfile(with: effectiveProfile)

        let category = selectCategory(for: effectiveProfile)
        let difficulty = selectDifficulty(for: effectiveProfile)
        let prompt = selectPrompt(category: category, difficulty: difficulty, usedPrompts: effectiveProfile.promptsUsed)
        let inspiration = generateInspiration(for: prompt, profile: effectiveProfile)

        return AIWritingPrompt(
            text: prompt,
            category: category,
            difficulty: difficulty,
            inspiration: inspiration
        )
    }

    private func selectCategory(for profile: WriterProfile) -> PromptCategory {
        if let lastSession = profile.lastSessionDate {
            let daysSinceLastSession = Calendar.current.dateComponents([.day], from: lastSession, to: Date()).day ?? 0
            if daysSinceLastSession > 7 {
                return .journal
            }
        }

        if profile.currentStreak > 5 {
            return profile.preferredGenres.randomElement() ?? .reflection
        }

        return profile.preferredGenres.randomElement() ?? .creative
    }

    private func selectDifficulty(for profile: WriterProfile) -> Difficulty {
        let totalWords = profile.totalWordsWritten

        if totalWords < 5000 {
            return .beginner
        } else if totalWords < 25000 {
            return .intermediate
        } else {
            return .advanced
        }
    }

    private func selectPrompt(category: PromptCategory, difficulty: Difficulty, usedPrompts: [String]) -> String {
        let seasonalPrompts = getSeasonalPrompts()
        let availablePrompts = WritingData.prompts(for: category) + seasonalPrompts.filter { $0.category == category }

        let unusedPrompts = availablePrompts.filter { !usedPrompts.contains($0.text) }
        let pool = unusedPrompts.isEmpty ? availablePrompts : unusedPrompts

        return pool.randomElement()?.text ?? "What's on your mind today?"
    }

    private func getSeasonalPrompts() -> [WritingPrompt] {
        let month = Calendar.current.component(.month, from: Date())

        switch month {
        case 3...5:
            return [
                WritingPrompt(text: "Spring represents renewal. What are you ready to let grow?", category: .reflection),
                WritingPrompt(text: "A garden that wasn't there yesterday...", category: .fiction)
            ]
        case 6...8:
            return [
                WritingPrompt(text: "The longest day of the year, and you find yourself...", category: .creative),
                WritingPrompt(text: "Summer memories: capture one before it fades.", category: .journal)
            ]
        case 9...11:
            return [
                WritingPrompt(text: "The seasons are changing. What else is ready to transform?", category: .reflection),
                WritingPrompt(text: "Leaves crunched beneath your feet as you realized...", category: .fiction)
            ]
        default:
            return [
                WritingPrompt(text: "The quiet of winter invites introspection. What do you find there?", category: .journal),
                WritingPrompt(text: "Snow fell, and with it, a realization...", category: .creative)
            ]
        }
    }

    private func generateInspiration(for prompt: String, profile: WriterProfile) -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        if profile.currentStreak > 0 {
            return "🔥 \(profile.currentStreak)-day streak! Keep the momentum going."
        }

        if hour < 9 {
            return "🌅 Fresh morning, fresh words. Your best writing might be waiting."
        } else if hour < 12 {
            return "☀️ Morning focus time. Your mind is sharpest now."
        } else if hour < 17 {
            return "🌤️ Afternoon session. A great time to reflect and create."
        } else {
            return "🌙 Evening reflections. Wind down with some journaling."
        }
    }

    // MARK: - Profile Management

    func updateProfile(with newProfile: WriterProfile) {
        var updatedProfile = newProfile
        updatedProfile.preferredTimeOfDay = WriterProfile.currentTimeOfDay()
        self.profile = updatedProfile

        if let encoded = try? JSONEncoder().encode(updatedProfile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    func recordPromptUsage(_ promptText: String) {
        if !profile.promptsUsed.contains(promptText) {
            profile.promptsUsed.append(promptText)
        }
        profile.lastSessionDate = Date()
        updateProfile(with: profile)
    }

    func recordSession(wordCount: Int, duration: TimeInterval) {
        profile.totalWordsWritten += wordCount
        profile.writingDaysHistory.append(Date())

        if let lastDate = profile.lastSessionDate {
            let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if daysSince == 1 {
                profile.currentStreak += 1
            } else if daysSince > 1 {
                profile.currentStreak = 1
            }
        } else {
            profile.currentStreak = 1
        }

        updateProfile(with: profile)
    }

    func getProfile() -> WriterProfile {
        return profile
    }
}
