import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var bookStore: BookStore
    @EnvironmentObject var challengeStore: ChallengeStore
    @State private var showingSetGoal = false
    @State private var showingChallengeHistory = false
    @State private var newGoal: Int = 24

    var body: some View {
        ZStack {
            Color.plumeBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Annual Challenge Card
                    annualChallengeCard

                    // Monthly Challenge Card
                    monthlyChallengeCard

                    // Stats Overview
                    statsOverview
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Challenges")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingSetGoal) {
            SetGoalSheet(goal: $newGoal) {
                challengeStore.createChallenge(goal: newGoal)
                showingSetGoal = false
            }
        }
        .sheet(isPresented: $showingChallengeHistory) {
            ChallengeHistoryView()
        }
    }

    @ViewBuilder
    private var annualChallengeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Annual Reading Challenge")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                if let challenge = challengeStore.currentChallenge, !challenge.isOnTrack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }

            VStack(spacing: 0) {
                if let challenge = challengeStore.currentChallenge {
                    // Progress ring
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.plumeTextSecondary.opacity(0.1), lineWidth: 10)

                            Circle()
                                .trim(from: 0, to: CGFloat(challenge.progressPercent))
                                .stroke(
                                    AngularGradient(
                                        colors: [.plumeAccent, .plumeAccentSecondary],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.8), value: challenge.progressPercent)

                            VStack(spacing: 2) {
                                Text("\(challenge.booksCompleted)")
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(.plumeTextPrimary)

                                Text("of \(challenge.annualGoal)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                        .frame(width: 100, height: 100)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(challenge.year)")
                                .font(.custom("Georgia-Bold", size: 20))
                                .foregroundColor(.plumeTextPrimary)

                            if let message = challenge.paceMessage {
                                Text(message)
                                    .font(.system(size: 13))
                                    .foregroundColor(challenge.isOnTrack ? .plumeAccent : .orange)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Text("\(challenge.booksRemaining) books to go")
                                .font(.system(size: 12))
                                .foregroundColor(.plumeTextSecondary)
                        }

                        Spacer()
                    }
                    .padding(20)

                    Divider()

                    Button {
                        newGoal = challenge.annualGoal
                        showingSetGoal = true
                    } label: {
                        HStack {
                            Image(systemName: "target")
                            Text("Adjust Goal")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plumeAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                } else {
                    // No challenge set
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 40))
                            .foregroundColor(.plumeTextSecondary.opacity(0.5))

                        Text("Set Your Reading Goal")
                            .font(.custom("Georgia-Bold", size: 17))
                            .foregroundColor(.plumeTextPrimary)

                        Text("How many books do you want to read this year?")
                            .font(.system(size: 14))
                            .foregroundColor(.plumeTextSecondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 12) {
                            ForEach([12, 24, 52], id: \.self) { goal in
                                Button {
                                    newGoal = goal
                                    challengeStore.createChallenge(goal: goal)
                                } label: {
                                    Text("\(goal)")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.plumeAccent)
                                        .frame(width: 60, height: 60)
                                        .background(Color.plumeAccent.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                }
            }
            .background(Color.plumeSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private var monthlyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Monthly Challenge")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(.plumeTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                Button {
                    showingChallengeHistory = true
                } label: {
                    Text("History")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.plumeAccent)
                }
            }

            if let monthly = challengeStore.currentMonthlyChallenge {
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(monthly.isCompleted ? Color.plumeAccent.opacity(0.1) : Color.orange.opacity(0.1))
                                .frame(width: 50, height: 50)

                            Image(systemName: monthly.isCompleted ? "checkmark.circle.fill" : monthly.challengeType.icon)
                                .font(.system(size: 22))
                                .foregroundColor(monthly.isCompleted ? .plumeAccent : .orange)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(monthly.formattedDate)
                                .font(.system(size: 12))
                                .foregroundColor(.plumeTextSecondary)

                            Text(monthly.challengeText)
                                .font(.custom("Georgia-Bold", size: 16))
                                .foregroundColor(.plumeTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()
                    }
                    .padding(16)

                    Divider()

                    if monthly.isCompleted {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.plumeAccent)
                            Text("Challenge completed!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plumeAccent)
                            Spacer()
                        }
                        .padding(16)
                    } else {
                        Button {
                            challengeStore.markMonthlyChallengeComplete()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Mark as Complete")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plumeAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .background(Color.plumeSurface)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.plumeAccent)

                    Text("Loading challenge...")
                        .font(.system(size: 14))
                        .foregroundColor(.plumeTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.plumeSurface)
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.custom("Georgia-Bold", size: 13))
                .foregroundColor(.plumeTextSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ChallengeStatCard(
                    title: "Books Finished",
                    value: "\(bookStore.finishedBooks.count)",
                    icon: "books.vertical.fill",
                    color: .plumeFinished
                )

                ChallengeStatCard(
                    title: "Currently Reading",
                    value: "\(bookStore.currentlyReading.count)",
                    icon: "book.fill",
                    color: .plumeCurrentlyReading
                )

                ChallengeStatCard(
                    title: "Pages This Year",
                    value: "\(totalPagesReadThisYear)",
                    icon: "doc.text.fill",
                    color: .plumeAccent
                )

                ChallengeStatCard(
                    title: "Avg Pace",
                    value: averagePagesPerDay,
                    icon: "speedometer",
                    color: .orange
                )
            }
        }
    }

    private var totalPagesReadThisYear: Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return bookStore.allBooks
            .filter { calendar.component(.year, from: $0.startDate) == currentYear }
            .reduce(0) { $0 + $1.currentPage }
    }

    private var averagePagesPerDay: String {
        let books = bookStore.finishedBooks
        guard !books.isEmpty else { return "0" }
        let totalDays = books.reduce(0) { $0 + $1.daysReading }
        guard totalDays > 0 else { return "0" }
        let totalPages = books.reduce(0) { $0 + $1.totalPages }
        let avg = Double(totalPages) / Double(totalDays)
        return String(format: "%.0f/day", avg)
    }
}

