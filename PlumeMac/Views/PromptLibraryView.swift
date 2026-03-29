import SwiftUI

struct PromptLibraryView: View {
    @ObservedObject var data: WritingData
    @Binding var showEditor: Bool
    @Binding var selectedPrompt: WritingPrompt?
    @State private var selectedCategory: PromptCategory = .creative

    var filteredPrompts: [WritingPrompt] {
        WritingData.prompts(for: selectedCategory)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            categoryPicker
            promptList
        }
        .background(Theme.parchment)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Prompt Library")
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundColor(Theme.inkBlue)
            Text("Choose a prompt to inspire your writing")
                .font(.system(size: 13))
                .foregroundColor(Theme.inkBlue.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PromptCategory.allCases, id: \.self) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    private func categoryButton(_ category: PromptCategory) -> some View {
        Button(action: { selectedCategory = category }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 11))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(selectedCategory == category ? .white : Theme.inkBlue)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(selectedCategory == category ? Theme.inkBlue : Theme.cardBg)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    private var promptList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredPrompts) { prompt in
                    promptCard(prompt)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func promptCard(_ prompt: WritingPrompt) -> some View {
        Button(action: {
            selectedPrompt = prompt
            showEditor = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: prompt.category.icon)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.featherGold)
                    Text(prompt.category.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.inkBlue.opacity(0.5))
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Spacer()
                    Image(systemName: "pencil.line")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.inkBlue.opacity(0.3))
                }

                Text(prompt.text)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundColor(Theme.inkBlue)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Theme.cardBg)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
