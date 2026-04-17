import Foundation

struct TopicService: TopicProviding {
    static let allTopics: [Topic] = [
        // ━━━━━━━━━━ 食べ物 ━━━━━━━━━━
        // easy
        Topic(id: "food_e01", question: "昼に食べたいのは？", choices: ["寿司", "ラーメン", "カレー"], genre: .food, difficulty: .easy),
        Topic(id: "food_e02", question: "おやつに食べたいのは？", choices: ["ケーキ", "ポテチ", "アイス"], genre: .food, difficulty: .easy),
        Topic(id: "food_e03", question: "朝ごはんに食べたいのは？", choices: ["パン", "ごはん", "シリアル"], genre: .food, difficulty: .easy),
        Topic(id: "food_e04", question: "コンビニで買うなら？", choices: ["おにぎり", "サンドイッチ", "肉まん"], genre: .food, difficulty: .easy),
        Topic(id: "food_e05", question: "ファストフードなら？", choices: ["ハンバーガー", "牛丼", "フライドチキン"], genre: .food, difficulty: .easy),
        Topic(id: "food_e06", question: "夏に食べたいのは？", choices: ["かき氷", "そうめん", "スイカ"], genre: .food, difficulty: .easy),
        Topic(id: "food_e07", question: "冬に食べたいのは？", choices: ["鍋", "おでん", "シチュー"], genre: .food, difficulty: .easy),
        // normal
        Topic(id: "food_n01", question: "旅行先で食べたいのは？", choices: ["海鮮丼", "ステーキ", "パスタ"], genre: .food, difficulty: .normal),
        Topic(id: "food_n02", question: "夜食に食べたいのは？", choices: ["おにぎり", "カップ麺", "菓子パン"], genre: .food, difficulty: .normal),
        Topic(id: "food_n03", question: "お祭りで食べたいのは？", choices: ["たこ焼き", "焼きそば", "りんご飴"], genre: .food, difficulty: .normal),
        Topic(id: "food_n04", question: "ご褒美スイーツなら？", choices: ["パフェ", "クレープ", "タピオカ"], genre: .food, difficulty: .normal),
        Topic(id: "food_n05", question: "海外で食べたいのは？", choices: ["ピザ", "タコス", "フォー"], genre: .food, difficulty: .normal),
        Topic(id: "food_n06", question: "居酒屋で最初に頼むのは？", choices: ["枝豆", "唐揚げ", "刺身"], genre: .food, difficulty: .normal),
        Topic(id: "food_n07", question: "丼ものなら？", choices: ["親子丼", "カツ丼", "天丼"], genre: .food, difficulty: .normal),
        // hard
        Topic(id: "food_h01", question: "記念日に食べたいのは？", choices: ["フレンチ", "焼肉", "寿司"], genre: .food, difficulty: .hard),
        Topic(id: "food_h02", question: "二日酔いの朝に食べたいのは？", choices: ["味噌汁", "うどん", "おかゆ"], genre: .food, difficulty: .hard),
        Topic(id: "food_h03", question: "最後の晩餐に食べたいのは？", choices: ["母の手料理", "高級寿司", "ラーメン"], genre: .food, difficulty: .hard),
        Topic(id: "food_h04", question: "嫌いな人が作った料理、食べるなら？", choices: ["見た目が綺麗なもの", "シンプルなもの", "味が濃いもの"], genre: .food, difficulty: .hard),
        Topic(id: "food_h05", question: "一生ひとつしか食べられないなら？", choices: ["米", "パン", "麺"], genre: .food, difficulty: .hard),
        Topic(id: "food_h06", question: "深夜3時に食べたくなるのは？", choices: ["ラーメン", "ポテト", "チョコレート"], genre: .food, difficulty: .hard),
        Topic(id: "food_h07", question: "料理を振る舞うなら？", choices: ["カレー", "パスタ", "チャーハン"], genre: .food, difficulty: .hard),

        // ━━━━━━━━━━ 趣味 ━━━━━━━━━━
        // easy
        Topic(id: "hobby_e01", question: "休日にやりたいのは？", choices: ["映画", "ゲーム", "散歩"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_e02", question: "友達と遊ぶなら？", choices: ["カラオケ", "ボウリング", "ショッピング"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_e03", question: "動画で見るなら？", choices: ["お笑い", "音楽", "ゲーム実況"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_e04", question: "SNSでよく見るのは？", choices: ["写真", "動画", "テキスト"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_e05", question: "雨の日にしたいのは？", choices: ["映画鑑賞", "読書", "ゲーム"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_e06", question: "スポーツするなら？", choices: ["サッカー", "バスケ", "バドミントン"], genre: .hobby, difficulty: .easy),
        Topic(id: "hobby_e07", question: "音楽を聴くなら？", choices: ["J-POP", "洋楽", "アニソン"], genre: .hobby, difficulty: .easy),
        // normal
        Topic(id: "hobby_n01", question: "一人の時間にしたいのは？", choices: ["読書", "音楽鑑賞", "料理"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_n02", question: "新しく始めたい趣味は？", choices: ["筋トレ", "楽器", "絵を描く"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_n03", question: "推し活するなら？", choices: ["ライブ参戦", "グッズ収集", "SNS発信"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_n04", question: "学び直すなら？", choices: ["英語", "プログラミング", "お金の知識"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_n05", question: "ペットを飼うなら？", choices: ["犬", "猫", "うさぎ"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_n06", question: "写真を撮るなら？", choices: ["風景", "食べ物", "人物"], genre: .hobby, difficulty: .normal),
        Topic(id: "hobby_n07", question: "DIYで作るなら？", choices: ["棚", "アクセサリー", "インテリア雑貨"], genre: .hobby, difficulty: .normal),
        // hard
        Topic(id: "hobby_h01", question: "旅行するなら？", choices: ["温泉", "テーマパーク", "大自然"], genre: .hobby, difficulty: .hard),
        Topic(id: "hobby_h02", question: "デートで行きたいのは？", choices: ["水族館", "遊園地", "美術館"], genre: .hobby, difficulty: .hard),
        Topic(id: "hobby_h03", question: "100万円あったら何に使う？", choices: ["旅行", "貯金", "趣味に投資"], genre: .hobby, difficulty: .hard),
        Topic(id: "hobby_h04", question: "才能がもらえるなら？", choices: ["歌唱力", "画力", "運動神経"], genre: .hobby, difficulty: .hard),
        Topic(id: "hobby_h05", question: "異世界に行ったら何する？", choices: ["冒険", "のんびり暮らす", "商売を始める"], genre: .hobby, difficulty: .hard),
        Topic(id: "hobby_h06", question: "バンドを組むなら何担当？", choices: ["ボーカル", "ギター", "ドラム"], genre: .hobby, difficulty: .hard),
        Topic(id: "hobby_h07", question: "YouTuber になるなら？", choices: ["ゲーム実況", "料理", "旅行Vlog"], genre: .hobby, difficulty: .hard),

        // ━━━━━━━━━━ ランダム ━━━━━━━━━━
        // easy
        Topic(id: "random_e01", question: "もらって嬉しいのは？", choices: ["花束", "お菓子", "手紙"], genre: .random, difficulty: .easy),
        Topic(id: "random_e02", question: "朝型？夜型？どっち寄り？", choices: ["完全朝型", "夜型", "どっちでもない"], genre: .random, difficulty: .easy),
        Topic(id: "random_e03", question: "季節で一番好きなのは？", choices: ["春", "夏", "秋"], genre: .random, difficulty: .easy),
        Topic(id: "random_e04", question: "住むなら？", choices: ["都会", "田舎", "郊外"], genre: .random, difficulty: .easy),
        Topic(id: "random_e05", question: "移動手段なら？", choices: ["電車", "車", "自転車"], genre: .random, difficulty: .easy),
        Topic(id: "random_e06", question: "色で一番好きなのは？", choices: ["青", "赤", "緑"], genre: .random, difficulty: .easy),
        Topic(id: "random_e07", question: "連絡手段なら？", choices: ["LINE", "電話", "会って話す"], genre: .random, difficulty: .easy),
        // normal
        Topic(id: "random_n01", question: "生まれ変わるなら？", choices: ["犬", "猫", "鳥"], genre: .random, difficulty: .normal),
        Topic(id: "random_n02", question: "超能力を持つなら？", choices: ["テレパシー", "透明化", "瞬間移動"], genre: .random, difficulty: .normal),
        Topic(id: "random_n03", question: "宝くじが当たったら？", choices: ["旅行三昧", "投資", "家を買う"], genre: .random, difficulty: .normal),
        Topic(id: "random_n04", question: "転職するなら？", choices: ["クリエイター", "起業家", "公務員"], genre: .random, difficulty: .normal),
        Topic(id: "random_n05", question: "時間を止められたら？", choices: ["寝る", "旅行する", "勉強する"], genre: .random, difficulty: .normal),
        Topic(id: "random_n06", question: "友達に求めるのは？", choices: ["面白さ", "優しさ", "頼もしさ"], genre: .random, difficulty: .normal),
        Topic(id: "random_n07", question: "学校の科目なら？", choices: ["体育", "音楽", "美術"], genre: .random, difficulty: .normal),
        // hard
        Topic(id: "random_h01", question: "無人島に持っていくなら？", choices: ["ナイフ", "ライター", "ロープ"], genre: .random, difficulty: .hard),
        Topic(id: "random_h02", question: "タイムマシンで行くなら？", choices: ["過去", "未来", "別の時代の日本"], genre: .random, difficulty: .hard),
        Topic(id: "random_h03", question: "大事にしたい価値観は？", choices: ["自由", "安定", "挑戦"], genre: .random, difficulty: .hard),
        Topic(id: "random_h04", question: "人生で一番大切なのは？", choices: ["健康", "お金", "人間関係"], genre: .random, difficulty: .hard),
        Topic(id: "random_h05", question: "子供に伝えたいことは？", choices: ["努力の大切さ", "人への思いやり", "自分らしさ"], genre: .random, difficulty: .hard),
        Topic(id: "random_h06", question: "死ぬまでにしたいことは？", choices: ["世界一周", "本を出す", "家族と過ごす"], genre: .random, difficulty: .hard),
        Topic(id: "random_h07", question: "AI に任せたいことは？", choices: ["家事", "仕事", "勉強"], genre: .random, difficulty: .hard),
    ]

    func pickTopics(count: Int, genre: Genre, difficulty: Difficulty) -> [Topic] {
        let pool: [Topic]
        if genre == .random {
            pool = Self.allTopics
        } else {
            pool = Self.allTopics.filter { $0.genre == genre }
        }
        return Array(pool.shuffled().prefix(count))
    }
}
