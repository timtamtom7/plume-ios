import SwiftUI

// MARK: - Community Prompt Model

struct CommunityPrompt: Identifiable {
    let id = UUID()
    let text: String
    let authorName: String
    let category: PromptCategory
    let upvotes: Int
    let createdAt: Date
    var hasUpvoted: Bool
}

// MARK: - Community Prompts View

struct CommunityPromptsView: View {
    @State private var prompts: [CommunityPrompt] = []
    @State private var selectedPrompt: CommunityPrompt?
    @State private var showingShareSheet = false
    @State private var sharePromptText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Community Prompts")
                    .font(.title2.bold())

                Spacer()

                Button(action: { loadPrompts() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                Button(action: { showingShareSheet = true }) {
                    Label("Share a Prompt", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Today's popular prompt
            if let popular = mostPopularPrompt {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Today's Most Popular")
                            .font(.headline)
                    }

                    Text(popular.text)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)

                    HStack {
                        Button(action: { upvote(popular) }) {
                            Label("\(popular.upvotes)", systemImage: popular.hasUpvoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button("Use This Prompt") {
                            selectedPrompt = popular
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }

            Divider()

            // All prompts
            List(prompts) { prompt in
                VStack(alignment: .leading, spacing: 6) {
                    Text(prompt.text)
                        .font(.body)

                    HStack {
                        Label(prompt.category.rawValue, systemImage: prompt.category.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("by \(prompt.authorName)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: { upvote(prompt) }) {
                            Image(systemName: prompt.hasUpvoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .foregroundColor(prompt.hasUpvoted ? .blue : .secondary)
                        }
                        .buttonStyle(.plain)
                        Text("\(prompt.upvotes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $showingShareSheet) {
            SharePromptSheet(promptText: $sharePromptText, onShare: sharePrompt)
        }
        .onAppear { loadPrompts() }
    }

    private var mostPopularPrompt: CommunityPrompt? {
        prompts.max(by: { $0.upvotes < $1.upvotes })
    }

    private func loadPrompts() {
        prompts = CommunityPrompt.examples
    }

    private func upvote(_ prompt: CommunityPrompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index].hasUpvoted.toggle()
            if prompts[index].hasUpvoted {
                prompts[index] = CommunityPrompt(
                    id: prompt.id,
                    text: prompt.text,
                    authorName: prompt.authorName,
                    category: prompt.category,
                    upvotes: prompts[index].upvotes + 1,
                    createdAt: prompt.createdAt,
                    hasUpvoted: true
                )
            }
        }
    }

    private func sharePrompt() {
        guard !sharePromptText.isEmpty else { return }
        let newPrompt = CommunityPrompt(
            text: sharePromptText,
            authorName: "You",
            category: .creative,
            upvotes: 0,
            createdAt: Date(),
            hasUpvoted: false
        )
        prompts.insert(newPrompt, at: 0)
        sharePromptText = ""
        showingShareSheet = false
    }
}

// MARK: - Share Prompt Sheet

struct SharePromptSheet: View {
    @Binding var promptText: String
    let onShare: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: PromptCategory = .creative

    var body: some View {
        VStack(spacing: 16) {
            Text("Share a Prompt")
                .font(.headline)

            TextEditor(text: $promptText)
                .frame(minHeight: 100)
                .border(Color.secondary.opacity(0.3), cornerRadius: 6)

            Picker("Category", selection: $selectedCategory) {
                ForEach(PromptCategory.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }

            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Share") { onShare() }
                    .buttonStyle(.borderedProminent)
                    .disabled(promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

// MARK: - Examples

extension CommunityPrompt {
    static let examples: [CommunityPrompt] = [
        CommunityPrompt(
            text: "Write about a door that leads somewhere unexpected.",
            authorName: "Elena",
            category: .creative,
            upvotes: 42,
            createdAt: Date().addingTimeInterval(-86400),
            hasUpvoted: false
        ),
        CommunityPrompt(
            text: "A stranger sits next to you on a long train ride...",
            authorName: "Marco",
            category: .fiction,
            upvotes: 38,
            createdAt: Date().addingTimeInterval(-172800),
            hasUpvoted: true
        ),
        CommunityPrompt(
            text: "Describe a moment when you felt truly alive.",
            authorName: "Sofia",
            category: .reflection,
            upvotes: 31,
            createdAt: Date().addingTimeInterval(-259200),
            hasUpvoted: false
        ),
        CommunityPrompt(
            text: "What are three things you're grateful for today?",
            authorName: "Luca",
            category: .journal,
            upvotes: 27,
            createdAt: Date().addingTimeInterval(-345600),
            hasUpvoted: false
        ),
        CommunityPrompt(
            text: "Write a letter to your younger self.",
            authorName: "Giulia",
            category: .journal,
            upvotes: 25,
            createdAt: Date().addingTimeInterval(-432000),
            hasUpvoted: false
        ),
    ]
}

#Preview {
    CommunityPromptsView()
}
