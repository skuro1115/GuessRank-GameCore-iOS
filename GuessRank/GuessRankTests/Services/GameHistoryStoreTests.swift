import XCTest
@testable import GuessRankCore

final class GameHistoryStoreTests: XCTestCase {
    private var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    private func makeSnapshot(playerNames: [String] = ["A", "B", "C"]) -> GameSessionSnapshot {
        var session = Fixtures.session(playerNames: playerNames)
        session.players[0].score = 100
        session.players[1].score = 50
        return GameSessionSnapshot(from: session)
    }

    // MARK: - Save

    func test_saveでエントリが追加される() {
        let store = GameHistoryStore(directory: tempDir)
        let snap = makeSnapshot()
        store.save(snap)

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries[0].winnerName, "A")
        XCTAssertEqual(store.entries[0].winnerScore, 100)
    }

    func test_複数回saveで新しいものが先頭() {
        let store = GameHistoryStore(directory: tempDir)
        store.save(makeSnapshot(playerNames: ["A", "B"]))
        store.save(makeSnapshot(playerNames: ["X", "Y", "Z"]))

        XCTAssertEqual(store.entries.count, 2)
        XCTAssertEqual(store.entries[0].playerNames, ["X", "Y", "Z"])
        XCTAssertEqual(store.entries[1].playerNames, ["A", "B"])
    }

    // MARK: - Persistence

    func test_保存後に再読み込みでデータが復元される() {
        let store1 = GameHistoryStore(directory: tempDir)
        store1.save(makeSnapshot(playerNames: ["A", "B"]))
        store1.save(makeSnapshot(playerNames: ["X", "Y"]))

        let store2 = GameHistoryStore(directory: tempDir)
        XCTAssertEqual(store2.entries.count, 2)
        XCTAssertEqual(store2.entries[0].playerNames, ["X", "Y"])
    }

    // MARK: - Delete

    func test_deleteEntryで指定インデックスが削除される() {
        let store = GameHistoryStore(directory: tempDir)
        store.save(makeSnapshot(playerNames: ["A", "B"]))
        store.save(makeSnapshot(playerNames: ["X", "Y"]))

        store.deleteEntry(at: 0)
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries[0].playerNames, ["A", "B"])
    }

    func test_deleteEntryで範囲外インデックスは安全() {
        let store = GameHistoryStore(directory: tempDir)
        store.save(makeSnapshot())
        store.deleteEntry(at: 99)
        XCTAssertEqual(store.entries.count, 1)
    }

    // MARK: - Clear

    func test_clearAllで全件削除() {
        let store = GameHistoryStore(directory: tempDir)
        store.save(makeSnapshot())
        store.save(makeSnapshot())
        store.clearAll()
        XCTAssertTrue(store.entries.isEmpty)
    }

    func test_clearAll後に再読み込みでも空() {
        let store1 = GameHistoryStore(directory: tempDir)
        store1.save(makeSnapshot())
        store1.clearAll()

        let store2 = GameHistoryStore(directory: tempDir)
        XCTAssertTrue(store2.entries.isEmpty)
    }

    // MARK: - Entry properties

    func test_エントリにplayedAtが記録される() {
        let store = GameHistoryStore(directory: tempDir)
        let before = Date()
        store.save(makeSnapshot())
        let after = Date()

        let entry = store.entries[0]
        XCTAssertGreaterThanOrEqual(entry.playedAt, before)
        XCTAssertLessThanOrEqual(entry.playedAt, after)
    }

    func test_エントリのidはsnapshotのid() {
        let store = GameHistoryStore(directory: tempDir)
        let snap = makeSnapshot()
        store.save(snap)

        XCTAssertEqual(store.entries[0].id, snap.id)
    }

    func test_エントリのtotalTurnsが正しい() {
        let store = GameHistoryStore(directory: tempDir)
        store.save(makeSnapshot())

        XCTAssertEqual(store.entries[0].totalTurns, 3)
    }

    // MARK: - Retention (2日で自動削除)

    func test_2日以上前のエントリは読み込み時に削除される() {
        // 手動で古いエントリを含むJSONを書き込む
        let snap = makeSnapshot()
        let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
        let oldEntry = GameHistoryEntry(snapshot: snap, playedAt: threeDaysAgo)
        let freshEntry = GameHistoryEntry(snapshot: makeSnapshot(playerNames: ["X", "Y"]), playedAt: Date())

        let data = try! JSONEncoder().encode([freshEntry, oldEntry])
        let fileURL = tempDir.appendingPathComponent("game_history.json")
        try! data.write(to: fileURL)

        let store = GameHistoryStore(directory: tempDir)
        XCTAssertEqual(store.entries.count, 1, "2日超過のエントリは除外されるべき")
        XCTAssertEqual(store.entries[0].playerNames, ["X", "Y"])
    }

    func test_2日以内のエントリは保持される() {
        let snap = makeSnapshot()
        let oneDayAgo = Date().addingTimeInterval(-1 * 24 * 60 * 60)
        let entry = GameHistoryEntry(snapshot: snap, playedAt: oneDayAgo)

        let data = try! JSONEncoder().encode([entry])
        let fileURL = tempDir.appendingPathComponent("game_history.json")
        try! data.write(to: fileURL)

        let store = GameHistoryStore(directory: tempDir)
        XCTAssertEqual(store.entries.count, 1, "2日以内のエントリは保持されるべき")
    }
}
