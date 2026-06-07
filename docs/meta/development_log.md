# GuessRank — AI駆動開発の記録と新人エンジニア向けガイド

このドキュメントは、GuessRank プロジェクトを Claude Code（Opus 4.6 / 4.7）と共同で開発してきた **実際の編集履歴** をもとに、新人エンジニアが「AI とどう開発を進めるか」を学ぶための実践ガイドです。

抽象論ではなく、すべて **このリポジトリの git 履歴・PR 本文から抽出した実例** で説明します。

> **本文中のファイルパスは執筆時点（〜2026-05-07）のものです。** 当時 `docs/` 直下にあった `personas.md` / `scope.md` / `game_rules.md` / `brand.md` / `project_overview.md` は現在 `docs/product/` 配下に移動しています。本ドキュメント自身も `docs/ai_driven_development_log.md` から `docs/meta/development_log.md` に移動しました。歴史的経緯を読む目的では当時の記述で構いません。最新のドキュメント構成は [index.md](../index.md) を参照してください。

---

## 目次

1. [プロジェクト全体タイムライン](#1-プロジェクト全体タイムライン)
2. [各フェーズの編集詳細と判断](#2-各フェーズの編集詳細と判断)
3. [AI駆動開発の1サイクルの型](#3-ai駆動開発の1サイクルの型)
4. [Claude Code への指示の出し方（実例ベース）](#4-claude-code-への指示の出し方実例ベース)
5. [AI生成コードのレビューポイント](#5-ai生成コードのレビューポイント)
6. [このプロジェクトの評価と改善点](#6-このプロジェクトの評価と改善点)
7. [補章: AI駆動開発の How To](#7-補章-ai駆動開発の-how-to)

---

## 1. プロジェクト全体タイムライン

期間: **2026-04-14 〜 2026-05-07（約3週間）**
コミット: 22本 / PR: 6本 / リリース対象機能: 11個 (MVP含む)

| 日付 | フェーズ | 主な成果物 | 形式 |
|---|---|---|---|
| 04-14 | docs先行 | `a34ec56 first docs` | 直push |
| 04-15 | MVP実装 | `57d237f feat: MVP実装 + docs整備 + 単一リポジトリに統合` | 直push（巨大1コミット） |
| 04-17 | Phase B/C/A | `0377e05 GuessRank にリネーム + Phase B/C/A 完了`（テスト59件、DI導入、UI磨き込み） | 直push（巨大1コミット） |
| 05-02 | Phase D / 用語統一 / Phase 1.5 | アプリアイコン → 履歴保存 → 分析機能 → ルール画面&パス機能 → 用語統一 リファクタ | **6コミットを直push** |
| 05-03 | UI磨き込み | お題拡充 (3→7ジャンル, 63→147問) / ターン結果演出3フェーズ化 / 各画面UI調整 | 直push |
| 05-04 | App Store対応 | サポートページ・ブランド設定 / プライバシーポリシーをApple審査要件に準拠 | **PR #1, #2**（PR運用開始） |
| 05-06 | お題管理機能 | お題履歴 / お題ブロック / 枯渇通知 / ハードモード | **PR #3, #4, #5**（feature branch） |
| 05-07 | プロジェクトルール | `CLAUDE.md` 追加（Documentation / App Store / Build & Test の3ルール） | **PR #6** |

### 注目ポイント

- **MVP は1コミットで一気に完成**。最初から細かく刻まなかった。
- **Phase D は同日6コミット**。粒度を意識して分け始めた。
- **PR運用は中盤から**。前半は `main` 直 push、5/4 から feature branch + PR に移行。
- **CLAUDE.md は最後**。3週間使って蓄積した「やってほしいこと/やってほしくないこと」を最後にコード化した。
- すべてのコミットに `Co-Authored-By: Claude Opus 4.6 (1M context)` が付いている。

---

## 2. 各フェーズの編集詳細と判断

### 2.1 docs 先行戦略（04-14）

- **`a34ec56 first docs`** が `f9774a0 first commit`（コード）より先。
- `docs/personas.md`, `docs/game_rules.md`, `docs/scope.md` を **コードを書く前に Claude に書かせた**。
- 効果: 後続セッションで Claude に「このプロジェクトの目的」を毎回再説明する必要がなくなった。

> 💡 **新人向けポイント**: AI に大きい機能を任せたいなら、先に「ペルソナ・ゲームルール・スコープ」だけでも書く。AI は無からは設計できないが、「対象ユーザーがこういう人で、このゲームはこうあるべき」と書いてあれば、整合性のある実装を出せる。

### 2.2 MVP 実装（04-15、`57d237f`）

巨大1コミット (3桁ファイル変更):

```
- ゲームルール・ペルソナ・画面名定義など docs を整備
- SwiftUI/MVVM で MVP 実装（設定→ゲーム進行→結果）
- 進行フローを4ステップに簡略化
- 中断機能、再戦時のプレイヤー情報保持、視覚演出
- sanrentan/.git を解消してルートリポジトリに統合
```

- 1コミットに **docs整備 + 全画面実装 + リポジトリ構造変更** が混ざっている。
- メリット: 「docs と実装が原子的にコミット」されるため、後で見たときに整合する。
- デメリット: レビュー不能サイズ。MVP だから個人開発なら許容、チーム開発なら NG。

### 2.3 Phase B/C/A（04-17、`0377e05`）

巨大1コミット、3つのフェーズを混合:

| フェーズ | やったこと |
|---|---|
| **Phase B（テスト整備）** | SPMベースのユニットテスト59件追加。ScoreService / TopicService / GameSession / GameConfig / ViewModel のカバレッジ確保 |
| **Phase C（アーキテクチャ強化）** | `TopicProviding` プロトコル + DI 導入、`GameEngine` に純粋ロジック抽出、`TurnInputState` で UI 状態分離、`GameSessionSnapshot` で `EndView` を読み取り専用化 |
| **Phase A（MVP磨き込み）** | お題18→63問、ゲームクリア演出、TurnResultView アニメ + ハプティクス、EndView に個人統計、プレイヤー名サニタイズ |

> 💡 **新人向けポイント**: Phase B → C の順序は意図的。「先にテストを書いて、リファクタで壊れないことを保証してから DI 導入」というのは AI に任せる時こそ有効。テストがあれば AI のリファクタが暴走しても気づける。

### 2.4 Phase D（05-02、6コミット）

ここから **粒度を意識して分け始めた**:

```
ef140ca feat: アプリアイコンを追加              <- 独立した雑務
f9409c6 feat: ゲーム履歴保存機能 (Phase D-1)
f91a3d0 feat: 分析機能 (Phase D-2)             <- D-1 が前提
f9b752a feat: ルール説明画面 + お題パス機能      <- 独立機能2つを1コミットに
ad26158 fix: お題変更を回数無制限に変更 + ペルソナ・企画書に設計思想を反映
6180f1c refactor: 用語を統一（出題者→ターゲット、回答者→予想者）  <- 24ファイル横断リネーム
```

特徴:
- **`refactor:` を独立コミット化**。リファクタ（コード意味を変えない）と feat（機能追加）を混ぜない原則を実装。
- **`ad26158` は実装+docsを同一コミット**。「お題変更を無制限に」というルール変更を、コード（実装）と `personas.md`/`scope.md`（仕様）の両方に反映。
- **`6180f1c` の用語統一**: コード24ファイル + docs 8ファイルを横断する一括リネーム。AI が得意な作業の典型例。

### 2.5 Apple審査対応（05-04、PR #1〜#2）

- `eebc76d feat: App Storeサポートページ・ブランド設定を追加`（`docs/support.html` 新規）
- `535a5f9 fix: プライバシーポリシーをApple審査要件に対応`（+58 / -14 の差分）

このフェーズで **CLAUDE.md の "App Store Compliance" ルールが生まれた**:

```markdown
## App Store Compliance
- Privacy policy must enumerate: data types collected, retention policy, third-party SDKs, contact info, children's data handling
- Generic templates fail Apple review — write project-specific copy reflecting actual app behavior
```

> 💡 **新人向けポイント**: AI が「テンプレート的なプライバシーポリシー」を出してきた → Apple審査で落ちる、を実体験 → 次セッションのために CLAUDE.md にルール化。**痛い思いをした学びを CLAUDE.md に翻訳する** のが鉄則。

### 2.6 お題管理機能 + ハードモード（05-06、PR #5）

PR #5 は **6コミットに分けて1PRにまとめた** 大規模変更:

```
1. refactor: extend TopicProviding (excluding: Set<String> 追加、後方互換維持)
2. feat: topic history (重複回避ストア)
3. feat: topic block (長押しブロック)
4. docs: move topic features out of future
5. feat: exhaustion notification
6. feat: hard mode (PlayMode enum + 6→3 選択 UI)
```

ここで重要なのは **PR本文の構造**:

```markdown
## アーキテクチャ判断
- 既存のフラット構成を維持。Feature-First への切替は閾値（15ファイル）未満なので保留
- 新規永続化サービスは GameHistoryStore パターン踏襲
- Codable後方互換: GameConfig / Topic の playMode フィールドは旧JSONでは .normal フォールバック

## スキップ判断（docs/future/ 残り）
- multiplayer_design.md (Firebase) — バックエンド要、別スコープ
- remote_topics.md — サーバ要、別スコープ
- analytics_design.md — MVP相当は AnalyticsService ですでに実装済み
- monetization.md — Phase 3、具体仕様なし
```

> 💡 **新人向けポイント**: AI に PR 本文を書かせるなら、**「やったこと」だけでなく「やらなかったこと」と「なぜ」** を必ず書かせる。後で「なんでこの未実装が残ってるんだっけ？」と人間が悩む時間を消せる。

### 2.7 CLAUDE.md 制定（05-07、PR #6）

3週間の試行錯誤の結果として、3つのルールに集約:

```markdown
## Documentation Structure
- Avoid duplication across docs files; each piece of information lives in exactly one place
- Organize docs at feature-level granularity, not by document type
- When scaffolding new docs, propose the structure first before creating files

## App Store Compliance
- Privacy policy must enumerate: data types collected, retention policy, third-party SDKs, contact info, children's data handling
- Generic templates fail Apple review
- Cross-check docs/support.html and the privacy policy whenever data collection or third-party integrations change

## Build & Test Verification
- After Swift/TypeScript changes, run the build and report compile errors before declaring done
- For Swift: verify Hashable/Equatable conformance when adding enums or structs used in Sets/Dicts
- Surface compilation errors proactively rather than waiting for the user to paste them
```

各ルールの背景:
- **Documentation Structure**: docs/index.md の SSOT ルールで「同じ情報を2箇所に書かない」と決めていたのに、Claude が重複を作りがちだった。
- **App Store Compliance**: 5/4 のプライバシーポリシー修正で学んだ。
- **Build & Test Verification**: Hashable 適合忘れで何度かビルドエラーが起きた → ルール化。

---

## 3. AI駆動開発の1サイクルの型

このプロジェクトで**機能追加1個** を進めるときの典型サイクル:

```
[1] 仕様を docs に書く（spec.md / ui.md / qa.md）
        ↓
[2] AI に "spec.md を読んで実装計画を出せ" と指示
        ↓
[3] 計画レビュー → 修正点を口頭で指示
        ↓
[4] AI に実装させる（feature branch）
        ↓
[5] AI に swift test と xcodebuild を走らせる
        ↓
[6] エラーがあれば AI に修正させる
        ↓
[7] 自分で iOS Simulator で動作確認（AIには見えない領域）
        ↓
[8] AI に PR 本文を書かせる（やったこと / やらなかったこと / アーキ判断）
        ↓
[9] PR レビュー → マージ
        ↓
[10] 学びを CLAUDE.md にフィードバック
```

### 各ステップの注意点

| ステップ | AIに任せていい | 人間がやる |
|---|---|---|
| [1] 仕様作成 | 叩き台の生成 | 最終的な意思決定 |
| [2] 計画 | 全部 | レビュー |
| [3] 修正指示 | — | **必須**（AIは"いい質問しなさそうな提案"も平気で出す） |
| [4] 実装 | 全部 | コード差分のスポットレビュー |
| [5] ビルド/テスト | 全部 | コマンド実行を確認 |
| [6] エラー修正 | 全部 | エラーの本質を確認（見当違いの修正をしてないか） |
| [7] UI動作確認 | **不可能** | **必須**（AIは画面が見えない） |
| [8] PR文 | 全部 | アーキ判断・スキップ判断の正確性をレビュー |
| [9] レビュー | コミット単位の自己レビュー | 最終承認 |
| [10] 振り返り | 学びの抽出案 | 採否判断 |

---

## 4. Claude Code への指示の出し方（実例ベース）

このプロジェクトの実コミットメッセージから、**良い指示の型** を抽出します。

### 4.1 良い指示のパターン

#### パターンA: 「why + what」を明示

```
❌ 悪い: 「お題を増やして」
✅ 良い: 「お題を3→7ジャンル（63→147問）に拡充。学生あるある・恋愛・性格/価値観・もしもを追加」
        → コミット b9a6be3 はこの指示で生まれた
```

理由が「ジャンル追加」と分かるため、AI が無関係な変更（既存お題の削除など）をしない。

#### パターンB: アーキテクチャ制約を先に伝える

PR #5 のコミット 1 が示す例:

```
✅ 「TopicProviding に excluding: Set<String> を追加したい。
    旧 API は default 実装で互換維持して。」
```

これだけで `39c12e4 refactor: extend TopicProviding to support excluded IDs` が生まれた。**「default 実装で互換維持」と先に言う** ことで、AI が呼び出し側を全部書き換えるのを防げる。

#### パターンC: 段階を分ける

ハードモード実装の例（PR #5、6コミットに分割）:

```
1. まずプロトコルだけ拡張して（refactor）
2. 履歴ストアを足して（feat）
3. ブロック機能を足して（feat）
4. docs を整理して（docs）
5. 枯渇通知を足して（feat）
6. 最後にハードモード（feat）
```

**「まずリファクタ → そのあと feature 追加」** の順序を指示すると、コミットが綺麗に分かれて後でレビュー/revert しやすい。

#### パターンD: 失敗パターンを事前に防ぐ

CLAUDE.md の "Build & Test Verification" がまさにこれ:

```
After Swift/TypeScript changes, run the build and report compile errors before declaring done
```

**過去の失敗から逆算したルール** をプロジェクト固有のメモリ（CLAUDE.md）に書くことで、毎回「ビルド通った？」と聞く必要がなくなる。

### 4.2 悪い指示の避け方

このプロジェクトで起きた（であろう）失敗例と対策:

| 起きた失敗 | 推測される指示 | より良い指示 |
|---|---|---|
| プライバシーポリシーが Apple 審査で落ちた | 「プライバシーポリシー作って」 | 「このアプリは何を収集して何を収集しないか書く。Apple審査の必須項目（収集データ/保持/第三者SDK/連絡先/子供データ）を網羅」 |
| Hashable 未適合でビルド失敗 | 「PlayMode enum 追加して」 | 「PlayMode enum を追加。Set/Dict で使うので Hashable 必須」 |
| docs が重複 | 「topic_history のドキュメント書いて」 | 「`docs/features/_template/` をコピーして topic_history を作る。data_model.md に既出の項目はリンク参照のみ」 |

---

## 5. AI生成コードのレビューポイント

GuessRank の実コードベースから、**Swift/iOS 開発で AI 生成コードを見るときのチェック項目** を抽出します。

### 5.1 一般チェック項目

#### ✅ 後方互換が壊れていないか

PR #5 の例:
```
Codable後方互換: GameConfig / Topic の playMode フィールドは旧JSONでは .normal フォールバック
```

→ **既存ユーザーのセーブデータが読めるか** を必ず確認。AI は新しい型に新フィールドを追加する時、既存 JSON を考慮しないことがある。

#### ✅ テストが「動いているか」と「意味があるか」

PR #5 のテスト追加: 42件。だが、**テストが何を保証しているか** は人間がレビューする必要がある。AI のテストは時に「実装をそのままアサート」するだけになる（実装変更で割れない = 価値が低い）。

#### ✅ 不要な抽象化を入れていないか

CLAUDE.md にはないが、システムプロンプトの教えとして:
> Don't add features, refactor, or introduce abstractions beyond what the task requires.

GuessRank では、`TopicProviding` プロトコルや `GameEngine` 抽出は **テスト容易性** という具体的目的があった（Phase B でテストを書きたいから DI 必要）。**目的が明示されない抽象化は AI に作らせない。**

### 5.2 Swift / iOS 特有

#### ✅ Hashable / Equatable / Codable

CLAUDE.md にも明記:
```
For Swift: verify Hashable/Equatable conformance when adding enums or structs used in Sets/Dicts
```

`PlayMode.swift` 追加時、`Set<PlayMode>` で使う場面があるか確認。

#### ✅ @Observable / @State / @Binding の境界

GuessRank は MVVM:
```
View → ViewModel (@Observable) → Service / Model
```

**View に直接 Model を書き換えるロジックを書かない** が原則。AI は時に View のクロージャの中で Service を呼んで結果を Model に書く、という汚い書き方をする。

#### ✅ SwiftUI のテスト不可領域

`README.md` 記載:
```
Views（SwiftUI 依存）はテスト対象外です。
```

→ **View の動作確認は人間の手動UI確認が必須**。AI が「テスト通りました」と言っても、それは Model/Service/ViewModel のテストでしかない。

#### ✅ 永続化のディレクトリ注入

`GameHistoryStore`、`TopicHistoryStore`、`TopicFeedbackStore` はすべて **テスト用ディレクトリを注入できる** 設計。AI が `FileManager.default.urls(...)` をハードコードしたら指摘する。

### 5.3 ドキュメント側のチェック

GuessRank は SSOT を徹底しているので:

#### ✅ docs/index.md に追加されているか

PR #5 で `feat/topic-features-and-hard-mode` 機能追加時、`docs/index.md` の機能一覧表に必ず1行追加されている。

#### ✅ data_model.md と Models/ が一致するか

`docs/data_model.md` がデータ構造の SSOT。`Topic.swift` に `playMode` フィールドを足したなら、`data_model.md` にも反映する。

#### ✅ future → features 移行が完了しているか

PR #5 の `2e8c640 docs: move implemented topic features out of future` のような **完了したものを future から移す動き** ができているか。docs/future/ は将来構想置き場であって、実装済み機能のドキュメントを置く場所ではない。

---

## 6. このプロジェクトの評価と改善点

率直な評価です。

### 6.1 良かった点

1. **docs 先行戦略**
   - `first docs` が `first commit` より先。3週間後でも `personas.md` がブレずに残っている。
   - 新人がコードベースに参加する時、`docs/index.md` から辿れば全体像が見える。

2. **コミットメッセージの質**
   - bullet で「やったこと」と「なぜ」を分けている例多数（`f9b752a`, `0377e05` など）。
   - 後から git log で機能追加の意図が辿れる。

3. **Phase の刻み方**
   - Phase B (テスト) → Phase C (アーキ強化) → Phase A (磨き込み) の順序は意図的に「テストでガードしてからリファクタ」になっている。

4. **CLAUDE.md の "失敗から逆算" アプローチ**
   - 3週間使って学んだ "やってほしくないこと" を3ルールに集約。最初から完璧に書こうとしないのが現実的。

5. **PR本文の "スキップ判断" セクション**
   - PR #5 の「やらなかったこと + 理由」が秀逸。スコープが膨らまない歯止めになっている。

6. **テンプレート (`docs/features/_template/`)**
   - 4ファイル構成 (spec/ui/qa/tasks) を雛形化。新機能追加で AI が迷わない。

### 6.2 改善点

1. **CLAUDE.md が遅すぎた**
   - 3週間目に作った。**プロジェクト開始時に空でいいから作るべき**。「最初は空だった CLAUDE.md に1ルール追加するごとに git commit する」というワークフローのほうが学びが残る。
   - 例えば 5/2 の用語統一 (`6180f1c`) で「用語の正式名はターゲット/予想者」と決めたなら、即 CLAUDE.md に書くべきだった。

2. **MVP・Phase B/C/A は1コミットが大きすぎる**
   - `57d237f` (MVP) や `0377e05` (Phase B/C/A) は 100ファイル超の差分。**個人開発で許容したのは合理的だが、もしチームに引き継ぐ場合 git bisect が無力化する**。
   - 改善: せめて Phase B / C / A はそれぞれ別コミットに分けるべきだった。

3. **PR #2 が空本文**
   - PR #1 と同じブランチ名 `feat/topics-and-result-animation` で別 PR 化されている。**自動マージの履歴が読めない**。
   - 改善: PR を立てたら本文必須。空ならローカルマージで済ませる。

4. **PR #1〜#5 の Test plan のチェックボックスが未消化**
   - すべて `[ ]` のまま。「手動UI確認」がマージ後に行われたか、追跡できない。
   - 改善: マージ前に Test plan を `[x]` に更新する習慣を入れる（AI に自動でやらせない、人間が確認したことの記録だから）。

5. **PR #5 が大きすぎる**
   - 6コミット、24ファイル変更、+828/-75。**お題履歴 / お題ブロック / 枯渇通知 / ハードモード** は本来 4 PR に分けられた。
   - 1 PR にまとめたメリット: feature flag が要らない、リリース粒度が大きい。
   - デメリット: レビュー負荷、片方だけ revert ができない。
   - 改善: ハードモードだけは別 PR にすべき（Codable 後方互換に関わるため、独立してテストすべき変更）。

6. **`Co-Authored-By: Claude Opus 4.6` のままになっているコミットがある**
   - 実際は 4.7 にアップグレードしているはずなのに 4.6 のまま。
   - 改善: `~/.claude/CLAUDE.md` または settings.json でモデル名を動的に出すフックを入れる。

7. **screenshots/ が突然出現**
   - `9c43337 theme 充実 future feature` で Next.js プロジェクト一式が +2689 行で混入。
   - 改善: 「スクショ生成基盤」を独立コミットにすべき。

8. **CLAUDE.md の "Build & Test Verification" のテストカバレッジ言及が弱い**
   - 「コンパイルエラーを先回り報告」はあるが、「テストを実行して報告」はない。Hashable 起因の問題はテストでも捕まる。
   - 改善案:
     ```
     - After Swift changes, run `swift test` and report failures before declaring done
     - For changes touching Models or Services, ensure new tests are added
     ```

9. **iPad スクショ追加 (PR #4) のテストプランが手動のみ**
   - `screenshots/src/app/page.tsx` の +267/-501 という大きな書き換えで、**自動テストが1つもない**。
   - 改善: Next.js の vitest なり Playwright なりで、最低でも「サイズ選択 UI が render できる」は自動化すべき。

### 6.3 一般的に良いやり方だったか？（総評）

**個人開発のスピード感としては A 評価、チーム開発の再現性としては B 評価** です。

- **A 評価のポイント**: docs先行、SSOT徹底、Phase で刻んだロードマップ、CLAUDE.md による学びの蓄積。これは AI 駆動開発の優等生な進め方。
- **B 評価の理由**:
  - PR運用の開始が遅い（5/4から、それまでは main 直push）
  - CLAUDE.md の制定が遅い（最後）
  - 巨大コミットが2つ存在する
  - Test plan が完了マークされない
- **新人エンジニアへ**: 最初からこのプロジェクトと同じ完成度を目指す必要はない。**「docs 先行」「CLAUDE.md を空でも作る」「PR 本文に "やらなかったこと" を書く」の3つだけ** 真似すれば、AI と仕事しやすい開発スタイルがほぼ身につく。

---

## 7. 補章: AI駆動開発の How To

新人エンジニア向けに、一般原則と GuessRank の実例を組み合わせた実践ガイド。

### 7.0 大前提（マインドセット）

| よくある誤解 | 実態 |
|---|---|
| 「AIに仕様を渡せば完成品が出る」 | **会話で詰める**。1機能あたり10往復は普通 |
| 「AIが書いたら自分は確認するだけ」 | **半分は人間の仕事**（仕様決定・動作確認・スコープ管理） |
| 「コードが速く書けるから残業が減る」 | **メタワーク（docs/ルール/リファクタ）が増える**。総時間は減るが配分が変わる |
| 「優秀なAIなら間違えない」 | **小さい失敗を必ずする**（後方互換忘れ、Hashable未実装、テンプレ流用）→ ガードを置く |

GuessRank の数字: 手作業 140〜220h → AI併用 30〜60h（**3〜4倍速**）

### 7.1 プロジェクト立ち上げ — 最初の1日にやること

#### ① docs を先に書く（コードより前）

```bash
mkdir docs
touch docs/{personas,scope,game_rules,data_model}.md
```

何も書けなくても箱だけ用意。AI に「ペルソナを3人提案して」と聞いて叩き台を作らせ、**自分で取捨選択**して保存。

> GuessRank: `a34ec56 first docs` が `f9774a0 first commit` より先。ペルソナ（ユウキ/サキ/タケシ）が3週間後の意思決定にも効いた。

#### ② 空の CLAUDE.md を作る

```bash
cat > CLAUDE.md <<'EOF'
# Project Guide
（空でOK。失敗するたび1行ずつ追加する）
EOF
```

最初から完璧に書こうとしない。**痛い思いをするたびにルール化**。GuessRank は最終的に7セクションになったが、全部「失敗の痕跡」。

#### ③ docs/index.md で SSOT（Single Source of Truth）宣言

```markdown
## SSOT ルール
1. 同じ情報を2箇所以上に書かない — 必ずリンクで参照
2. 定義の場所を1つに決める — データモデルは data_model.md
3. 矛盾が生じたら定義元を正とする
```

**AIは「参考のために」既存情報をコピーしがち**。SSOTルールを宣言しておかないと、3ヶ月後に同じ仕様が4箇所に書かれている地獄になる。

### 7.2 機能を1個作るサイクル（10ステップ）

```
[1] spec.md を書く（AIに叩き台を出させ、自分で詰める）
[2] AI に「spec.md を読んで実装計画を出せ」
[3] 計画レビュー → 修正点を口頭で指示
[4] feature branch を切る
[5] AI に refactor を先に分離させる（必要なら）
[6] AI に feat 本体を実装させる
[7] swift test / xcodebuild を走らせる
[8] エラーがあれば AI に修正させる
[9] 自分で iOS Simulator で動作確認 ← AI には絶対できない
[10] AI に PR本文を書かせる（やったこと/やらなかったこと/Test plan）
```

#### GuessRank での実例（PR #5、ハードモード）

| ステップ | 実コミット |
|---|---|
| spec | `docs/features/play_modes/spec.md` を先に作成 |
| refactor先行 | `39c12e4 refactor: extend TopicProviding to support excluded IDs`（後方互換維持） |
| feat | `4e90587 feat: implement hard mode`（PlayMode enum + UI + 21問追加） |
| docs同期 | `data_model.md` 更新、`docs/index.md` の機能一覧に追加 |

> **コツ**: refactor を先に独立コミット化することで、もし feat だけ revert したくなった時に綺麗に戻せる。

### 7.3 指示の型 4パターン

#### パターンA: why + what を明示

| 悪い指示 | 良い指示 |
|---|---|
| 「お題を増やして」 | 「お題を3→7ジャンル（63→147問）に拡充。学生あるある・恋愛・性格/価値観・もしもを追加」 |

→ 「ジャンル追加」と分かるので、AI が既存お題を消したり書き換えたりしない。

#### パターンB: 制約を先に伝える

```
❌ 「TopicProviding に excluding 引数追加して」
   → AI が呼び出し側を全部書き換えて巨大diff になる

✅ 「TopicProviding に excluding: Set<String> 追加。
    旧 API は default 実装で互換維持して」
   → 5ファイル変更で済む（実例: 39c12e4）
```

#### パターンC: 段階を切る

```
「以下を別コミットでやってほしい:
 1. まずプロトコル拡張（refactor）
 2. 次にストア追加（feat）
 3. UI を繋ぐ（feat）
 4. 最後にdocs更新（docs）」
```

→ コミットが綺麗に分かれ、レビュー時に diff を読みやすい（PR #5 の6コミット構成）。

#### パターンD: 失敗を先回りで防ぐ

```
「PlayMode enum を追加。Set/Dict で使うので Hashable 必須。
 既存JSONのデコードでは .normal にフォールバック」
```

→ Hashable 忘れ + Codable 後方互換 の2つの定番事故を一文で予防。

### 7.4 レビューの3層

AI のコードを「全部読む」は現実的じゃないので、**層を分けて深さを変える**。

#### 第1層: コミットメッセージで方向確認（10秒）

- `refactor:` なのに振る舞いが変わってないか？
- `feat:` の説明が抽象的すぎないか？

#### 第2層: 差分の異常検出（1〜3分）

特に**広い差分は警戒**:
- 24ファイル横断 → 用語統一なら正解、機能追加なら異常
- 既存テストが大量変更 → AI が「実装に合わせて」テストを壊している可能性

#### 第3層: 重要箇所を熟読（5〜15分）

| Swift/iOS で必ず見る箇所 |
|---|
| Hashable / Equatable / Codable の適合 |
| 永続化ストアが `FileManager.default` をハードコードしてないか |
| View が直接 Service を呼んでないか（MVVM境界） |
| 後方互換: 新フィールドは optional + フォールバック |
| SwiftUI Views の挙動（テスト不可領域、自分で動かす） |

> GuessRank の経験: テストが通っても **手動UI確認は必須**。AI には画面が見えない。

### 7.5 負債を貯めない運用

#### 早期にやるほど後で楽になる5つ

| いつやるか | やること | サボると... |
|---|---|---|
| 初日 | 用語の正式名称を決定 & docs化 | 24ファイル横断リネームが発生（GuessRank `6180f1c`） |
| 初日 | 空CLAUDE.md | 同じ失敗をAIと何度も繰り返す |
| 第1週 | テスト基盤（最低でも Models/Services） | リファクタが恐くなる |
| 第1週 | DI 導入（テスト容易性） | 後で全部書き直し |
| PR出すたび | 「やらなかったこと」をPR本文に書く | 3ヶ月後の自分が悩む |

#### CLAUDE.md に書くべきものの判別

**書くべき**:
- 過去にAIが間違えた / プロジェクト固有の制約 / 守ってほしい命名

**書くべきでない**（システムプロンプトと重複するから）:
- 「コメントは少なめに」「テスト書いて」のような一般原則
- コードベースを読めば分かること

GuessRank の良い例:
```markdown
## Domain Terminology
- Use ターゲット (target); never 出題者
- These terms appear in Models, ViewModels, Views, and docs/
- Renaming was committed in 6180f1c — do not reintroduce
```

→ **失敗の歴史 + 現在のルール + 過去コミット参照** が揃っている。AIが理由まで理解できる。

### 7.6 つまずきと対処

| 症状 | 原因 | 対処 |
|---|---|---|
| AI が大量diff を出してくる | スコープ指示が曖昧 | 「○○のみ変更、他は触らない」と明示 |
| ビルドが通らない | Hashable / import / typo | エラーメッセージごと貼って AI に直させる。直さない場合は人間が読む |
| テストが通っても挙動が違う | View の挙動が未検証 | シミュレータで実機確認 |
| 後方互換が壊れた | Codable に新フィールド | optional + フォールバック値 + 旧JSONデコードテスト |
| docs が乱立 | SSOT ルール未宣言 | docs/index.md で宣言してCLAUDE.mdにも書く |
| PR が大きすぎる | 機能を分けず一気に依頼 | 「refactor → feat1 → feat2」と段階指定 |
| AI がテンプレ的回答 | プロジェクト固有性が伝わってない | personas.md / brand.md / spec.md を先に渡す |

> GuessRank の失敗: プライバシーポリシー（`535a5f9`）はテンプレ流用でApple審査落ち→具体記述に書き直し。**「Apple審査に通るプライバシーポリシーを」と言うだけでは弱い**。要件を列挙してCLAUDE.md化。

### 7.7 ツール選び

| 局面 | おすすめ |
|---|---|
| 仕様書きの叩き台 | Claude（長文構造化が得意） |
| コード実装 | Claude Code（Edit/Read/Bash 一体型） |
| 大規模リファクタ | Opus（精度優先） / Sonnet（速度優先） |
| 短いバグ修正 | Sonnet または Haiku |
| ドキュメント横断 | Claude Code の Agent / Explore で並列調査 |
| テスト実行 | Bash で `swift test` を AI に走らせる |

#### CLAUDE.md / settings.local.json の使い分け

- **CLAUDE.md**: 全AI セッションに効く、プロジェクトのルール集
- **`.claude/settings.local.json`**: あなたの環境固有の権限/設定（gitignoreされてOK）

### 7.8 やってはいけない 3つ

#### ① UI 動作確認を AI に任せる

AI には画面が**見えない**。`swift test` が通った = OK、ではない。

#### ② 「全部AIが正しい」と信じる

特に注意:
- 後方互換（既存ユーザーデータ）
- セキュリティ（API key 露出、SQL injection）
- ライセンス（GPLコードを混入させる可能性）
- プライバシーポリシー / 法的文書（テンプレ流用は通らない）

#### ③ メタワークを後回しにする

「とりあえず動く機能を量産 → 後でリファクタ」は **AI駆動開発では特に悪手**。AI は新規機能と整合させるためのリファクタが下手で、コードベースが汚れるほど指示の難易度が上がる。

GuessRank の後半2週間は「最初にやっておけばよかった」整理に費やされた:
- 用語統一（24ファイル）
- docs/future → features 移行
- 命名統一
- CLAUDE.md 制定

### 7.9 まとめ — 1行で言うと

> **AI駆動開発は「速く書く技術」ではなく「速く詰める対話術 + 早めに整える運用術」**

最初の1ヶ月で、書いたコードの量より **CLAUDE.md と docs の質** が伸びていれば、あなたは順調。

---

## 付録: AI駆動開発の鉄則 5つ

このプロジェクトを通じて検証された原則:

1. **docs を先に書け、コードは後** — AI に整合性を要求するなら、整合する仕様が必要。
2. **CLAUDE.md は空でいいから初日に作れ** — 痛い目を見たら即ルール化、それを Claude が読む。
3. **refactor と feat を混ぜるな** — コミットが綺麗だと差し戻しが効く。
4. **PR には "やらなかったこと" を書け** — スコープ膨張の歯止め、未来の自分への申し送り。
5. **AI が見えない領域を覚えておけ** — UI、課金、本番DB、人間の感情。テストが通っても OK ではない。

---

最終更新: 2026-05-07
このドキュメント自体も Claude Opus 4.7 と共同で生成しています。
