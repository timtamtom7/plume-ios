import SwiftUI

// MARK: - Writing Challenge Model

struct WritingChallenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let wordGoal: Int
    let timeLimitMinutes: Int?
    let startDate: Date
    let endDate: Date
    let participants: Int
    var isJoined: Bool
    var isCompleted: Bool

    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    var isExpired: Bool {
        Date() > endDate
    }
}

// MARK: - Writing Challenges View

struct WritingChallengesView: View {
    @Environment(\.appTheme) var theme
    @State private var challenges: [WritingChallenge] = []
    @State private var joinedChallenges: [WritingChallenge] = []
    @State private var currentStreak: Int = 0
    @State private var monthlyGoal: Int = 10000
    @State private var monthlyProgress: Int = 0
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Writing Challenges")
                    .font(.title2.bold())
                Spacer()
            }
            .padding()

            Divider()

            // Streak & Goals Summary
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(theme.accentOrange)
                        Text("\(currentStreak)-day Streak")
                            .font(.headline)
                    }
                    Text("Keep writing daily!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(theme.accentOrange.opacity(0.1))
                .cornerRadius(8)

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("March Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ProgressView(value: Double(min(monthlyProgress, monthlyGoal)), total: Double(monthlyGoal))
                        .frame(width: 150)
                    Text("\(monthlyProgress) / \(monthlyGoal) words")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()

            Divider()

            // Tab selection
            Picker("", selection: $selectedTab) {
                Text("Active Challenges").tag(0)
                Text("Quick Sprints").tag(1)
                Text("My Progress").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Content based on tab
            Group {
                switch selectedTab {
                case 0:
                    activeChallengesView
                case 1:
                    quickSprintsView
                case 2:
                    myProgressView
                default:
                    EmptyView()
                }
            }
        }
        .onAppear { loadChallenges() }
    }

    // MARK: - Active Challenges

    private var activeChallengesView: some View {
        List(challenges) { challenge in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(challenge.title)
                        .font(.headline)
                    Spacer()
                    if challenge.isActive {
                        Text("Active")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(theme.successGreen.opacity(0.2))
                            .foregroundColor(theme.successGreen)
                            .cornerRadius(4)
                    } else if challenge.isExpired {
                        Text("Ended")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(theme.subtleGray.opacity(0.2))
                            .foregroundColor(theme.subtleGray)
                            .cornerRadius(4)
                    }
                }

                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Label("\(challenge.wordGoal) words", systemImage: "text.alignleft")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let limit = challenge.timeLimitMinutes {
                        Label("\(limit) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Label("\(challenge.participants) joined", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !challenge.isCompleted {
                    Button(action: { joinChallenge(challenge) }) {
                        Text(challenge.isJoined ? "Joined ✓" : "Join Challenge")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(challenge.isJoined || challenge.isExpired)
                } else {
                    Label("Completed!", systemImage: "checkmark.circle.fill")
                        .foregroundColor(theme.successGreen)
                }
            }
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
    }

    // MARK: - Quick Sprints

    private var quickSprintsView: some View {
        VStack(spacing: 16) {
            Text("500 words in 30 minutes")
                .font(.title3.bold())

            HStack(spacing: 16) {
                ForEach([15, 30, 45, 60], id: \.self) { minutes in
                    SprintCard(minutes: minutes, words: 500 * minutes / 30)
                }
            }

            Divider()

            Text("Or set your own sprint")
                .font(.headline)

            HStack {
                TextField("Word goal", value: $monthlyGoal, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)

                Text("words in")

                TextField("Minutes", value: $monthlyProgress, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)

                Text("minutes")

                Button("Start Sprint") {
                    startSprint()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    // MARK: - My Progress

    private var myProgressView: some View {
        VStack(spacing: 24) {
            // Monthly goals
            VStack(alignment: .leading, spacing: 8) {
                Text("Monthly Writing Goals")
                    .font(.headline)

                VStack(spacing: 8) {
                    GoalRow(label: "Words written", current: monthlyProgress, goal: monthlyGoal)
                    GoalRow(label: "Days active", current: 18, goal: 31)
                    GoalRow(label: "Pieces completed", current: 7, goal: 10)
                }
            }
            .padding()
            .background(Color.accentColor.opacity(0.05))
            .cornerRadius(8)

            // Streak challenges
            VStack(alignment: .leading, spacing: 8) {
                Text("Streak Challenges")
                    .font(.headline)

                HStack(spacing: 16) {
                    StreakBadge(days: 7, currentStreak: currentStreak >= 7)
                    StreakBadge(days: 14, currentStreak: currentStreak >= 14)
                    StreakBadge(days: 30, currentStreak: currentStreak >= 30)
                    StreakBadge(days: 100, currentStreak: currentStreak >= 100)
                }
            }

            // Joined challenges
            VStack(alignment: .leading, spacing: 8) {
                Text("My Challenges")
                    .font(.headline)

                if joinedChallenges.isEmpty {
                    Text("You haven't joined any challenges yet.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(joinedChallenges) { challenge in
                        HStack {
                            Text(challenge.title)
                            Spacer()
                            if challenge.isCompleted {
                                Label("Done", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(theme.successGreen)
                            } else {
                                Text("\(challenge.wordGoal) words")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private func loadChallenges() {
        currentStreak = 5
        monthlyProgress = 4250
        challenges = WritingChallenge.examples
        joinedChallenges = challenges.filter { $0.isJoined }
    }

    private func joinChallenge(_ challenge: WritingChallenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].isJoined = true
            joinedChallenges.append(challenges[index])
        }
    }

    private func startSprint() {
        // Would open writing editor in sprint mode
    }
}

// MARK: - Sprint Card

struct SprintCard: View {
    let minutes: Int
    let words: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(minutes) min")
                .font(.title3.bold())
            Text("\(words) words")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Goal Row

struct GoalRow: View {
    let label: String
    let current: Int
    let goal: Int

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(current) / \(goal)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: progress)
        }
    }
}

// MARK: - Streak Badge

struct StreakBadge: View {
    @Environment(\.appTheme) var theme
    let days: Int
    let currentStreak: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: currentStreak ? "flame.fill" : "flame")
                .font(.title2)
                .foregroundColor(currentStreak ? theme.accentOrange : theme.subtleGray)
            Text("\(days) days")
                .font(.caption)
                .foregroundColor(currentStreak ? .primary : .secondary)
        }
        .padding()
        .background((currentStreak ? theme.accentOrange : theme.subtleGray).opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Examples

extension WritingChallenge {
    static let examples: [WritingChallenge] = [
        WritingChallenge(
            title: "March Madness",
            description: "Write 10,000 words throughout March. Any topic, any style.",
            wordGoal: 10000,
            timeLimitMinutes: nil,
            startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            participants: 142,
            isJoined: true,
            isCompleted: false
        ),
        WritingChallenge(
            title: "Flash Fiction Week",
            description: "Write a complete story in 500 words or less.",
            wordGoal: 500,
            timeLimitMinutes: nil,
            startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
            participants: 89,
            isJoined: false,
            isCompleted: false
        ),
        WritingChallenge(
            title: "Write Every Day",
            description: "Write at least 200 words every single day for a week.",
            wordGoal: 1400,
            timeLimitMinutes: nil,
            startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
            participants: 234,
            isJoined: true,
            isCompleted: true
        ),
        WritingChallenge(
            title: "Speed Writing",
            description: "500 words in 30 minutes. Race against the clock!",
            wordGoal: 500,
            timeLimitMinutes: 30,
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            participants: 67,
            isJoined: false,
            isCompleted: false
        ),
    ]
}

#Preview {
    WritingChallengesView()
}
