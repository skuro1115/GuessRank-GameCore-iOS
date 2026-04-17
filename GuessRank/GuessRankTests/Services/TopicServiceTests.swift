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

    func test_お題は3つの選択肢を持つ() {
        for topic in TopicService.allTopics {
            XCTAssertEqual(topic.choices.count, 3, "Topic \(topic.id) の choices が3つではない")
        }
    }

    func test_全お題のidはユニーク() {
        let ids = TopicService.allTopics.map { $0.id }
        XCTAssertEqual(ids.count, Set(ids).count, "allTopics に id の重複がある")
    }
}
