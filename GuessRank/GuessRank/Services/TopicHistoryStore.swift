import Foundation

/// Persists which topic IDs have already been played so the next session can
/// avoid repeating them. Mirrors `GameHistoryStore`'s file-based persistence.
class TopicHistoryStore {
    private let fileURL: URL
    private(set) var playedIds: Set<String> = []

    init(directory: URL? = nil) {
        let dir = directory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent("topic_history.json")
        load()
    }

    func record(_ topicId: String) {
        guard !topicId.isEmpty else { return }
        guard !playedIds.contains(topicId) else { return }
        playedIds.insert(topicId)
        persist()
    }

    func record<S: Sequence>(_ topicIds: S) where S.Element == String {
        var changed = false
        for id in topicIds where !id.isEmpty && !playedIds.contains(id) {
            playedIds.insert(id)
            changed = true
        }
        if changed { persist() }
    }

    func clear() {
        guard !playedIds.isEmpty else { return }
        playedIds.removeAll()
        persist()
    }

    var count: Int { playedIds.count }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let ids = try? JSONDecoder().decode([String].self, from: data) {
            playedIds = Set(ids)
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(Array(playedIds)) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
