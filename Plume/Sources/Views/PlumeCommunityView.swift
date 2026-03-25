import SwiftUI

/// R9: Anonymous community feed view
struct PlumeCommunityView: View {
    @StateObject private var communityService = PlumeCommunityService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                if communityService.isLoading {
                    ProgressView()
                        .tint(Color.plumeAccent)
                        .scaleEffect(1.5)
                } else {
                    communityContent
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await communityService.loadPublicFeed()
            }
        }
    }

    private var communityContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(communityService.publicReading) { update in
                    readingUpdateCard(update)
                }
            }
            .padding(16)
        }
    }

    private func readingUpdateCard(_ update: PlumeCommunityService.PublicReadingUpdate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 11))
                    Text(update.anonymousId)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color.plumeTextSecondary)

                Spacer()

                Text(timeAgo(update.timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(Color.plumeTextSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(update.bookTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.plumeTextPrimary)

                Text("by \(update.author)")
                    .font(.system(size: 13))
                    .foregroundColor(Color.plumeTextSecondary)
            }

            VStack(spacing: 8) {
                HStack {
                    Text("Read \(update.pagesRead) pages")
                        .font(.system(size: 13))
                        .foregroundColor(Color.plumeTextSecondary)

                    Spacer()

                    Text("\(update.progress)% complete")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.plumeAccent)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.plumeTextSecondary.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.plumeAccent)
                            .frame(width: geometry.size.width * CGFloat(update.progress) / 100, height: 6)
                    }
                }
                .frame(height: 6)
            }

            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                    Text("\(update.likes)")
                        .font(.system(size: 12))
                }
                .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(Color.plumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
