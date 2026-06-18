import Foundation

struct TopicService: TopicProviding {
    /// Total number of topics in the bundled pool. Used by the UI to detect
    /// "全てプレイ済み" exhaustion against TopicHistoryStore.
    static var totalTopicCount: Int { allTopics.count }

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

        // ━━━━━━━━━━ 学生あるある ━━━━━━━━━━
        // easy
        Topic(id: "school_e01", question: "学校で一番好きだった時間は？", choices: ["昼休み", "放課後", "体育の時間"], genre: .school, difficulty: .easy),
        Topic(id: "school_e02", question: "授業中にやりがちだったのは？", choices: ["居眠り", "落書き", "手紙回し"], genre: .school, difficulty: .easy),
        Topic(id: "school_e03", question: "学校の購買で買ってたのは？", choices: ["パン", "ジュース", "アイス"], genre: .school, difficulty: .easy),
        Topic(id: "school_e04", question: "席替えで当たりだと思うのは？", choices: ["窓際の後ろ", "友達の隣", "前の方"], genre: .school, difficulty: .easy),
        Topic(id: "school_e05", question: "好きだった給食メニューは？", choices: ["揚げパン", "カレー", "冷凍みかん"], genre: .school, difficulty: .easy),
        Topic(id: "school_e06", question: "学校行事で好きだったのは？", choices: ["文化祭", "体育祭", "修学旅行"], genre: .school, difficulty: .easy),
        Topic(id: "school_e07", question: "部活で入りたかったのは？", choices: ["運動部", "文化部", "帰宅部"], genre: .school, difficulty: .easy),
        // normal
        Topic(id: "school_n01", question: "テスト前日あるある、どれ？", choices: ["急に部屋を掃除", "徹夜で詰め込み", "諦めて寝る"], genre: .school, difficulty: .normal),
        Topic(id: "school_n02", question: "先生のモノマネ、誰の？", choices: ["怒り方が独特な先生", "口癖がある先生", "動きが面白い先生"], genre: .school, difficulty: .normal),
        Topic(id: "school_n03", question: "修学旅行の夜にやるのは？", choices: ["恋バナ", "枕投げ", "こっそり夜更かし"], genre: .school, difficulty: .normal),
        Topic(id: "school_n04", question: "学校でちょっとした英雄になれるのは？", choices: ["先生に反論して勝つ", "忘れ物を全員分カバー", "授業を脱線させる"], genre: .school, difficulty: .normal),
        Topic(id: "school_n05", question: "学校で一番テンション上がった瞬間は？", choices: ["授業が自習になった時", "好きな人と同じ班", "先生が休みの連絡"], genre: .school, difficulty: .normal),
        Topic(id: "school_n06", question: "学生時代にやっておけばよかったのは？", choices: ["もっと勉強", "もっと遊ぶ", "告白"], genre: .school, difficulty: .normal),
        Topic(id: "school_n07", question: "クラスにいたキャラといえば？", choices: ["いじられキャラ", "ムードメーカー", "謎に詳しいやつ"], genre: .school, difficulty: .normal),
        // hard
        Topic(id: "school_h01", question: "学生時代の黒歴史、どのタイプ？", choices: ["痛いSNS投稿", "謎のファッション", "中二病ポエム"], genre: .school, difficulty: .hard),
        Topic(id: "school_h02", question: "卒業式で泣いた理由は？", choices: ["友達との別れ", "先生の言葉", "泣いてない"], genre: .school, difficulty: .hard),
        Topic(id: "school_h03", question: "学生時代に戻れるなら何する？", choices: ["もっと恋愛する", "友達を大事にする", "将来の準備をする"], genre: .school, difficulty: .hard),
        Topic(id: "school_h04", question: "学校で一番緊張した場面は？", choices: ["好きな人への告白", "全校生徒の前で発表", "成績表を親に見せる"], genre: .school, difficulty: .hard),
        Topic(id: "school_h05", question: "担任に言われて刺さった一言は？", choices: ["お前は変わった", "期待してるぞ", "もっとやれるだろ"], genre: .school, difficulty: .hard),
        Topic(id: "school_h06", question: "学生時代の自分に一言言うなら？", choices: ["そのままでいい", "もっと自信持て", "その友達大事にしろ"], genre: .school, difficulty: .hard),
        Topic(id: "school_h07", question: "文化祭で一番キツかったのは？", choices: ["準備の徹夜", "クラスの揉め事", "出し物が滑った"], genre: .school, difficulty: .hard),

