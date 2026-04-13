# アーキテクチャ概要

## 技術スタック

| レイヤー | 技術 |
|---|---|
| UI | SwiftUI（iOS 17+） |
| 言語 | Swift |
| アーキテクチャ | MVVM |
| 状態管理 | @Observable / @State / @Bindable |
| ローカル保存 | なし（MVP） |
| 通信 | なし（MVP）→ Firebase（Phase 2） |
| 対応プラットフォーム | iOS |

## レイヤー構成

```
View (SwiftUI)
  ↕ @State / @Bindable
ViewModel (@Observable)
  ↕
Model + Service
  ↕
(将来) Firebase / Local Storage
```

## 依存方向

```
View → ViewModel → Service → (外部)
              ↓
            Model
```

- View は ViewModel のみを参照する
- ViewModel は Service と Model を参照する
- Model はどこにも依存しない（純粋データ構造体）
- Service は外部接続を担当する（MVPでは最小限）

## 設計原則

### ゲームロジックは純粋関数化

```swift
// Good: 入力と出力が明確、テスト可能
func calculateScore(correct: [String], answer: [String]) -> Int { ... }

// Bad: 状態に依存
func calculateScore() -> Int { session.currentTurn.score }
```

### スコア計算は独立

スコア計算ロジックはゲーム進行から分離し、単体テスト可能にする。

### 状態はCodableで持つ

将来の通信対応に備え、すべての状態は `Codable` 準拠で変換可能にする。

### UIとロジックの分岐

| 項目 | ローカル | 複数台（将来） |
|---|---|---|
| UI | 端末回しUI | 個別入力UI |
| ゲームロジック | **共通** | **共通** |
| 状態管理 | **共通** | **共通** |
| 通信層 | なし | Firebase / Bluetooth |

> UIは分岐、ロジックは共通
