import XCTest
@testable import GuessRankCore

final class TopicServiceTests: XCTestCase {
    func test_food絞り込みは全てfoodジャンル() {
        let topics = TopicService().pickTopics(count: 3, genre: .food, difficulty: .easy)
        XCTAssertEqual(topics.count, 3)
        XCTAssertTrue(topics.allSatisfy { $0.genre == .food })
    }

    func test_hobby絞り込みは全てhobbyジャンル() {
        let topics = TopicService().pickTopics(count: 3, genre: .hobby, difficulty: .normal)
        XCTAssertEqual(topics.count, 3)
        XCTAssertTrue(topics.allSatisfy { $0.genre == .hobby })
    }

    func test_random指定は全ジャンルから選出() {
        // .random は allTopics 全件から選ぶ（フィルタなし）
        let topics = TopicService().pickTopics(count: 10, genre: .random, difficulty: .easy)
        XCTAssertEqual(topics.count, 10)
        // 全件から10件取れる = allTopics に10件以上ある
    }

    func test_count指定より多くは返さない() {
        let topics = TopicService().pickTopics(count: 2, genre: .food, difficulty: .easy)
        XCTAssertLessThanOrEqual(topics.count, 2)
    }

    func test_countがプール以上なら全件を返す() {
        // food ジャンルの最大数を超えるリクエストでもクラッシュしない
        let topics = TopicService().pickTopics(count: 1000, genre: .food, difficulty: .easy)
        XCTAssertTrue(topics.allSatisfy { $0.genre == .food })
    }

    func test_選出されたお題に重複はない() {
        let topics = TopicService().pickTopics(count: 5, genre: .random, difficulty: .easy)
        let ids = topics.map { $0.id }
        XCTAssertEqual(ids.count, Set(ids).count, "選出された Topic.id に重複があってはいけない")
    }

    func test_お題のchoices数はplayModeと一致する() {
        for topic in TopicService.allTopics {
            XCTAssertEqual(
                topic.choices.count,
                topic.playMode.choiceCount,
                "Topic \(topic.id) (\(topic.playMode)) の choices 数が期待値と一致しない"
            )
        }
    }

    func test_全お題のidはユニーク() {
        let ids = TopicService.allTopics.map { $0.id }
        XCTAssertEqual(ids.count, Set(ids).count, "allTopics に id の重複がある")
    }

    func test_excluding指定したIDは選ばれない() {
        let excluded: Set<String> = ["food_e01", "food_e02", "food_e03"]
        let topics = TopicService().pickTopics(count: 5, genre: .food, difficulty: .easy, excluding: excluded)
        for topic in topics {
            XCTAssertFalse(excluded.contains(topic.id), "除外IDが選ばれている: \(topic.id)")
        }
    }

    func test_excluding空はデフォルト挙動と等価() {
        let withEmpty = TopicService().pickTopics(count: 3, genre: .food, difficulty: .easy, excluding: [])
        let withDefault = TopicService().pickTopics(count: 3, genre: .food, difficulty: .easy)
        XCTAssertEqual(withEmpty.count, withDefault.count)
        XCTAssertTrue(withEmpty.allSatisfy { $0.genre == .food })
    }

    func test_全候補が除外されたらフォールバックで返す() {
        let foodIds = Set(TopicService.allTopics.filter { $0.genre == .food }.map { $0.id })
        let topics = TopicService().pickTopics(count: 3, genre: .food, difficulty: .easy, excluding: foodIds)
        // フィルタ後が空でもクラッシュせず、お題を返す（ゲーム継続を優先）
        XCTAssertFalse(topics.isEmpty)
        XCTAssertTrue(topics.allSatisfy { $0.genre == .food })
    }

    func test_playMode_normal指定はhardモードを除外する() {
        let topics = TopicService().pickTopics(
            count: 50,
            genre: .random,
            difficulty: .normal,
            playMode: .normal,
            excluding: []
        )
        XCTAssertFalse(topics.isEmpty)
        XCTAssertTrue(topics.allSatisfy { $0.playMode == .normal })
    }

    func test_playMode_hard指定はnormalモードを除外する() {
        let topics = TopicService().pickTopics(
            count: 50,
            genre: .random,
            difficulty: .normal,
            playMode: .hard,
            excluding: []
        )
        XCTAssertFalse(topics.isEmpty, "ハードモードのお題が登録されている前提")
        XCTAssertTrue(topics.allSatisfy { $0.playMode == .hard })
        XCTAssertTrue(topics.allSatisfy { $0.choices.count == 6 })
    }

    func test_totalTopicCountはallTopicsのcountと一致() {
        XCTAssertEqual(TopicService.totalTopicCount, TopicService.allTopics.count)
    }

    // MARK: - Seed-fixing (再現可能なお題抽選)

    func test_同じseedは同じお題系列を返す() {
        func pick() -> [String] {
            var rng = SeededRandomNumberGenerator(seed: 2024)
            return TopicService().pickTopics(
                count: 8, genre: .random, difficulty: .normal,
                playMode: .normal, excluding: [], using: &rng
            ).map(\.id)
        }
        XCTAssertEqual(pick(), pick(), "同じシードなら同じお題・同じ順序になるべき")
    }

    func test_異なるseedは概ね異なるお題系列を返す() {
        func pick(_ seed: UInt64) -> [String] {
            var rng = SeededRandomNumberGenerator(seed: seed)
            return TopicService().pickTopics(
                count: 8, genre: .random, difficulty: .normal,
                playMode: .normal, excluding: [], using: &rng
            ).map(\.id)
        }
        XCTAssertNotEqual(pick(1), pick(2))
    }
}
