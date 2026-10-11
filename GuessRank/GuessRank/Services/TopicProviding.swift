import Foundation

protocol TopicProviding {
    /// 指定した乱数生成器を使ってお題を抽選する。
    /// 生成器を注入できるようにすることで、dev_mode の「シード固定」で
    /// 固定シードから同じお題系列を再現できる。
    func pickTopics<G: RandomNumberGenerator>(
        count: Int,
        genre: Genre,
        difficulty: Difficulty,
        playMode: PlayMode,
        excluding: Set<String>,
        using generator: inout G
    ) -> [Topic]

    /// 指定 ID のお題を返す（存在しなければ `nil`）。
    /// dev_mode の「お題固定」で、抽選をバイパスして特定のお題を直接差し込むために使う。
    func topic(withId id: String) -> Topic?
}

extension TopicProviding {
    /// システム乱数を使う簡便版。再現性を必要としない通常の呼び出し元はこちらを使う。
    func pickTopics(
        count: Int,
        genre: Genre,
        difficulty: Difficulty,
        playMode: PlayMode = .normal,
        excluding: Set<String> = []
    ) -> [Topic] {
        var generator = SystemRandomNumberGenerator()
        return pickTopics(
            count: count,
            genre: genre,
            difficulty: difficulty,
            playMode: playMode,
            excluding: excluding,
            using: &generator
        )
    }
}
