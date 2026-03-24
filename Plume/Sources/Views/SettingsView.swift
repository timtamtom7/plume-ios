import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                List {
                    // Current Plan Section
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Plan")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary)

                                Text(subscriptionManager.currentTier.displayName)
                                    .font(.custom("Georgia-Bold", size: 17))
                                    .foregroundColor(.plumeTextPrimary)

                                Text(subscriptionManager.currentTier.pricePerMonth)
                                    .font(.system(size: 13))
                                    .foregroundColor(.plumeTextSecondary)
                            }

                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(subscriptionManager.currentTier.accentColorSwiftUI.opacity(0.1))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(subscriptionManager.currentTier.accentColorSwiftUI)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.plumeSurface)

                        Button {
                            // Upgrade action handled by parent
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(.plumeAccent)
                                Text("Upgrade Plan")
                                    .foregroundColor(.plumeAccent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plumeTextSecondary.opacity(0.5))
                            }
                        }
                        .listRowBackground(Color.plumeSurface)
                    } header: {
                        Text("Subscription")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    // About Section
                    Section {
                        HStack {
                            Image(systemName: "feather")
                                .font(.system(size: 28))
                                .foregroundColor(.plumeAccent)
                                .frame(width: 44, height: 44)
                                .background(Color.plumeAccent.opacity(0.1))
                                .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Plume")
                                    .font(.custom("Georgia-Bold", size: 17))
                                    .foregroundColor(.plumeTextPrimary)
                                Text("Version 1.0.0")
                                    .font(.system(size: 13))
                                    .foregroundColor(.plumeTextSecondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.plumeSurface)
                    } header: {
                        Text("About")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Section {
                        SettingsRow(icon: "info.circle", title: "About Plume", subtitle: "Track your reading, finish your books.") {
                            // About action
                        }
                        .listRowBackground(Color.plumeSurface)

                        SettingsRow(icon: "star", title: "Rate Plume", subtitle: "Leave a review on the App Store") {
                            // Rate action
                        }
                        .listRowBackground(Color.plumeSurface)

                        SettingsRow(icon: "envelope", title: "Send Feedback", subtitle: "Help us improve Plume") {
                            // Feedback action
                        }
                        .listRowBackground(Color.plumeSurface)
                    } header: {
                        Text("Support")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Section {
                        HStack {
                            Spacer()
                            Text("Made with 📚 & ☕")
                                .font(.system(size: 12))
                                .foregroundColor(.plumeTextSecondary)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.plumeAccent)
                }
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.plumeAccent)
                    .frame(width: 28, height: 28)
                    .background(Color.plumeAccent.opacity(0.1))
                    .cornerRadius(6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15))
                        .foregroundColor(.plumeTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.plumeTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.plumeTextSecondary.opacity(0.5))
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SubscriptionManager.shared)
}
