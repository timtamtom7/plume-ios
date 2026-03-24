import SwiftUI

struct PricingView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: SubscriptionTier = .reader
    @State private var showingPurchaseAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plumeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Header
                        headerSection

                        // Tier cards
                        VStack(spacing: 16) {
                            ForEach(SubscriptionTier.allCases) { tier in
                                PricingTierCard(
                                    tier: tier,
                                    isSelected: selectedTier == tier,
                                    onSelect: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedTier = tier
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        // CTA
                        ctaButton

                        // Guarantee
                        guaranteeSection
                    }
                    .padding(.vertical, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Choose Your Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plumeTextSecondary)
                            .frame(width: 28, height: 28)
                            .background(Color.plumeSurface)
                            .clipShape(Circle())
                    }
                }
            }
            .alert("Coming Soon", isPresented: $showingPurchaseAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("In-app purchases will be available in a future update. Thank you for your interest in Plume \(selectedTier.displayName)!")
            }
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Simple, honest pricing.")
                .font(.custom("Georgia-Bold", size: 24))
                .foregroundColor(.plumeTextPrimary)
                .multilineTextAlignment(.center)

            Text("Start free. Upgrade when you're ready.")
                .font(.system(size: 15))
                .foregroundColor(.plumeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var ctaButton: some View {
        VStack(spacing: 12) {
            Button {
                if selectedTier == .free {
                    subscriptionManager.setTier(.free)
                    dismiss()
                } else {
                    showingPurchaseAlert = true
                }
            } label: {
                Text(selectedTier == .free ? "Continue Free" : "Start \(selectedTier.displayName)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedTier.accentColorSwiftUI)
                    .cornerRadius(12)
                    .shadow(color: selectedTier.accentColorSwiftUI.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            if selectedTier != .free {
                Text("Cancel anytime. No commitment.")
                    .font(.system(size: 12))
                    .foregroundColor(.plumeTextSecondary)
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var guaranteeSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf")
                .font(.system(size: 14))
                .foregroundColor(.plumeCurrentlyReading)

            Text("30-day money-back guarantee on all paid plans.")
                .font(.system(size: 12))
                .foregroundColor(.plumeTextSecondary)
        }
        .padding(.horizontal, 16)
    }
}

struct PricingTierCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(tier.displayName)
                                .font(.custom("Georgia-Bold", size: 18))
                                .foregroundColor(.plumeTextPrimary)

                            if tier.isPopular {
                                Text("Most Popular")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.plumeAccentSecondary)
                                    .cornerRadius(10)
                            }
                        }

                        Text(tier.tagline)
                            .font(.system(size: 13))
                            .foregroundColor(.plumeTextSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(tier.price)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(tier.accentColorSwiftUI)

                        if tier != .free {
                            Text("/ month")
                                .font(.system(size: 11))
                                .foregroundColor(.plumeTextSecondary)
                        }
                    }
                }
                .padding(16)

                Divider()

                // Features
                VStack(spacing: 10) {
                    ForEach(tier.features) { feature in
                        HStack(spacing: 10) {
                            Image(systemName: feature.included ? "checkmark.circle.fill" : "xmark.circle")
                                .font(.system(size: 14))
                                .foregroundColor(feature.included ? .plumeCurrentlyReading : .plumeTextSecondary.opacity(0.4))

                            Text(feature.text)
                                .font(.system(size: 14))
                                .foregroundColor(feature.included ? .plumeTextPrimary : .plumeTextSecondary.opacity(0.5))

                            Spacer()
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.plumeSurface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? tier.accentColorSwiftUI : Color.plumeTextSecondary.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? tier.accentColorSwiftUI.opacity(0.15) : .black.opacity(0.05), radius: isSelected ? 12 : 6, x: 0, y: isSelected ? 6 : 3)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

extension SubscriptionTier {
    var accentColorSwiftUI: Color {
        Color(hex: accentColor) ?? .plumeAccent
    }
}

#Preview {
    PricingView()
        .environmentObject(SubscriptionManager())
}