struct ChallengeStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.plumeTextPrimary)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.plumeTextSecondary)
        }
        .padding(16)
        .background(Color.plumeSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct SetGoalSheet: View {
    @Binding var goal: Int
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Set Your Annual Goal")
                        .font(.custom("Georgia-Bold", size: 20))
                        .foregroundColor(.plumeTextPrimary)

                    Text("How many books do you want to read?")
                        .font(.system(size: 15))
                        .foregroundColor(.plumeTextSecondary)

                    HStack(spacing: 16) {
                        ForEach([12, 24, 52, 100], id: \.self) { number in
                            Button {
                                goal = number
                            } label: {
                                Text("\(number)")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(goal == number ? .white : .plumeAccent)
                                    .frame(width: 70, height: 70)
                                    .background(goal == number ? Color.plumeAccent : Color.plumeAccent.opacity(0.1))
                                    .cornerRadius(16)
                            }
                        }
                    }

                    VStack(spacing: 8) {
                        Text("Or enter custom:")
                            .font(.system(size: 13))
                            .foregroundColor(.plumeTextSecondary)

                        TextField("Goal", value: $goal, format: .number)
                            .font(.system(size: 24, weight: .semibold, design: .monospaced))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.plumeSurface)
                            .cornerRadius(12)
                            .frame(width: 150)
                    }

                    Spacer()

                    Button {
                        onSave()
                    } label: {
                        Text("Save Goal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.plumeAccent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
        }
    }
}

struct ChallengeHistoryView: View {
    @EnvironmentObject var challengeStore: ChallengeStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                if challengeStore.monthlyChallengesHistory.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundColor(.plumeTextSecondary.opacity(0.5))

                        Text("No Challenge History")
                            .font(.custom("Georgia-Bold", size: 17))
                            .foregroundColor(.plumeTextPrimary)

                        Text("Your monthly challenges will appear here")
                            .font(.system(size: 14))
                            .foregroundColor(.plumeTextSecondary)
                    }
                } else {
                    List {
                        ForEach(challengeStore.monthlyChallengesHistory) { challenge in
                            HStack(spacing: 12) {
                                Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : challenge.challengeType.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(challenge.isCompleted ? .plumeAccent : .orange)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(challenge.formattedDate)
                                        .font(.system(size: 12))
                                        .foregroundColor(.plumeTextSecondary)

                                    Text(challenge.challengeText)
                                        .font(.system(size: 15))
                                        .foregroundColor(.plumeTextPrimary)
                                }

                                Spacer()

                                if challenge.isCompleted {
                                    Text("✓")
                                        .foregroundColor(.plumeAccent)
                                }
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(Color.plumeSurface)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Challenge History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
            .onAppear {
                challengeStore.loadMonthlyChallengesHistory()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChallengeView()
            .environmentObject(BookStore())
            .environmentObject(ChallengeStore())
    }
}
