import XCTest
@testable import GuessRankCore

final class PlayModeTests: XCTestCase {
    func test_choiceCount_normalは3() {
        XCTAssertEqual(PlayMode.normal.choiceCount, 3)
    }

    func test_choiceCount_hardは6() {
        XCTAssertEqual(PlayMode.hard.choiceCount, 6)
    }

    func test_rankSlotCount_両モード共通で3() {
        XCTAssertEqual(PlayMode.normal.rankSlotCount, 3)
        XCTAssertEqual(PlayMode.hard.rankSlotCount, 3)
    }

    func test_displayName() {
        XCTAssertEqual(PlayMode.normal.displayName, "ノーマル")
        XCTAssertEqual(PlayMode.hard.displayName, "ハード")
    }

    func test_Codable() throws {
        for mode in PlayMode.allCases {
            let data = try JSONEncoder().encode(mode)
            let decoded = try JSONDecoder().decode(PlayMode.self, from: data)
            XCTAssertEqual(decoded, mode)
        }
    }
}
