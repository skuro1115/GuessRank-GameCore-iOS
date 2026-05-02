import SwiftUI

/// ランキング入力 — ターゲット/予想者が順位を並べ替える画面
struct RankingInputView: View {
    @Bindable var viewModel: GameProgressViewModel

    private var accentColor: Color {
        viewModel.isTargetInput ? .orange : .cyan
    }

    var body: some View {
        ZStack {
            accentColor.opacity(0.06)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                if let player = viewModel.currentInputPlayer {
                    if viewModel.isTargetInput {
                        Label("\(player.name) の好みの順位", systemImage: "crown.fill")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(player.name) の予想")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.orange)
                            Text("\(viewModel.targetPlayer.name)")
                                .fontWeight(.semibold)
                            Text("はどう並べる?")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }

                if let topic = viewModel.currentTopic {
                    Text(topic.question)
                        .font(.title3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }

                RankingEditor(items: $viewModel.rankingInput, accentColor: accentColor)

                Spacer()

                Button {
                    viewModel.submitRanking()
                } label: {
                    Text("決定")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: accentColor.opacity(0.3), radius: 8, y: 4)
                }
            }
            .padding()
        }
    }
}
