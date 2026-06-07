import SwiftUI

/// 開発者モードのデバッグオーバーレイ。ゲーム進行画面の右上に半透明の小さなパネルとして
/// 現在のターン番号 / フェーズ / 入力中プレイヤー / 直近スコアの最大値を表示する。
///
/// 表示制御は `FeatureFlag.debugOverlayEnabled` を経由する。詳細は
/// `docs/features/dev_mode/spec.md` を参照。
struct DebugOverlay: View {
    let viewModel: GameProgressViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("turn \(viewModel.session.currentTurnIndex + 1)/\(viewModel.session.totalTurns)")
            Text("phase: \(phaseLabel)")
            if let player = viewModel.currentInputPlayer {
                Text("input: \(player.name)")
            }
            if let topicId = viewModel.currentTopic?.id {
                Text("topic: \(topicId)")
            }
            if let lastScore = lastTurnTopScore {
                Text("last best: \(lastScore)")
            }
        }
        .font(.system(size: 9, weight: .medium, design: .monospaced))
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var phaseLabel: String {
        switch viewModel.phase {
        case .showTopic:
            "showTopic"
        case .rankingInput(let index, let covered):
            "rankingInput(\(index),\(covered ? "covered" : "uncovered"))"
        case .showResult:
            "showResult"
        }
    }

    /// 直近完了ターンの最高スコアを表示用に取得（completed なターンのみ対象）。
    private var lastTurnTopScore: Int? {
        viewModel.session.turns
            .last(where: { $0.isCompleted })?
            .answers
            .map(\.score)
            .max()
    }
}
