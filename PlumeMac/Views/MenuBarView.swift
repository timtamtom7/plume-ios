import SwiftUI

struct MenuBarView: View {
    @StateObject private var data = WritingData()
    @State private var selectedTab: Tab = .home
    @State private var showEditor: Bool = false
    @State private var selectedPrompt: WritingPrompt?
    @State private var editorPrompt: WritingPrompt?

    enum Tab: String, CaseIterable {
        case home = "Home"
        case prompts = "Prompts"
        case stats = "Stats"

        var icon: String {
            switch self {
            case .home: return "house"
            case .prompts: return "text.book.closed"
            case .stats: return "chart.bar"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if showEditor {
                WritingEditorView(
                    data: data,
                    isPresented: $showEditor,
                    prompt: editorPrompt
                )
            } else {
                mainContent
            }
        }
        .frame(width: 360, height: 480)
        .onAppear {
            data.todayPrompt = WritingData.todaysPrompt()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            tabBar
            tabContent
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Theme.cardBg)
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                Text(tab.rawValue)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(selectedTab == tab ? Theme.inkBlue : Theme.inkBlue.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView(data: data, showEditor: $showEditor, selectedPrompt: $editorPrompt)
        case .prompts:
            PromptLibraryView(data: data, showEditor: $showEditor, selectedPrompt: $editorPrompt)
        case .stats:
            StatsView(data: data)
        }
    }
}
