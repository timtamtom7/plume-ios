import SwiftUI

struct HomeView: View {
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
        .background(Theme.parchment.ignoresSafeArea())
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good \(greeting)")
                .font(.system(size: 28, weight: .light, design: .serif))
                .foregroundColor(Theme.inkBlue)
            Text(formattedDate)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Theme.inkBlue.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "feather.pointed")
                    .foregroundColor(Theme.featherGold)
                Text("Today's Prompt")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.inkBlue.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
            }

            Text(data.todayPrompt?.text ?? "What will you write today?")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.inkBlue)
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
                .background(Theme.inkBlue)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(Theme.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var statsPreview: some View {
        HStack(spacing: 16) {
            statCard(
                icon: "flame.fill",
                iconColor: .orange,
                value: "\(data.streak)",
                label: "Day Streak"
            )
            statCard(
                icon: "character.cursor.ibeam",
                iconColor: Theme.inkBlue,
                value: "\(data.todayWordCount)",
                label: "Words Today"
            )
            statCard(
                icon: "target",
                iconColor: Theme.featherGold,
                value: "\(Int(Double(data.todayWordCount) / Double(data.dailyGoal) * 100))%",
                label: "Goal"
            )
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.inkBlue)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.inkBlue.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.cardBg)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
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
