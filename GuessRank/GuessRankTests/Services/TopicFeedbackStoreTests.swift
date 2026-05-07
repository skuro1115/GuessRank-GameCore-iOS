import XCTest
@testable import GuessRankCore

final class TopicFeedbackStoreTests: XCTestCase {
    private var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("topic_feedback_tests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        if let tempDir { try? FileManager.default.removeItem(at: tempDir) }
        tempDir = nil
        super.tearDown()
    }

    // MARK: - Block

    func test_block_新規追加でblockedIdsに反映() {
        let store = TopicFeedbackStore(directory: tempDir)
        XCTAssertTrue(store.blockedIds.isEmpty)

        store.block("topic_1", reason: .inappropriate)

        XCTAssertEqual(store.blockedIds, ["topic_1"])
        XCTAssertEqual(store.blockedEntries.first?.blockReason, .inappropriate)
    }

    func test_block_同一IDの再登録は重複しない() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("topic_1", reason: .boring)
        store.block("topic_1", reason: .other)

        XCTAssertEqual(store.blockedEntries.count, 1)
        XCTAssertEqual(store.blockedEntries.first?.blockReason, .other, "再登録で理由が更新される")
    }

    func test_unblockで除外される() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("topic_1")
        store.block("topic_2")

        store.unblock("topic_1")

        XCTAssertEqual(store.blockedIds, ["topic_2"])
    }

    func test_unblock_未登録IDでもクラッシュしない() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.unblock("nonexistent")
        XCTAssertTrue(store.blockedIds.isEmpty)
    }

    func test_clearBlocksでブロックのみ削除() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("topic_1")
        store.block("topic_2")
        store.like("topic_3")

        store.clearBlocks()

        XCTAssertTrue(store.blockedIds.isEmpty)
        XCTAssertEqual(store.likedIds, ["topic_3"], "likeは残る")
    }

    func test_clearAllで全件削除() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("topic_1")
        store.like("topic_2")
        store.clearAll()

        XCTAssertTrue(store.blockedIds.isEmpty)
        XCTAssertTrue(store.likedIds.isEmpty)
    }

    func test_永続化_新インスタンスでも復元() {
        let store1 = TopicFeedbackStore(directory: tempDir)
        store1.block("topic_1", reason: .inappropriate)
        store1.like("topic_2")

        let store2 = TopicFeedbackStore(directory: tempDir)
        XCTAssertEqual(store2.blockedIds, ["topic_1"])
        XCTAssertEqual(store2.likedIds, ["topic_2"])
        XCTAssertEqual(store2.blockedEntries.first?.blockReason, .inappropriate)
    }

    func test_isBlockedで判定できる() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("topic_1")

        XCTAssertTrue(store.isBlocked("topic_1"))
        XCTAssertFalse(store.isBlocked("topic_2"))
    }

    func test_理由なしでブロックできる() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("topic_1", reason: nil)

        XCTAssertEqual(store.blockedIds, ["topic_1"])
        XCTAssertNil(store.blockedEntries.first?.blockReason)
    }

    func test_空文字IDはブロックされない() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("")
        XCTAssertTrue(store.entries.isEmpty)
    }

    // MARK: - Like

    func test_like_新規追加でlikedIdsに反映() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.like("topic_1")

        XCTAssertEqual(store.likedIds, ["topic_1"])
        XCTAssertTrue(store.isLiked("topic_1"))
    }

    func test_like_同一IDの再登録は重複しない() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.like("topic_1")
        store.like("topic_1")

        XCTAssertEqual(store.likedEntries.count, 1)
    }

    func test_unlikeで除外される() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.like("topic_1")
        store.unlike("topic_1")

        XCTAssertFalse(store.isLiked("topic_1"))
    }

    func test_blockとlikeは独立して共存できる() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.block("topic_1")
        store.like("topic_1")

        XCTAssertTrue(store.isBlocked("topic_1"))
        XCTAssertTrue(store.isLiked("topic_1"))
        XCTAssertEqual(store.entries.count, 2)
    }

    func test_空文字IDはlikeされない() {
        let store = TopicFeedbackStore(directory: tempDir)
        store.like("")
        XCTAssertTrue(store.entries.isEmpty)
    }

    // MARK: - Migration

    func test_旧topic_blocks_jsonからの移行() throws {
        struct LegacyBlockedTopic: Codable {
            let topicId: String
            let reason: TopicBlockReason?
            let blockedAt: Date
        }
        let legacy = [
            LegacyBlockedTopic(topicId: "old_1", reason: .boring, blockedAt: Date(timeIntervalSince1970: 1000)),
            LegacyBlockedTopic(topicId: "old_2", reason: nil, blockedAt: Date(timeIntervalSince1970: 2000))
        ]
        let legacyURL = tempDir.appendingPathComponent("topic_blocks.json")
        let data = try JSONEncoder().encode(legacy)
        try data.write(to: legacyURL)

        let store = TopicFeedbackStore(directory: tempDir)

        XCTAssertEqual(store.blockedIds, ["old_1", "old_2"])
        XCTAssertEqual(
            store.blockedEntries.first(where: { $0.topicId == "old_1" })?.blockReason,
            .boring
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: legacyURL.path), "移行後は旧ファイルが削除される")
    }
}
