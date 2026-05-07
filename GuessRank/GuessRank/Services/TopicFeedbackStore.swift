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

enum TopicFeedbackKind: String, Codable {
    case block
    case like
}

struct TopicFeedback: Codable, Identifiable, Equatable {
    let topicId: String
    let kind: TopicFeedbackKind
    let blockReason: TopicBlockReason?
    let recordedAt: Date

    var id: String { "\(kind.rawValue):\(topicId)" }
}

/// Persists user feedback (block / like) on topics for local filtering and future remote sync.
class TopicFeedbackStore {
    private let fileURL: URL
    private(set) var entries: [TopicFeedback] = []

    init(directory: URL? = nil) {
        let dir = directory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent("topic_feedback.json")
        load()
        migrateLegacyBlockStoreIfNeeded(in: dir)
    }

    // MARK: - Block API

    var blockedEntries: [TopicFeedback] {
        entries.filter { $0.kind == .block }
    }

    var blockedIds: Set<String> {
        Set(blockedEntries.map { $0.topicId })
    }

    func isBlocked(_ topicId: String) -> Bool {
        entries.contains { $0.topicId == topicId && $0.kind == .block }
    }

    func block(_ topicId: String, reason: TopicBlockReason? = nil, at date: Date = Date()) {
        guard !topicId.isEmpty else { return }
        let new = TopicFeedback(topicId: topicId, kind: .block, blockReason: reason, recordedAt: date)
        if let index = entries.firstIndex(where: { $0.topicId == topicId && $0.kind == .block }) {
            entries[index] = new
        } else {
            entries.append(new)
        }
        persist()
    }

    func unblock(_ topicId: String) {
        let before = entries.count
        entries.removeAll { $0.topicId == topicId && $0.kind == .block }
        if entries.count != before { persist() }
    }

    func clearBlocks() {
        let before = entries.count
        entries.removeAll { $0.kind == .block }
        if entries.count != before { persist() }
    }

    // MARK: - Like API

    var likedEntries: [TopicFeedback] {
        entries.filter { $0.kind == .like }
    }

    var likedIds: Set<String> {
        Set(likedEntries.map { $0.topicId })
    }

    func isLiked(_ topicId: String) -> Bool {
        entries.contains { $0.topicId == topicId && $0.kind == .like }
    }

    func like(_ topicId: String, at date: Date = Date()) {
        guard !topicId.isEmpty else { return }
        if entries.contains(where: { $0.topicId == topicId && $0.kind == .like }) { return }
        entries.append(TopicFeedback(topicId: topicId, kind: .like, blockReason: nil, recordedAt: date))
        persist()
    }

    func unlike(_ topicId: String) {
        let before = entries.count
        entries.removeAll { $0.topicId == topicId && $0.kind == .like }
        if entries.count != before { persist() }
    }

    func clearLikes() {
        let before = entries.count
        entries.removeAll { $0.kind == .like }
        if entries.count != before { persist() }
    }

    // MARK: - Common

    func clearAll() {
        guard !entries.isEmpty else { return }
        entries.removeAll()
        persist()
    }

    // MARK: - Export

    /// 永続化された全FBエントリを人間可読のJSON文字列として返す。
    /// ユーザー操作で ShareSheet 経由のエクスポート用。
    func exportJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(entries)
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([TopicFeedback].self, from: data) {
            entries = decoded
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func migrateLegacyBlockStoreIfNeeded(in directory: URL) {
        let legacyURL = directory.appendingPathComponent("topic_blocks.json")
        let fm = FileManager.default
        guard fm.fileExists(atPath: legacyURL.path) else { return }
        guard !fm.fileExists(atPath: fileURL.path) else { return }

        struct LegacyBlockedTopic: Codable {
            let topicId: String
            let reason: TopicBlockReason?
            let blockedAt: Date
        }
        guard let data = try? Data(contentsOf: legacyURL),
              let legacy = try? JSONDecoder().decode([LegacyBlockedTopic].self, from: data) else {
            return
        }
        entries = legacy.map {
            TopicFeedback(topicId: $0.topicId, kind: .block, blockReason: $0.reason, recordedAt: $0.blockedAt)
        }
        persist()
        try? fm.removeItem(at: legacyURL)
    }
}
