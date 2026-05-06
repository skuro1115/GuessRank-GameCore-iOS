import Foundation

enum TopicBlockReason: String, Codable, CaseIterable {
    case inappropriate
    case boring
    case other

    var displayName: String {
        switch self {
        case .inappropriate: "不適切"
        case .boring: "つまらない"
        case .other: "その他"
        }
    }
}

struct BlockedTopic: Codable, Identifiable, Equatable {
    let topicId: String
    let reason: TopicBlockReason?
    let blockedAt: Date

    var id: String { topicId }
}

/// Persists user-blocked topic IDs so they're excluded from future selections.
class TopicBlockStore {
    private let fileURL: URL
    private(set) var entries: [BlockedTopic] = []

    init(directory: URL? = nil) {
        let dir = directory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent("topic_blocks.json")
        load()
    }

    var blockedIds: Set<String> { Set(entries.map { $0.topicId }) }

    var count: Int { entries.count }

    func isBlocked(_ topicId: String) -> Bool {
        entries.contains { $0.topicId == topicId }
    }

    func block(_ topicId: String, reason: TopicBlockReason? = nil, at date: Date = Date()) {
        guard !topicId.isEmpty else { return }
        if let index = entries.firstIndex(where: { $0.topicId == topicId }) {
            // Refresh existing record with new metadata.
            entries[index] = BlockedTopic(topicId: topicId, reason: reason, blockedAt: date)
        } else {
            entries.append(BlockedTopic(topicId: topicId, reason: reason, blockedAt: date))
        }
        persist()
    }

    func unblock(_ topicId: String) {
        guard let index = entries.firstIndex(where: { $0.topicId == topicId }) else { return }
        entries.remove(at: index)
        persist()
    }

    func clearAll() {
        guard !entries.isEmpty else { return }
        entries.removeAll()
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([BlockedTopic].self, from: data) {
            entries = decoded
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
