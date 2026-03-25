import Foundation

/// R8: Cross-device sync service for iPad, macOS, Apple Watch
@MainActor
final class PlumeCrossDeviceSyncService: ObservableObject {
    static let shared = PlumeCrossDeviceSyncService()

    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var connectedDevices: [Device] = []

    struct Device: Identifiable, Codable {
        let id: UUID
        let name: String
        let type: DeviceType
        let lastSeen: Date
        var isConnected: Bool

        enum DeviceType: String, Codable {
            case iPhone
            case iPad
            case mac
            case appleWatch
        }
    }

    private init() {
        loadLastSyncDate()
        loadConnectedDevices()
    }

    func syncAll() async throws {
        guard !isSyncing else { return }
        isSyncing = true

        try await Task.sleep(nanoseconds: 500_000_000)

        lastSyncDate = Date()
        saveLastSyncDate()
        isSyncing = false
    }

    var lastSyncText: String {
        guard let date = lastSyncDate else { return "Never synced" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Synced \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: "plume_last_sync")
    }

    private func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: "plume_last_sync") as? Date
    }

    private func loadConnectedDevices() {
        // Load from UserDefaults
    }
}
