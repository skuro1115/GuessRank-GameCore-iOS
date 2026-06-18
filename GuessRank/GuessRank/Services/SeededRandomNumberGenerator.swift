import Foundation

/// 決定的な擬似乱数生成器（SplitMix64）。
///
/// 同じ seed からは常に同じ系列を生成するため、dev_mode の「シード固定」で
/// お題抽選を再現可能にするのに使う。SplitMix64 は seed 0 でも偏りのない
/// 出力を返すので、UserDefaults の既定値（0）をそのまま seed にできる。
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// お題抽選で使う RNG。`seed` が与えられれば決定的（`SeededRandomNumberGenerator`）、
/// `nil` ならシステム乱数にフォールバックする。`GameProgressViewModel` が
/// 1ゲーム分の抽選系列を進めるために保持する。
struct TopicRandomNumberGenerator: RandomNumberGenerator {
    private var seeded: SeededRandomNumberGenerator?
    private var system = SystemRandomNumberGenerator()

    init(seed: UInt64?) {
        if let seed {
            seeded = SeededRandomNumberGenerator(seed: seed)
        }
    }

    mutating func next() -> UInt64 {
        if seeded != nil {
            return seeded!.next()
        }
        return system.next()
    }
}