        // ━━━━━━━━━━ 恋愛 ━━━━━━━━━━
        // easy
        Topic(id: "love_e01", question: "デートで行きたい場所は？", choices: ["カフェ", "水族館", "映画館"], genre: .love, difficulty: .easy),
        Topic(id: "love_e02", question: "好きなタイプは？", choices: ["面白い人", "優しい人", "かっこいい・かわいい人"], genre: .love, difficulty: .easy),
        Topic(id: "love_e03", question: "恋人からのプレゼント、嬉しいのは？", choices: ["手紙", "アクセサリー", "サプライズ体験"], genre: .love, difficulty: .easy),
        Topic(id: "love_e04", question: "告白するなら？", choices: ["直接会って", "電話で", "LINEで"], genre: .love, difficulty: .easy),
        Topic(id: "love_e05", question: "恋人とのお揃い、アリなのは？", choices: ["スマホケース", "リング", "絶対ナシ"], genre: .love, difficulty: .easy),
        Topic(id: "love_e06", question: "恋のきっかけになるのは？", choices: ["一緒に笑った時", "助けてもらった時", "ギャップを見た時"], genre: .love, difficulty: .easy),
        Topic(id: "love_e07", question: "連絡頻度の理想は？", choices: ["毎日何回も", "1日1回", "用事がある時だけ"], genre: .love, difficulty: .easy),
        // normal
        Topic(id: "love_n01", question: "恋人に一番求めるものは？", choices: ["信頼感", "ドキドキ感", "居心地の良さ"], genre: .love, difficulty: .normal),
        Topic(id: "love_n02", question: "別れる原因になりそうなのは？", choices: ["価値観の違い", "連絡が減る", "浮気"], genre: .love, difficulty: .normal),
        Topic(id: "love_n03", question: "恋人の嫉妬、どう思う？", choices: ["嬉しい", "重い", "程度による"], genre: .love, difficulty: .normal),
        Topic(id: "love_n04", question: "遠距離恋愛で大事なのは？", choices: ["こまめな連絡", "会える時に全力", "信じて待つ"], genre: .love, difficulty: .normal),
        Topic(id: "love_n05", question: "友達の恋愛相談、何を重視する？", choices: ["共感する", "本音を言う", "一緒に考える"], genre: .love, difficulty: .normal),
        Topic(id: "love_n06", question: "理想のプロポーズは？", choices: ["ロマンチックな演出", "日常の中でさりげなく", "二人きりの場所で"], genre: .love, difficulty: .normal),
        Topic(id: "love_n07", question: "恋人との喧嘩、先に謝るのは？", choices: ["自分から", "相手から待つ", "時間が解決"], genre: .love, difficulty: .normal),
        // hard
        Topic(id: "love_h01", question: "元カレ・元カノとの思い出の品、どうする？", choices: ["捨てる", "取っておく", "見えない場所にしまう"], genre: .love, difficulty: .hard),
        Topic(id: "love_h02", question: "恋人の秘密、知りたい？", choices: ["全部知りたい", "知らなくていい", "聞かれたら答えてほしい"], genre: .love, difficulty: .hard),
        Topic(id: "love_h03", question: "浮気の境界線は？", choices: ["二人きりで食事", "手をつなぐ", "気持ちが動いた時点"], genre: .love, difficulty: .hard),
        Topic(id: "love_h04", question: "愛と恋の違いって？", choices: ["時間の長さ", "相手を思う深さ", "覚悟の有無"], genre: .love, difficulty: .hard),
        Topic(id: "love_h05", question: "恋愛で一番辛いのは？", choices: ["片思い", "すれ違い", "失恋"], genre: .love, difficulty: .hard),
        Topic(id: "love_h06", question: "好きな人の親友があなたに告白。どうする？", choices: ["断る", "好きな人に相談", "気持ちを受け止める"], genre: .love, difficulty: .hard),
        Topic(id: "love_h07", question: "結婚相手に一番大事なのは？", choices: ["価値観が合う", "一緒にいて楽", "経済力"], genre: .love, difficulty: .hard),

