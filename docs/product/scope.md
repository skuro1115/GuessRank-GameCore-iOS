# MVPスコープ定義

> このドキュメントは「MVP として何を作る／作らないか」の **判断基準** を残すものです。実装済み機能は `docs/features/` 配下の spec.md が SSOT、優先順位は [future/roadmap.md](../future/roadmap.md) が SSOT。

## スコープ判断基準

MVPに含めるかの判断：

> **「ローカルで1ゲーム完走できるか」に必要かどうか**

- 必要 → MVP
- あると良い → Phase 2以降（[future/roadmap.md](../future/roadmap.md)）
- なくても遊べる → 後回し

---

## MVP（リリース対象）

### 通信モード

- ローカル（1台共有）のみ

### コア機能

| 機能 | features/ |
|---|---|
| プレイヤー登録・人数設定 | [game_settings/](../features/game_settings/) |
| ジャンル / 難易度 / サイクル / プレイモード設定 | [game_settings/](../features/game_settings/) |
| ターン進行・端末回し・覗き見防止 | [game_progress/](../features/game_progress/) |
| お題抽選 / お題変更 | [game_progress/](../features/game_progress/) |
| スコア計算（順位一致度ベース） | [game_progress/](../features/game_progress/) |
| 最終順位表示・再戦 | [end_screen/](../features/end_screen/) |
| 通信設定画面（ローカル固定） | [communication_settings/](../features/communication_settings/) |

### MVP に含めたが当初の Phase 2 想定だったもの

実装の流れで前倒した機能。`features/` に SSOT を持つ:

| 機能 | features/ | 理由 |
|---|---|---|
| お題履歴・重複回避 | [topic_history/](../features/topic_history/) | 同じお題が繰り返されるとプレイ感が単調 |
| お題フィードバック（ブロック / 面白い） | [topic_feedback/](../features/topic_feedback/) | お題の質改善が体験の核 |
| ハードモード（6択上位3つ） | [play_modes/](../features/play_modes/) | リプレイ性確保 |
| 1ゲーム分の分析（相性・サプライズ） | [analytics/](../features/analytics/) | 終了画面の納得感 |
| 機能フラグ基盤 / 開発者モード | [feature_flags/](../features/feature_flags/) + [dev_mode/](../features/dev_mode/) | 開発・QA 効率 |

---

## MVP外（Phase 2 以降）

優先順位は [future/roadmap.md](../future/roadmap.md) を参照。

| 機能 | 予定 | 理由 |
|---|---|---|
| Firebase 基盤 + Topic FB アップロード | Phase 2 | multiplayer / 課金の前提 |
| 複数台通信（ネット） | Phase 2 | 体験拡大の主要候補だが実装規模が大きい |
| AdMob + 広告削除 IAP | Phase 3 | ユーザーベースが先 |
| 複数台通信（Bluetooth） | Phase 3 | 実装コスト高 |
| お題リモート配信 | 保留 | 当面はバンドル内蔵で十分 |
| 累計分析（横断統計） | 不要判断 | パーティーゲームの player identity が安定しない |
