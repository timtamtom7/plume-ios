import Foundation

enum SubscriptionTier: String, CaseIterable, Identifiable {
    case free = "free"
    case reader = "reader"
    case scholar = "scholar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .reader: return "Reader"
        case .scholar: return "Scholar"
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .reader: return "$4.99"
        case .scholar: return "$9.99"
        }
    }

    var pricePerMonth: String {
        switch self {
        case .free: return "Free forever"
        case .reader: return "$4.99 / month"
        case .scholar: return "$9.99 / month"
        }
    }

    var tagline: String {
        switch self {
        case .free: return "Start tracking your reading"
        case .reader: return "For dedicated readers"
        case .scholar: return "For serious readers & researchers"
        }
    }

    var maxBooks: Int {
        switch self {
        case .free: return 3
        case .reader: return Int.max
        case .scholar: return Int.max
        }
    }

    var features: [SubscriptionFeature] {
        switch self {
        case .free:
            return [
                SubscriptionFeature(text: "Track up to 3 books", included: true),
                SubscriptionFeature(text: "Basic progress tracking", included: true),
                SubscriptionFeature(text: "Simple reading pace", included: true),
                SubscriptionFeature(text: "Unlimited books", included: false),
                SubscriptionFeature(text: "Finish date prediction", included: false),
                SubscriptionFeature(text: "Export quotes & citations", included: false),
                SubscriptionFeature(text: "Reading streaks", included: false),
                SubscriptionFeature(text: "Personalized recommendations", included: false),
            ]
        case .reader:
            return [
                SubscriptionFeature(text: "Unlimited books", included: true),
                SubscriptionFeature(text: "Reading pace tracking", included: true),
                SubscriptionFeature(text: "Finish date prediction", included: true),
                SubscriptionFeature(text: "Progress history", included: true),
                SubscriptionFeature(text: "Export quotes & citations", included: false),
                SubscriptionFeature(text: "Reading streaks", included: false),
                SubscriptionFeature(text: "Personalized recommendations", included: false),
            ]
        case .scholar:
            return [
                SubscriptionFeature(text: "Everything in Reader", included: true),
                SubscriptionFeature(text: "Export quotes", included: true),
                SubscriptionFeature(text: "Citation formats (APA, MLA, Chicago)", included: true),
                SubscriptionFeature(text: "Reading streaks", included: true),
                SubscriptionFeature(text: "Personalized recommendations", included: true),
                SubscriptionFeature(text: "Priority support", included: true),
            ]
        }
    }

    var accentColor: String {
        switch self {
        case .free: return "#7a7068"
        case .reader: return "#2d5a3d"
        case .scholar: return "#8b4513"
        }
    }

    var isPopular: Bool {
        self == .reader
    }
}

struct SubscriptionFeature: Identifiable {
    let id = UUID()
    let text: String
    let included: Bool
}
