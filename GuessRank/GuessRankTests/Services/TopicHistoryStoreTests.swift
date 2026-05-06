import XCTest
@testable import GuessRankCore

final class TopicHistoryStoreTests: XCTestCase {
    private var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("topic_history_tests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        if let tempDir { try? FileManager.default.removeItem(at: tempDir) }
        tempDir = nil
        super.tearDown()
    }

    func test_record単一IDで保存される() {
        let store = TopicHistoryStore(directory: tempDir)
        XCTAssertTrue(store.playedIds.isEmpty)
        store.record("topic_1")
        XCTAssertEqual(store.playedIds, ["topic_1"])
    }

    func test_record同一IDは重複しない() {
        let store = TopicHistoryStore(directory: tempDir)
        store.record("topic_1")
        store.record("topic_1")
        XCTAssertEqual(store.count, 1)
    }

    func test_recordシーケンスで一括追加() {
        let store = TopicHistoryStore(directory: tempDir)
        store.record(["a", "b", "c"])
        XCTAssertEqual(store.playedIds, ["a", "b", "c"])
    }

    func test_clearで全件削除() {
        let store = TopicHistoryStore(directory: tempDir)
        store.record(["a", "b"])
        store.clear()
        XCTAssertTrue(store.playedIds.isEmpty)
    }

    func test_永続化_新インスタンスでも復元される() {
        let store1 = TopicHistoryStore(directory: tempDir)
        store1.record(["a", "b"])

        let store2 = TopicHistoryStore(directory: tempDir)
        XCTAssertEqual(store2.playedIds, ["a", "b"])
    }

    func test_clear後の永続化_新インスタンスで空() {
        let store1 = TopicHistoryStore(directory: tempDir)
        store1.record(["a"])
        store1.clear()

        let store2 = TopicHistoryStore(directory: tempDir)
        XCTAssertTrue(store2.playedIds.isEmpty)
    }

    func test_空文字IDは記録されない() {
        let store = TopicHistoryStore(directory: tempDir)
        store.record("")
        XCTAssertTrue(store.playedIds.isEmpty)
    }
}