        // ━━━━━━━━━━ 性格・価値観 ━━━━━━━━━━
        // easy
        Topic(id: "pers_e01", question: "自分はどっちかというと？", choices: ["インドア派", "アウトドア派", "気分次第"], genre: .personality, difficulty: .easy),
        Topic(id: "pers_e02", question: "ストレス発散法は？", choices: ["食べる", "寝る", "人と話す"], genre: .personality, difficulty: .easy),
        Topic(id: "pers_e03", question: "約束の時間、どうしがち？", choices: ["早めに着く", "ギリギリ", "たまに遅刻"], genre: .personality, difficulty: .easy),
        Topic(id: "pers_e04", question: "買い物スタイルは？", choices: ["即決", "めちゃ悩む", "口コミを調べまくる"], genre: .personality, difficulty: .easy),
        Topic(id: "pers_e05", question: "旅行の計画は？", choices: ["しっかり立てる", "ノープラン", "ざっくりだけ決める"], genre: .personality, difficulty: .easy),
        Topic(id: "pers_e06", question: "人見知りする？", choices: ["結構する", "全然しない", "最初だけ"], genre: .personality, difficulty: .easy),
        Topic(id: "pers_e07", question: "SNSの使い方は？", choices: ["見る専", "たまに投稿", "めっちゃ発信"], genre: .personality, difficulty: .easy),
        // normal
        Topic(id: "pers_n01", question: "褒められて嬉しいのは？", choices: ["見た目", "中身", "努力"], genre: .personality, difficulty: .normal),
        Topic(id: "pers_n02", question: "自分の長所は？", choices: ["真面目さ", "明るさ", "気配り"], genre: .personality, difficulty: .normal),
        Topic(id: "pers_n03", question: "嘘をつくならどんな嘘？", choices: ["優しい嘘", "保身の嘘", "嘘はつかない"], genre: .personality, difficulty: .normal),
        Topic(id: "pers_n04", question: "リーダータイプ？サポートタイプ？", choices: ["リーダー", "サポート", "一匹狼"], genre: .personality, difficulty: .normal),
        Topic(id: "pers_n05", question: "怒りのタイプは？", choices: ["すぐ言う", "溜め込む", "態度に出る"], genre: .personality, difficulty: .normal),
        Topic(id: "pers_n06", question: "お金の使い方で大事なのは？", choices: ["経験に使う", "モノに使う", "貯める"], genre: .personality, difficulty: .normal),
        Topic(id: "pers_n07", question: "人間関係で疲れるのは？", choices: ["空気を読む", "本音と建前", "グループの派閥"], genre: .personality, difficulty: .normal),
        // hard
        Topic(id: "pers_h01", question: "自分の嫌いなところは？", choices: ["優柔不断", "人に流される", "考えすぎ"], genre: .personality, difficulty: .hard),
        Topic(id: "pers_h02", question: "幸せの定義は？", choices: ["やりたいことができる", "大切な人と過ごせる", "不安がない"], genre: .personality, difficulty: .hard),
        Topic(id: "pers_h03", question: "一番許せないのは？", choices: ["裏切り", "無関心", "嘘"], genre: .personality, difficulty: .hard),
        Topic(id: "pers_h04", question: "人生で後悔していることは？", choices: ["挑戦しなかったこと", "人を傷つけたこと", "後悔はない"], genre: .personality, difficulty: .hard),
        Topic(id: "pers_h05", question: "自分を変えたいと思う瞬間は？", choices: ["人と比べた時", "失敗した時", "変えたくない"], genre: .personality, difficulty: .hard),
        Topic(id: "pers_h06", question: "本当の友達の条件は？", choices: ["辛い時にそばにいる", "何年会わなくても変わらない", "本音を言い合える"], genre: .personality, difficulty: .hard),
        Topic(id: "pers_h07", question: "死ぬ間際に思い出すのは？", choices: ["家族の顔", "やり残したこと", "一番楽しかった瞬間"], genre: .personality, difficulty: .hard),

