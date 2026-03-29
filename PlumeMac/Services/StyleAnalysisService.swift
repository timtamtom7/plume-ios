import Foundation
import NaturalLanguage

// MARK: - Writing Style Metrics

struct WritingStyleMetrics: Codable {
    let readabilityScore: Double
    let avgSentenceLength: Double
    let vocabularyDiversity: Double
    let sentiment: Double
    let complexity: Double
    let dominantTone: String
    let sentenceLengthVariance: Double

    static var empty: WritingStyleMetrics {
        WritingStyleMetrics(
            readabilityScore: 0,
            avgSentenceLength: 0,
            vocabularyDiversity: 0,
            sentiment: 0,
            complexity: 0,
            dominantTone: "neutral",
            sentenceLengthVariance: 0
        )
    }
}

// MARK: - Weekly Digest

struct WeeklyDigest: Codable {
    let totalWords: Int
    let totalSessions: Int
    let streakDays: Int
    let topSentiments: [String]
    let improvementAreas: [String]
    let highlight: String
    let averageSessionLength: TimeInterval
    let mostProductiveTime: String
    let generatedAt: Date

    static var empty: WeeklyDigest {
        WeeklyDigest(
            totalWords: 0,
            totalSessions: 0,
            streakDays: 0,
            topSentiments: [],
            improvementAreas: [],
            highlight: "Start writing to see your weekly insights!",
            averageSessionLength: 0,
            mostProductiveTime: "Unknown",
            generatedAt: Date()
        )
    }
}

// MARK: - Session Insights

struct SessionInsight {
    let wordCount: Int
    let duration: TimeInterval
    let wordsPerMinute: Double
    let sentiment: Double
    let isFlowState: Bool
    let flowStateMessage: String
}

// MARK: - Style Analysis Service

@MainActor
final class StyleAnalysisService {
    static let shared = StyleAnalysisService()

    private let userDefaultsKey = "styleHistory"
    private let sessionsKey = "writingSessions"

    private init() {}

    // MARK: - Style Analysis

