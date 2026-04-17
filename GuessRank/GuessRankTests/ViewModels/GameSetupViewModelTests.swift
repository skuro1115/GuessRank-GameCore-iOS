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
}
