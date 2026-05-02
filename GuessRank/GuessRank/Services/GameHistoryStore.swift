import Foundation

struct GameHistoryEntry: Identifiable, Codable {
    let id: String
    let playedAt: Date
    let playerNames: [String]
    let winnerName: String
    let winnerScore: Int
    let totalTurns: Int
    let snapshot: GameSessionSnapshot

    init(snapshot: GameSessionSnapshot, playedAt: Date = Date()) {
        self.id = snapshot.id
        self.playedAt = playedAt
        self.playerNames = snapshot.players.map { $0.name }
        self.winnerName = snapshot.winner?.name ?? ""
        self.winnerScore = snapshot.winner?.score ?? 0
        self.totalTurns = snapshot.totalTurns
        self.snapshot = snapshot
    }
}

class GameHistoryStore {
    private let fileURL: URL
    private(set) var entries: [GameHistoryEntry] = []

    init(directory: URL? = nil) {
        let dir = directory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent("game_history.json")
        load()
    }

    func save(_ snapshot: GameSessionSnapshot) {
        let entry = GameHistoryEntry(snapshot: snapshot)
        entries.insert(entry, at: 0)
        persist()
    }

    func deleteEntry(at index: Int) {
        guard entries.indices.contains(index) else { return }
        entries.remove(at: index)
        persist()
    }

    func clearAll() {
        entries.removeAll()
        persist()
    }

    private static let retentionInterval: TimeInterval = 2 * 24 * 60 * 60 // 2日

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let all = (try? JSONDecoder().decode([GameHistoryEntry].self, from: data)) ?? []
        let cutoff = Date().addingTimeInterval(-Self.retentionInterval)
        let filtered = all.filter { $0.playedAt > cutoff }
        entries = filtered
        if filtered.count != all.count {
            persist()
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
