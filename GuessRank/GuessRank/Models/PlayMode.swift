import Foundation

/// プレイモード — 選択肢数と回答スタイルを切り替える。
///
/// - `.normal`: 選択肢3つ、全ての順位を当てる（MVP標準）
/// - `.hard`:   選択肢6つ、上位3つ（1位・2位・3位）を当てる
enum PlayMode: String, Codable, CaseIterable {
    case normal
    case hard

    /// お題が持つ選択肢の数。
    var choiceCount: Int {
        switch self {
        case .normal: 3
        case .hard: 6
        }
    }

    /// 予想する順位スロットの数（常に 1〜3 位）。
    var rankSlotCount: Int { 3 }

    var displayName: String {
        switch self {
        case .normal: "ノーマル"
        case .hard: "ハード"
        }
    }

    var shortDescription: String {
        switch self {
        case .normal: "選択肢3つ・全順位を当てる"
        case .hard: "選択肢6つ・上位3つを当てる"
        }
    }
}
