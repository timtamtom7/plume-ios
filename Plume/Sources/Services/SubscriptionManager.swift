import Foundation
import SwiftUI

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    private let userDefaults = UserDefaults.standard
    private let tierKey = "plume.subscription.tier"
    private let onboardingCompleteKey = "plume.onboarding.complete"
    private let onboardingShownKey = "plume.onboarding.shown"

    @Published var currentTier: SubscriptionTier = .free

    init() {
        loadTier()
    }

    private func loadTier() {
        if let raw = userDefaults.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: raw) {
            currentTier = tier
        } else {
            currentTier = .free
        }
    }

    func setTier(_ tier: SubscriptionTier) {
        currentTier = tier
        userDefaults.set(tier.rawValue, forKey: tierKey)
    }

    var isOnboardingComplete: Bool {
        get { userDefaults.bool(forKey: onboardingCompleteKey) }
        set { userDefaults.set(newValue, forKey: onboardingCompleteKey) }
    }

    var hasSeenOnboarding: Bool {
        get { userDefaults.bool(forKey: onboardingShownKey) }
        set { userDefaults.set(newValue, forKey: onboardingShownKey) }
    }

    func canAddBook(currentBookCount: Int) -> Bool {
        currentBookCount < currentTier.maxBooks
    }

    var showUpgradePrompt: Bool {
        false // Hook for future subscription logic
    }
}
