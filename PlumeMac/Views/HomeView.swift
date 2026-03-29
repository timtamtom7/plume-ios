import SwiftUI

struct HomeView: View {
    @Environment(\.appTheme) var theme
    @ObservedObject var data: WritingData
    @Binding var showEditor: Bool
    @Binding var selectedPrompt: WritingPrompt?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                promptCard
                statsPreview
            }
            .padding(24)
        }
        .background(theme.parchment.ignoresSafeArea())
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good \(greeting)")
                .font(.system(size: 28, weight: .light, design: .serif))
                .foregroundColor(theme.inkBlue)
            Text(formattedDate)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(theme.inkBlue.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "feather.pointed")
                    .foregroundColor(theme.featherGold)
                Text("Today's Prompt")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.inkBlue.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
            }

            Text(data.todayPrompt?.text ?? "What will you write today?")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(theme.inkBlue)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                selectedPrompt = data.todayPrompt
                showEditor = true
            }) {
                HStack {
                    Image(systemName: "pencil.line")
                    Text("Start Writing")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(theme.inkBlue)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(theme.cardBg)
        .cornerRadius(16)
        .shadow(color: theme.parchment.opacity(0.6), radius: 8, x: 0, y: 2)
    }

    private var statsPreview: some View {
        HStack(spacing: 16) {
            statCard(icon: "flame.fill", iconColor: theme.accentOrange, value: "\(data.streak)", label: "Day Streak")
            statCard(icon: "character.cursor.ibeam", iconColor: theme.inkBlue, value: "\(data.todayWordCount)", label: "Words Today")
            statCard(icon: "target", iconColor: theme.featherGold, value: "\(Int(Double(data.todayWordCount) / Double(data.dailyGoal) * 100))%", label: "Goal")
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(theme.inkBlue)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.inkBlue.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(theme.cardBg)
        .cornerRadius(12)
        .shadow(color: theme.inkBlue.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Morning" }
        else if hour < 17 { return "Afternoon" }
        else { return "Evening" }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}
