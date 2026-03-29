import SwiftUI

struct StatsView: View {
    @ObservedObject var data: WritingData
    @State private var weeklyData: [DailyStats] = []
    @State private var monthlyTotal: Int = 0
    @State private var averageSessionLength: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                streakCard
                wordsSection
                goalsSection
            }
            .padding(20)
        }
        .background(Theme.parchment)
        .onAppear {
            generateMockData()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Statistics")
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundColor(Theme.inkBlue)
            Text("Track your writing journey")
                .font(.system(size: 13))
                .foregroundColor(Theme.inkBlue.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var streakCard: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                HStack(alignment: .top, spacing: 4) {
                    Text("\(data.streak)")
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundColor(Theme.inkBlue)
                    Text("days")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.inkBlue.opacity(0.5))
                        .offset(y: 10)
                }
                Text("Current Streak")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.inkBlue.opacity(0.6))
            }

            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange.opacity(0.8))
        }
        .padding(24)
        .background(Theme.cardBg)
        .cornerRadius(16)
    }

    private var wordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Words Written")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.inkBlue.opacity(0.6))
                .textCase(.uppercase)
                .tracking(0.8)

            HStack(spacing: 12) {
                wordStatCard(value: "\(data.todayWordCount)", label: "Today", color: Theme.featherGold)
                wordStatCard(value: "\(weeklyTotal)", label: "This Week", color: Theme.inkBlue)
                wordStatCard(value: "\(monthlyTotal)", label: "This Month", color: Theme.featherGold.opacity(0.7))
            }

            weeklyChart
        }
    }

    private func wordStatCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.inkBlue)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.inkBlue.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.inkBlue.opacity(0.6))

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyData) { day in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(day.wordCount > 0 ? Theme.featherGold : Theme.parchment)
                            .frame(width: 28, height: chartHeight(for: day.wordCount))
                        Text(dayLabel(for: day.date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.inkBlue.opacity(0.4))
                    }
                }
            }
            .frame(height: 80, alignment: .bottom)
            .padding(.horizontal, 8)
        }
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private func chartHeight(for wordCount: Int) -> CGFloat {
        let wordCounts: [Int] = weeklyData.map { stat in stat.wordCount }
        let maxWords: Int = wordCounts.max() ?? 1
        guard maxWords > 0 else { return 8 }
        return max(CGFloat(wordCount) / CGFloat(maxWords) * 60, 8)
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var weeklyTotal: Int {
        var total = 0
        for day in weeklyData {
            total += day.wordCount
        }
        return total
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goals")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.inkBlue.opacity(0.6))
                .textCase(.uppercase)
                .tracking(0.8)

            VStack(spacing: 16) {
                goalRow(
                    title: "Daily Word Goal",
                    current: data.todayWordCount,
                    target: data.dailyGoal,
                    icon: "character.cursor.ibeam"
                )
                goalRow(
                    title: "Daily Writing Streak",
                    current: data.streak,
                    target: 30,
                    icon: "flame.fill"
                )
                goalRow(
                    title: "Average Session",
                    current: averageSessionLength,
                    target: 30,
                    icon: "clock"
                )
            }
        }
    }

    private func goalRow(title: String, current: Int, target: Int, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.featherGold)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.inkBlue)
                    Spacer()
                    Text("\(current)/\(target)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.inkBlue.opacity(0.6))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.parchment)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(current >= target ? Color.green : Theme.featherGold)
                            .frame(width: geometry.size.width * CGFloat(min(current, target)) / CGFloat(max(target, 1)), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private func generateMockData() {
        let calendar = Calendar.current
        var newWeeklyData: [DailyStats] = []
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: Date()) ?? Date()
            let isToday = calendar.isDateInToday(date)
            let wordCount = isToday ? data.todayWordCount : Int.random(in: 100...800)
            let sessionsCount = Int.random(in: 1...3)
            let totalDuration = TimeInterval(Int.random(in: 600...3600))
            newWeeklyData.append(DailyStats(date: date, wordCount: wordCount, sessionsCount: sessionsCount, totalDuration: totalDuration))
        }
        weeklyData = newWeeklyData

        var total = 0
        for day in weeklyData {
            total += day.wordCount
        }
        monthlyTotal = total * 4 + Int.random(in: 500...2000)
        averageSessionLength = Int.random(in: 20...45)
    }
}
