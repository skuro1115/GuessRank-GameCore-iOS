import XCTest
@testable import GuessRankCore

final class GameSetupViewModelTests: XCTestCase {
    func test_sanitizeは前後空白を除去() {
        let vm = GameSetupViewModel()
        XCTAssertEqual(vm.sanitize("  太郎  "), "太郎")
    }

    func test_sanitizeは改行を除去() {
        let vm = GameSetupViewModel()
        XCTAssertEqual(vm.sanitize("太\n郎"), "太郎")
        XCTAssertEqual(vm.sanitize("太\r郎"), "太郎")
    }

    func test_sanitizeは最大文字数で切り詰め() {
        let vm = GameSetupViewModel()
        let longName = String(repeating: "あ", count: 20)
        let result = vm.sanitize(longName)
        XCTAssertEqual(result.count, GameSetupViewModel.maxNameLength)
    }

    func test_canStartGameは全名前入力で重複なしならtrue() {
        let vm = GameSetupViewModel()
        vm.playerNames = ["A", "B", "C"]
        XCTAssertTrue(vm.canStartGame)
    }

    func test_canStartGameは空名前があるとfalse() {
        let vm = GameSetupViewModel()
        vm.playerNames = ["A", "", "C"]
        XCTAssertFalse(vm.canStartGame)
    }

    func test_canStartGameは重複名前でfalse() {
        let vm = GameSetupViewModel()
        vm.playerNames = ["A", "A", "C"]
        XCTAssertFalse(vm.canStartGame)
    }

    func test_canStartGameは空白のみの名前をfalse() {
        let vm = GameSetupViewModel()
        vm.playerNames = ["A", "   ", "C"]
        XCTAssertFalse(vm.canStartGame)
    }

    func test_updatePlayerCountで人数が増えるとフィールド追加() {
        let vm = GameSetupViewModel()
        vm.playerNames = ["A", "B", "C"]
        vm.updatePlayerCount(5)
        XCTAssertEqual(vm.playerNames.count, 5)
        XCTAssertEqual(vm.playerNames[0], "A")
    }

    func test_updatePlayerCountで人数が減ると末尾削除() {
        let vm = GameSetupViewModel()
        vm.playerNames = ["A", "B", "C"]
        vm.updatePlayerCount(2)
        XCTAssertEqual(vm.playerNames, ["A", "B"])
    }

    // MARK: - Estimated time

    func test_estimatedSeconds_2人1サイクル() {
        let vm = GameSetupViewModel()
        vm.playerCount = 2
        vm.cycleCount = 1
        // 1ターン = 2人 × 15秒 + 10秒 = 40秒
        // 総ターン数 = 2 × 1 = 2
        // 合計 = 80秒
        XCTAssertEqual(vm.estimatedSeconds, 80)
    }

    func test_estimatedSeconds_4人1サイクル() {
        let vm = GameSetupViewModel()
        vm.playerCount = 4
        vm.cycleCount = 1
        // 1ターン = 4×15 + 10 = 70秒、総ターン4 → 280秒
        XCTAssertEqual(vm.estimatedSeconds, 280)
    }

    func test_estimatedSeconds_6人3サイクル() {
        let vm = GameSetupViewModel()
        vm.playerCount = 6
        vm.cycleCount = 3
        // 1ターン = 6×15 + 10 = 100秒、総ターン18 → 1800秒
        XCTAssertEqual(vm.estimatedSeconds, 1800)
    }

    func test_estimatedTimeText_秒余りなしは分のみ表示() {
        let vm = GameSetupViewModel()
        vm.playerCount = 6
        vm.cycleCount = 3 // 1800秒 = 30分
        XCTAssertEqual(vm.estimatedTimeText, "約30分")
    }

    func test_estimatedTimeText_秒余りありは分秒表示() {
        let vm = GameSetupViewModel()
        vm.playerCount = 4
        vm.cycleCount = 1 // 280秒 = 4分40秒
        XCTAssertEqual(vm.estimatedTimeText, "約4分40秒")
    }
}
