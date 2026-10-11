import XCTest
@testable import GuessRankCore

final class SeededRandomNumberGeneratorTests: XCTestCase {
    private func sequence(seed: UInt64, count: Int = 16) -> [UInt64] {
        var rng = SeededRandomNumberGenerator(seed: seed)
        return (0..<count).map { _ in rng.next() }
    }

    func test_同じseedは同じ系列を生成する() {
        XCTAssertEqual(sequence(seed: 42), sequence(seed: 42))
    }

    func test_異なるseedは異なる系列を生成する() {
        XCTAssertNotEqual(sequence(seed: 1), sequence(seed: 2))
    }

    func test_seed0でも非自明な出力を返す() {
        // SplitMix64 は seed 0 でも 0 を連発しない（xorshift 系の弱点を回避）。
        let seq = sequence(seed: 0)
        XCTAssertFalse(seq.allSatisfy { $0 == 0 }, "seed 0 で 0 ばかりになってはいけない")
        XCTAssertEqual(Set(seq).count, seq.count, "16 連続で重複が出るのは異常")
    }

    func test_配列shuffleが同じseedで再現する() {
        let base = Array(1...50)
        var a = SeededRandomNumberGenerator(seed: 7)
        var b = SeededRandomNumberGenerator(seed: 7)
        XCTAssertEqual(base.shuffled(using: &a), base.shuffled(using: &b))
    }

    // MARK: - TopicRandomNumberGenerator wrapper

    func test_wrapper_seedありは決定的() {
        func seq() -> [UInt64] {
            var rng = TopicRandomNumberGenerator(seed: 99)
            return (0..<8).map { _ in rng.next() }
        }
        XCTAssertEqual(seq(), seq())
    }

    func test_wrapper_seedありはSeededと同じ系列() {
        var wrapper = TopicRandomNumberGenerator(seed: 123)
        var seeded = SeededRandomNumberGenerator(seed: 123)
        let lhs = (0..<8).map { _ in wrapper.next() }
        let rhs = (0..<8).map { _ in seeded.next() }
        XCTAssertEqual(lhs, rhs)
    }
}
