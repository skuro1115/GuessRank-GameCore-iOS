import Foundation

enum TopicService {
    static let allTopics: [Topic] = [
        // 食べ物
        Topic(id: "food_01", question: "昼に食べたいのは？", choices: ["寿司", "ラーメン", "カレー"], genre: .food, difficulty: .easy),
        Topic(id: "food_02", question: "おやつに食べたいのは？", choices: ["ケーキ", "ポテチ", "アイス"], genre: .food, difficulty: .easy),
        Topic(id: "food_03", question: "旅行先で食べたいのは？", choices: ["海鮮丼", "ステーキ", "パスタ"], genre: .food, difficulty: .normal),
        Topic(id: "food_04", question: "夜食に食べたいのは？", choices: ["おにぎり", "カップ麺", "菓子パン"], genre: .food, difficulty: .normal),
        Topic(id: "food_05", question: "記念日に食べたいのは？", choices: ["フレンチ", "焼肉", "寿司"], genre: .food, difficulty: .hard),
        Topic(id: "food_06", question: "二日酔いの朝に食べたいのは？", choices: ["味噌汁", "うどん", "おかゆ"], genre: .food, difficulty: .hard),

        // 趣味
        Topic(id: "hobby_01", question: "休日にやりたいのは？", choices: ["映画", "ゲーム", "散歩"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_02", question: "友達と遊ぶなら？", choices: ["カラオケ", "ボウリング", "ショッピング"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_03", question: "一人の時間にしたいのは？", choices: ["読書", "音楽鑑賞", "料理"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_04", question: "新しく始めたい趣味は？", choices: ["筋トレ", "楽器", "絵を描く"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_05", question: "旅行するなら？", choices: ["温泉", "テーマパーク", "自然"], genre: .hobby, difficulty: .hard),
        Topic(id: "hobby_06", question: "デートで行きたいのは？", choices: ["水族館", "遊園地", "美術館"], genre: .hobby, difficulty: .hard),

        // ランダム
        Topic(id: "random_01", question: "もらって嬉しいのは？", choices: ["花束", "お菓子", "手紙"], genre: .random, difficulty: .easy),
        Topic(id: "random_02", question: "生まれ変わるなら？", choices: ["犬", "猫", "鳥"], genre: .random, difficulty: .normal),
        Topic(id: "random_03", question: "超能力を持つなら？", choices: ["テレパシー", "透明化", "瞬間移動"], genre: .random, difficulty: .normal),
        Topic(id: "random_04", question: "無人島に持っていくなら？", choices: ["ナイフ", "ライター", "ロープ"], genre: .random, difficulty: .hard),
        Topic(id: "random_05", question: "タイムマシンで行くなら？", choices: ["過去", "未来", "別の時代の日本"], genre: .random, difficulty: .hard),
        Topic(id: "random_06", question: "大事にしたい価値観は？", choices: ["自由", "安定", "挑戦"], genre: .random, difficulty: .hard),
    ]

    static func pickTopics(count: Int, genre: Genre, difficulty: Difficulty) -> [Topic] {
        let pool: [Topic]
        if genre == .random {
            pool = allTopics
        } else {
            pool = allTopics.filter { $0.genre == genre }
        }
        return Array(pool.shuffled().prefix(count))
    }
}