    func analyzeStyle(of text: String) -> WritingStyleMetrics {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .sentimentScore])
        tagger.string = text

        var totalWords = 0
        var totalSentences = 0
        var uniqueWords = Set<String>()
        var totalSentiment: Double = 0
        var sentimentCount = 0
        var sentenceLengths: [Int] = []

        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

        for word in words {
            uniqueWords.insert(word.lowercased())
            totalWords += 1
        }

        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        totalSentences = max(sentences.count, 1)
        sentenceLengths = sentences.map { $0.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count }

        var sentimentTotal: Double = 0
        var sentimentItems = 0

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                sentimentTotal += score
                sentimentItems += 1
            }
            return true
        }

        if sentimentItems > 0 {
            totalSentiment = sentimentTotal / Double(sentimentItems)
        }

        let avgSentenceLength = totalSentences > 0 ? Double(totalWords) / Double(totalSentences) : 0
        let vocabularyDiversity = totalWords > 0 ? Double(uniqueWords.count) / Double(totalWords) : 0

        let readabilityScore = calculateReadabilityScore(
            avgSentenceLength: avgSentenceLength,
            avgSyllablesPerWord: estimateAvgSyllables(in: text)
        )

        let complexity = calculateComplexity(
            avgSentenceLength: avgSentenceLength,
            vocabularyDiversity: vocabularyDiversity
        )

        let variance = calculateVariance(sentenceLengths)
        let dominantTone = determineDominantTone(sentiment: totalSentiment)

        return WritingStyleMetrics(
            readabilityScore: readabilityScore,
            avgSentenceLength: avgSentenceLength,
            vocabularyDiversity: vocabularyDiversity,
            sentiment: totalSentiment,
            complexity: complexity,
            dominantTone: dominantTone,
            sentenceLengthVariance: variance
        )
    }

    private func calculateReadabilityScore(avgSentenceLength: Double, avgSyllablesPerWord: Double) -> Double {
        let score = 206.835 - (1.015 * avgSentenceLength) - (84.6 * avgSyllablesPerWord)
        return max(0, min(100, score))
    }

    private func estimateAvgSyllables(in text: String) -> Double {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        guard !words.isEmpty else { return 0 }

        var totalSyllables = 0
        for word in words {
            totalSyllables += countSyllables(in: word)
        }

        return Double(totalSyllables) / Double(words.count)
    }

    private func countSyllables(in word: String) -> Int {
        let vowels = CharacterSet(charactersIn: "aeiouAEIOU")
        let cleanWord = word.filter { $0.isLetter }
        guard !cleanWord.isEmpty else { return 0 }

        var count = 0
        var prevWasVowel = false

        for char in cleanWord {
            let isVowel = String(char).rangeOfCharacter(from: vowels) != nil
            if isVowel && !prevWasVowel {
                count += 1
            }
            prevWasVowel = isVowel
        }

        if cleanWord.lowercased().hasSuffix("e") && count > 1 {
            count -= 1
        }

        return max(1, count)
    }

    private func calculateComplexity(avgSentenceLength: Double, vocabularyDiversity: Double) -> Double {
        let sentenceWeight = min(avgSentenceLength / 20.0, 1.0)
        let vocabWeight = vocabularyDiversity
        return (sentenceWeight * 0.4 + vocabWeight * 0.6) * 100
    }

    private func calculateVariance(_ values: [Int]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = Double(values.reduce(0, +)) / Double(values.count)
        let squaredDiffs = values.map { pow(Double($0) - mean, 2) }
        return sqrt(squaredDiffs.reduce(0, +) / Double(values.count))
    }

    private func determineDominantTone(sentiment: Double) -> String {
        switch sentiment {
        case 0.6...1.0: return "positive"
        case 0.2..<0.6: return "optimistic"
        case -0.2..<0.2: return "neutral"
        case -0.6..<(-0.2): return "contemplative"
        default: return "intense"
        }
    }

    // MARK: - Style Description

    func getStyleDescription(for metrics: WritingStyleMetrics) -> String {
        var descriptions: [String] = []

        if metrics.avgSentenceLength < 10 {
            descriptions.append("You write in short, punchy sentences")
        } else if metrics.avgSentenceLength < 18 {
            descriptions.append("Your sentences flow at a comfortable pace")
        } else {
            descriptions.append("You craft elaborate, complex sentences")
        }

        if metrics.vocabularyDiversity > 0.7 {
            descriptions.append("with rich, varied vocabulary")
        } else if metrics.vocabularyDiversity > 0.5 {
            descriptions.append("with moderate vocabulary range")
        } else {
            descriptions.append("using straightforward, accessible language")
        }

        if metrics.sentiment > 0.3 {
            descriptions.append("Your writing carries warmth and optimism")
        } else if metrics.sentiment < -0.3 {
            descriptions.append("Your writing explores deeper, introspective themes")
        } else {
            descriptions.append("Your tone remains balanced and thoughtful")
        }

        return descriptions.joined(separator: ". ") + "."
    }

    // MARK: - Flow State Detection

    func detectFlowState(currentWordCount: Int, duration: TimeInterval, recentPace: Double) -> (isFlow: Bool, message: String) {
        guard duration > 60 else {
            return (false, "")
        }

        let wordsPerMinute = Double(currentWordCount) / (duration / 60.0)

        if wordsPerMinute >= 25 && recentPace > 0.8 {
            let message = "🔥 You're in the zone — \(currentWordCount) words in \(Int(duration / 60)) minutes"
            return (true, message)
        } else if wordsPerMinute >= 20 {
            return (true, "⚡ Finding your rhythm... keep going!")
        } else if wordsPerMinute >= 15 {
            return (false, "💭 Steady pace. Let the words flow naturally.")
        } else if duration > 1800 && wordsPerMinute < 10 {
            return (true, "☕ Consider taking a short break — fresh eyes help.")
        }

        return (false, "")
    }

    func analyzeSession(wordCount: Int, duration: TimeInterval, text: String? = nil) -> SessionInsight {
        let wpm = duration > 0 ? Double(wordCount) / (duration / 60.0) : 0
        let sentiment: Double

        if let text = text {
            sentiment = analyzeStyle(of: text).sentiment
        } else {
            sentiment = 0
        }

        let (isFlow, flowMessage) = detectFlowState(
            currentWordCount: wordCount,
            duration: duration,
            recentPace: min(wpm / 25.0, 1.0)
        )

        return SessionInsight(
            wordCount: wordCount,
            duration: duration,
            wordsPerMinute: wpm,
            sentiment: sentiment,
            isFlowState: isFlow,
            flowStateMessage: flowMessage
        )
    }

    // MARK: - Weekly Digest

    func generateWeeklyDigest(from sessions: [WritingSession]) -> WeeklyDigest {
        guard !sessions.isEmpty else {
            return .empty
        }

        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        let recentSessions = sessions.filter { $0.date >= weekAgo }
        let totalWords = recentSessions.reduce(0) { $0 + $1.wordCount }
        let totalDuration = recentSessions.reduce(0) { $0 + $1.duration }

        let avgSessionLength = recentSessions.isEmpty ? 0 : totalDuration / Double(recentSessions.count)

        var wordCountByHour: [Int: Int] = [:]
        for session in recentSessions {
            let hour = calendar.component(.hour, from: session.date)
            wordCountByHour[hour, default: 0] += session.wordCount
        }

        let mostProductiveHour = wordCountByHour.max(by: { $0.value < $1.value })?.key ?? 12
        let productiveTimeString = formatHour(mostProductiveHour)

        let streakDays = calculateStreak(from: sessions)

        let topSentiments = ["focused", "productive", "reflective"]
        let improvementAreas = detectImprovementAreas(from: recentSessions)

        let highlight = generateHighlight(
            totalWords: totalWords,
            sessions: recentSessions.count,
            avgLength: avgSessionLength
        )

        return WeeklyDigest(
            totalWords: totalWords,
            totalSessions: recentSessions.count,
            streakDays: streakDays,
            topSentiments: topSentiments,
            improvementAreas: improvementAreas,
            highlight: highlight,
            averageSessionLength: avgSessionLength,
            mostProductiveTime: productiveTimeString,
            generatedAt: Date()
        )
    }

    private func formatHour(_ hour: Int) -> String {
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<21: return "Evening"
        default: return "Night"
        }
    }

    private func calculateStreak(from sessions: [WritingSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        let sortedDates = sessions.map { calendar.startOfDay(for: $0.date) }.sorted(by: >)
        let uniqueDays = Array(Set(sortedDates)).sorted(by: >)

        for day in uniqueDays {
            if day == checkDate || calendar.isDate(day, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if day < checkDate {
                break
            }
        }

        return streak
    }

    private func detectImprovementAreas(from sessions: [WritingSession]) -> [String] {
        guard sessions.count >= 3 else { return [] }

        var areas: [String] = []

        let avgWords = sessions.map { Double($0.wordCount) }.reduce(0, +) / Double(sessions.count)
        if avgWords < 200 {
            areas.append("Try longer sessions to develop your ideas fully")
        }

        let avgDuration = sessions.map { $0.duration }.reduce(0, +) / Double(sessions.count)
        if avgDuration < 600 {
            areas.append("Your sessions are brief — consider setting a minimum 10-minute goal")
        }

        return areas
    }

    private func generateHighlight(totalWords: Int, sessions: Int, avgLength: TimeInterval) -> String {
        if totalWords > 5000 && sessions >= 5 {
            return "Outstanding week! You've written \(totalWords) words across \(sessions) sessions."
        } else if totalWords > 2000 {
            return "Solid progress — \(totalWords) words and counting!"
        } else if sessions >= 3 {
            return "Great consistency with \(sessions) sessions this week!"
        } else {
            return "Every word counts. Keep building your writing habit!"
        }
    }

    // MARK: - Session Storage

    func saveSession(_ session: WritingSession) {
        var sessions = loadSessions()
        sessions.append(session)

        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }

    func loadSessions() -> [WritingSession] {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let decoded = try? JSONDecoder().decode([WritingSession].self, from: data) else {
            return []
        }
        return decoded
    }
}