        // ━━━━━━━━━━ もしも ━━━━━━━━━━
        // easy
        Topic(id: "hypo_e01", question: "動物になれるなら？", choices: ["猫", "鳥", "イルカ"], genre: .hypothetical, difficulty: .easy),
        Topic(id: "hypo_e02", question: "有名人に会えるなら？", choices: ["芸能人", "スポーツ選手", "歴史上の偉人"], genre: .hypothetical, difficulty: .easy),
        Topic(id: "hypo_e03", question: "魔法が使えるなら？", choices: ["空を飛ぶ", "透明になれる", "時間を止める"], genre: .hypothetical, difficulty: .easy),
        Topic(id: "hypo_e04", question: "異世界に転生したら？", choices: ["勇者になる", "商人になる", "のんびり暮らす"], genre: .hypothetical, difficulty: .easy),
        Topic(id: "hypo_e05", question: "一日だけ別の性別になれたら？", choices: ["めっちゃ楽しむ", "違いを研究", "特に何もしない"], genre: .hypothetical, difficulty: .easy),
        Topic(id: "hypo_e06", question: "宇宙旅行に行けるなら？", choices: ["月", "火星", "宇宙ステーション"], genre: .hypothetical, difficulty: .easy),
        Topic(id: "hypo_e07", question: "生まれ変わるなら？", choices: ["別の国の人", "動物", "もう一度自分"], genre: .hypothetical, difficulty: .easy),
        // normal
        Topic(id: "hypo_n01", question: "一つだけ超能力をもらえるなら？", choices: ["読心術", "瞬間移動", "未来予知"], genre: .hypothetical, difficulty: .normal),
        Topic(id: "hypo_n02", question: "無人島に一つ持っていくなら？", choices: ["ナイフ", "本", "友達"], genre: .hypothetical, difficulty: .normal),
        Topic(id: "hypo_n03", question: "1億円もらえるけど代償があるなら？", choices: ["SNS永久禁止", "一生同じ服", "毎日5km走る"], genre: .hypothetical, difficulty: .normal),
        Topic(id: "hypo_n04", question: "タイムマシンがあったら？", choices: ["過去の失敗をやり直す", "未来を見に行く", "使わない"], genre: .hypothetical, difficulty: .normal),
        Topic(id: "hypo_n05", question: "世界から一つなくすなら？", choices: ["戦争", "病気", "貧困"], genre: .hypothetical, difficulty: .normal),
        Topic(id: "hypo_n06", question: "24時間だけ誰かになれるなら？", choices: ["大統領", "大富豪", "推しのアイドル"], genre: .hypothetical, difficulty: .normal),
        Topic(id: "hypo_n07", question: "法律を一つ作れるなら？", choices: ["週休3日義務化", "教育完全無料", "残業禁止"], genre: .hypothetical, difficulty: .normal),
        // hard
        Topic(id: "hypo_h01", question: "全人類の記憶を一つ消せるなら？", choices: ["戦争の記憶", "自分の黒歴史", "消さない"], genre: .hypothetical, difficulty: .hard),
        Topic(id: "hypo_h02", question: "死後の世界があるなら何したい？", choices: ["先に逝った人に会う", "生前の自分を見守る", "全く新しい世界を体験"], genre: .hypothetical, difficulty: .hard),
        Topic(id: "hypo_h03", question: "世界の真実を一つだけ知れるなら？", choices: ["宇宙の果て", "人はなぜ生きるのか", "死後の世界"], genre: .hypothetical, difficulty: .hard),
        Topic(id: "hypo_h04", question: "人類が滅亡するとしたら原因は？", choices: ["AI の反乱", "環境破壊", "隕石"], genre: .hypothetical, difficulty: .hard),
        Topic(id: "hypo_h05", question: "永遠に生きられるとしたら？", choices: ["生きたい", "普通に死にたい", "条件による"], genre: .hypothetical, difficulty: .hard),
        Topic(id: "hypo_h06", question: "全ての人の本音が見えたら？", choices: ["見たい", "怖いから見たくない", "特定の人だけ見たい"], genre: .hypothetical, difficulty: .hard),
        Topic(id: "hypo_h07", question: "自分のクローンがいたら？", choices: ["仕事を任せる", "友達になる", "怖いから消す"], genre: .hypothetical, difficulty: .hard),

