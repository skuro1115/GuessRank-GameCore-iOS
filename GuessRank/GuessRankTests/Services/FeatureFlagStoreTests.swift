import XCTest
@testable import GuessRankCore

final class FeatureFlagStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suiteName = "FeatureFlagStoreTests.\(UUID().uuidString)"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    // MARK: - Defaults

    func test_isEnabled_上書きなしの場合はビルドデフォルトを返す() {
        let store = FeatureFlagStore(defaults: defaults)
        for flag in FeatureFlag.allCases {
            XCTAssertEqual(
                store.isEnabled(flag),
                FeatureFlagStore.buildDefault(for: flag),
                "\(flag): build default と一致するべき"
            )
        }
    }

    func test_buildDefault_DEBUG時はdebugDefaultを返す() {
        // この test は DEBUG ビルド前提（swift test は DEBUG）
        for flag in FeatureFlag.allCases {
            XCTAssertEqual(
                FeatureFlagStore.buildDefault(for: flag),
                flag.debugDefault
            )
        }
    }

    // MARK: - Override

    func test_setEnabled_上書きが反映される() {
        let store = FeatureFlagStore(defaults: defaults)
        store.setEnabled(.devModeEnabled, false)

        XCTAssertFalse(store.isEnabled(.devModeEnabled))
    }

    func test_setEnabled_永続化される() {
        let store1 = FeatureFlagStore(defaults: defaults)
        store1.setEnabled(.quickStartEnabled, false)

        let store2 = FeatureFlagStore(defaults: defaults)
        XCTAssertFalse(store2.isEnabled(.quickStartEnabled), "別インスタンスでも復元される")
    }

    func test_hasOverride_上書き有無を判定できる() {
        let store = FeatureFlagStore(defaults: defaults)
        XCTAssertFalse(store.hasOverride(.devModeEnabled))

        store.setEnabled(.devModeEnabled, false)
        XCTAssertTrue(store.hasOverride(.devModeEnabled))
    }

    // MARK: - Reset

    func test_reset_デフォルトに戻る() {
        let store = FeatureFlagStore(defaults: defaults)
        store.setEnabled(.devModeEnabled, false)
        store.reset(.devModeEnabled)

        XCTAssertEqual(store.isEnabled(.devModeEnabled), FeatureFlagStore.buildDefault(for: .devModeEnabled))
        XCTAssertFalse(store.hasOverride(.devModeEnabled))
    }

    func test_resetAll_全フラグの上書きを破棄() {
        let store = FeatureFlagStore(defaults: defaults)
        for flag in FeatureFlag.allCases {
            store.setEnabled(flag, !FeatureFlagStore.buildDefault(for: flag))
        }
        store.resetAll()

        for flag in FeatureFlag.allCases {
            XCTAssertFalse(store.hasOverride(flag), "\(flag): 上書きが残っている")
        }
    }

    // MARK: - Animation speed

    func test_animationSpeedMultiplier_fastModeOFFは1x() {
        let store = FeatureFlagStore(defaults: defaults)
        store.setEnabled(.fastModeEnabled, false)
        XCTAssertEqual(store.animationSpeedMultiplier, 1.0)
    }

    func test_animationSpeedMultiplier_fastModeONは4x() {
        let store = FeatureFlagStore(defaults: defaults)
        store.setEnabled(.fastModeEnabled, true)
        XCTAssertEqual(store.animationSpeedMultiplier, 4.0)
    }

    func test_scaledDuration_fastModeONで4分の1() {
        let store = FeatureFlagStore(defaults: defaults)
        store.setEnabled(.fastModeEnabled, true)
        XCTAssertEqual(store.scaledDuration(2.0), 0.5, accuracy: 0.001)
        XCTAssertEqual(store.scaledDuration(0.45), 0.1125, accuracy: 0.001)
    }

    func test_scaledDuration_fastModeOFFで等倍() {
        let store = FeatureFlagStore(defaults: defaults)
        store.setEnabled(.fastModeEnabled, false)
        XCTAssertEqual(store.scaledDuration(1.5), 1.5, accuracy: 0.001)
    }

    // MARK: - 新規フラグの defaults

    func test_新規フラグもbuildDefaultが反映される() {
        let store = FeatureFlagStore(defaults: defaults)
        // DEBUG ビルド前提
        XCTAssertTrue(store.isEnabled(.dataResetEnabled), "dataResetEnabled は DEBUG で true")
        XCTAssertFalse(store.isEnabled(.fastModeEnabled), "fastModeEnabled は DEBUG で false（明示的にユーザーが ON にする想定）")
    }
}
