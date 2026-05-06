import XCTest
@testable import GuessRankCore

final class TopicBlockStoreTests: XCTestCase {
    private var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("topic_block_tests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        if let tempDir { try? FileManager.default.removeItem(at: tempDir) }
        tempDir = nil
        super.tearDown()
    }

    func test_block_新規追加でblockedIdsに反映() {
        let store = TopicBlockStore(directory: tempDir)
        XCTAssertTrue(store.blockedIds.isEmpty)

        store.block("topic_1", reason: .inappropriate)

        XCTAssertEqual(store.blockedIds, ["topic_1"])
        XCTAssertEqual(store.entries.first?.reason, .inappropriate)
    }

    func test_block_同一IDの再登録は重複しない() {
        let store = TopicBlockStore(directory: tempDir)
        store.block("topic_1", reason: .boring)
        store.block("topic_1", reason: .other)

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.reason, .other, "再登録で理由が更新される")
    }

    func test_unblockで除外される() {
        let store = TopicBlockStore(directory: tempDir)
        store.block("topic_1")
        store.block("topic_2")

        store.unblock("topic_1")

        XCTAssertEqual(store.blockedIds, ["topic_2"])
    }

    func test_unblock_未登録IDでもクラッシュしない() {
        let store = TopicBlockStore(directory: tempDir)
        store.unblock("nonexistent")
        XCTAssertTrue(store.blockedIds.isEmpty)
    }

    func test_clearAllで全件削除() {
        let store = TopicBlockStore(directory: tempDir)
        store.block("topic_1")
        store.block("topic_2")
        store.clearAll()

        XCTAssertTrue(store.blockedIds.isEmpty)
    }

    func test_永続化_新インスタンスでも復元() {
        let store1 = TopicBlockStore(directory: tempDir)
        store1.block("topic_1", reason: .inappropriate)

        let store2 = TopicBlockStore(directory: tempDir)
        XCTAssertEqual(store2.blockedIds, ["topic_1"])
        XCTAssertEqual(store2.entries.first?.reason, .inappropriate)
    }

    func test_isBlockedで判定できる() {
        let store = TopicBlockStore(directory: tempDir)
        store.block("topic_1")

        XCTAssertTrue(store.isBlocked("topic_1"))
        XCTAssertFalse(store.isBlocked("topic_2"))
    }

    func test_理由なしでブロックできる() {
        let store = TopicBlockStore(directory: tempDir)
        store.block("topic_1", reason: nil)

        XCTAssertEqual(store.blockedIds, ["topic_1"])
        XCTAssertNil(store.entries.first?.reason)
    }

    func test_空文字IDはブロックされない() {
        let store = TopicBlockStore(directory: tempDir)
        store.block("")
        XCTAssertTrue(store.entries.isEmpty)
    }
}