        // ━━━━━━━━━━ ランダム ━━━━━━━━━━
        // easy
        Topic(id: "random_e01", question: "もらって嬉しいのは？", choices: ["花束", "お菓子", "手紙"], genre: .random, difficulty: .easy),
        Topic(id: "random_e02", question: "朝型？夜型？どっち寄り？", choices: ["完全朝型", "夜型", "どっちでもない"], genre: .random, difficulty: .easy),
        Topic(id: "random_e03", question: "季節で一番好きなのは？", choices: ["春", "夏", "秋"], genre: .random, difficulty: .easy),
        Topic(id: "random_e04", question: "住むなら？", choices: ["都会", "田舎", "郊外"], genre: .random, difficulty: .easy),
        Topic(id: "random_e05", question: "移動手段なら？", choices: ["電車", "車", "自転車"], genre: .random, difficulty: .easy),
        Topic(id: "random_e06", question: "友達と話したい話題は？", choices: ["最近あった面白い話", "将来の夢", "恋バナ"], genre: .random, difficulty: .easy),
        Topic(id: "random_e07", question: "連絡手段なら？", choices: ["LINE", "電話", "会って話す"], genre: .random, difficulty: .easy),
        // normal
        Topic(id: "random_n01", question: "生まれ変わるなら？", choices: ["犬", "猫", "鳥"], genre: .random, difficulty: .normal),
        Topic(id: "random_n02", question: "超能力を持つなら？", choices: ["テレパシー", "透明化", "瞬間移動"], genre: .random, difficulty: .normal),
        Topic(id: "random_n03", question: "宝くじが当たったら？", choices: ["旅行三昧", "投資", "家を買う"], genre: .random, difficulty: .normal),
        Topic(id: "random_n04", question: "転職するなら？", choices: ["クリエイター", "起業家", "公務員"], genre: .random, difficulty: .normal),
        Topic(id: "random_n05", question: "時間を止められたら？", choices: ["寝る", "旅行する", "勉強する"], genre: .random, difficulty: .normal),
        Topic(id: "random_n06", question: "友達に求めるのは？", choices: ["面白さ", "優しさ", "頼もしさ"], genre: .random, difficulty: .normal),
        Topic(id: "random_n07", question: "飲み会で盛り上がるのは？", choices: ["暴露大会", "モノマネ", "思い出話"], genre: .random, difficulty: .normal),
        // hard
        Topic(id: "random_h01", question: "無人島に持っていくなら？", choices: ["ナイフ", "ライター", "ロープ"], genre: .random, difficulty: .hard),
        Topic(id: "random_h02", question: "タイムマシンで行くなら？", choices: ["過去", "未来", "別の時代の日本"], genre: .random, difficulty: .hard),
        Topic(id: "random_h03", question: "大事にしたい価値観は？", choices: ["自由", "安定", "挑戦"], genre: .random, difficulty: .hard),
        Topic(id: "random_h04", question: "人生で一番大切なのは？", choices: ["健康", "お金", "人間関係"], genre: .random, difficulty: .hard),
        Topic(id: "random_h05", question: "子供に伝えたいことは？", choices: ["努力の大切さ", "人への思いやり", "自分らしさ"], genre: .random, difficulty: .hard),
        Topic(id: "random_h06", question: "死ぬまでにしたいことは？", choices: ["世界一周", "本を出す", "家族と過ごす"], genre: .random, difficulty: .hard),
        Topic(id: "random_h07", question: "AI に任せたいことは？", choices: ["家事", "仕事", "勉強"], genre: .random, difficulty: .hard),

        // ━━━━━━━━━━ ハードモード（選択肢6つ・上位3つを当てる） ━━━━━━━━━━
        // food (hard mode)
        Topic(id: "food_hm01", question: "夕食に食べたいのは？", choices: ["寿司", "焼肉", "ラーメン", "カレー", "パスタ", "丼もの"], genre: .food, difficulty: .normal, playMode: .hard),
        Topic(id: "food_hm02", question: "おやつに食べたいのは？", choices: ["チョコ", "アイス", "ポテチ", "クッキー", "せんべい", "ケーキ"], genre: .food, difficulty: .normal, playMode: .hard),
        Topic(id: "food_hm03", question: "コンビニで買うなら？", choices: ["おにぎり", "サンドイッチ", "肉まん", "サラダ", "唐揚げ", "スイーツ"], genre: .food, difficulty: .normal, playMode: .hard),

        // hobby (hard mode)
        Topic(id: "hobby_hm01", question: "休日にやりたいのは？", choices: ["映画", "ゲーム", "散歩", "読書", "ショッピング", "カフェ巡り"], genre: .hobby, difficulty: .normal, playMode: .hard),
        Topic(id: "hobby_hm02", question: "新しく始めたい趣味は？", choices: ["筋トレ", "楽器", "絵を描く", "料理", "プログラミング", "写真"], genre: .hobby, difficulty: .normal, playMode: .hard),
        Topic(id: "hobby_hm03", question: "旅行で行きたいのは？", choices: ["温泉", "テーマパーク", "海外", "山", "島", "都会"], genre: .hobby, difficulty: .normal, playMode: .hard),

