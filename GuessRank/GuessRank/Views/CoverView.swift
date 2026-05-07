import SwiftUI

/// プレイヤーコール — 次のプレイヤーに端末を渡す覗き見防止画面
struct CoverView: View {
    let viewModel: GameProgressViewModel

    var body: some View {
        ZStack {
            (viewModel.isTargetInput
                ? Color.orange.opacity(0.10)
                : Color.cyan.opacity(0.10))
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Icon
                Image(systemName: viewModel.isTargetInput
                    ? "crown.fill" : "person.fill.questionmark")
                    .font(.system(size: 48))
                    .foregroundStyle(viewModel.isTargetInput ? .orange : .cyan)
                    .padding(.bottom, 8)

                // Role badge
                Text(viewModel.isTargetInput ? "ターゲット" : "予想者")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        (viewModel.isTargetInput ? Color.orange : Color.cyan).opacity(0.15)
                    )
                    .clipShape(Capsule())

                if let player = viewModel.currentInputPlayer {
                    Text(player.name)
                        .font(.system(size: 40, weight: .bold))

                    if viewModel.isTargetInput {
                        Text("自分の好みの順位を決めてください")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(viewModel.targetPlayer.name) の好みを予想しよう")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button {
                    viewModel.uncoverInput()
                } label: {
                    Text("タップして開始")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isTargetInput ? Color.orange : Color.cyan)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: (viewModel.isTargetInput ? Color.orange : Color.cyan).opacity(0.3),
                            radius: 8, y: 4
                        )
                }
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding()
        }
    }
}