        // school (hard mode)
        Topic(id: "school_hm01", question: "学校で楽しかった時間は？", choices: ["昼休み", "放課後", "体育", "音楽", "図工", "給食"], genre: .school, difficulty: .normal, playMode: .hard),
        Topic(id: "school_hm02", question: "学校行事で好きなのは？", choices: ["文化祭", "体育祭", "修学旅行", "遠足", "卒業式", "球技大会"], genre: .school, difficulty: .normal, playMode: .hard),
        Topic(id: "school_hm03", question: "授業で得意だったのは？", choices: ["国語", "数学", "英語", "理科", "社会", "体育"], genre: .school, difficulty: .normal, playMode: .hard),

        // love (hard mode)
        Topic(id: "love_hm01", question: "デートで行きたい場所は？", choices: ["カフェ", "水族館", "映画館", "公園", "夜景", "遊園地"], genre: .love, difficulty: .normal, playMode: .hard),
        Topic(id: "love_hm02", question: "好きなタイプは？", choices: ["優しい", "面白い", "頼れる", "賢い", "おしゃれ", "ミステリアス"], genre: .love, difficulty: .normal, playMode: .hard),
        Topic(id: "love_hm03", question: "プレゼントで嬉しいのは？", choices: ["手紙", "アクセサリー", "花束", "体験", "食事", "サプライズ"], genre: .love, difficulty: .normal, playMode: .hard),

        // personality (hard mode)
        Topic(id: "pers_hm01", question: "ストレス発散法は？", choices: ["寝る", "食べる", "話す", "運動", "買い物", "一人時間"], genre: .personality, difficulty: .normal, playMode: .hard),
        Topic(id: "pers_hm02", question: "自分の長所は？", choices: ["真面目", "明るい", "気配り", "行動力", "冷静", "創造力"], genre: .personality, difficulty: .normal, playMode: .hard),
        Topic(id: "pers_hm03", question: "大事にしたい価値観は？", choices: ["自由", "安定", "挑戦", "愛", "成長", "誠実"], genre: .personality, difficulty: .normal, playMode: .hard),

        // hypothetical (hard mode)
        Topic(id: "hypo_hm01", question: "超能力をもらえるなら？", choices: ["瞬間移動", "読心術", "未来予知", "透明化", "時間停止", "空を飛ぶ"], genre: .hypothetical, difficulty: .normal, playMode: .hard),
        Topic(id: "hypo_hm02", question: "無人島に持っていくなら？", choices: ["ナイフ", "ライター", "本", "水", "ロープ", "友達"], genre: .hypothetical, difficulty: .normal, playMode: .hard),
        Topic(id: "hypo_hm03", question: "1億円当たったら？", choices: ["旅行", "貯金", "投資", "家を買う", "家族にあげる", "仕事を辞める"], genre: .hypothetical, difficulty: .normal, playMode: .hard),

        // random (hard mode)
        Topic(id: "random_hm01", question: "もらって嬉しいのは？", choices: ["花束", "お菓子", "手紙", "本", "アクセサリー", "現金"], genre: .random, difficulty: .normal, playMode: .hard),
        Topic(id: "random_hm02", question: "住むなら？", choices: ["都会", "田舎", "郊外", "海沿い", "山の中", "海外"], genre: .random, difficulty: .normal, playMode: .hard),
        Topic(id: "random_hm03", question: "人生で大切なのは？", choices: ["健康", "お金", "人間関係", "やりがい", "時間", "自由"], genre: .random, difficulty: .normal, playMode: .hard),
    ]

    func pickTopics<G: RandomNumberGenerator>(
        count: Int,
        genre: Genre,
        difficulty: Difficulty,
        playMode: PlayMode,
        excluding: Set<String>,
        using generator: inout G
    ) -> [Topic] {
        let modePool = Self.allTopics.filter { $0.playMode == playMode }
        let basePool: [Topic]
        if genre == .random {
            basePool = modePool
        } else {
            basePool = modePool.filter { $0.genre == genre }
        }

        let filtered = basePool.filter { !excluding.contains($0.id) }
        // Fall back to the unfiltered pool when exclusion eliminates every candidate
        // so the game can always continue.
        let pool = filtered.isEmpty ? basePool : filtered
        return Array(pool.shuffled(using: &generator).prefix(count))
    }

    func topic(withId id: String) -> Topic? {
        Self.allTopics.first { $0.id == id }
    }
}
