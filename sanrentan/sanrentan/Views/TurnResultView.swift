import SwiftUI

struct TurnResultView: View {
    let viewModel: GameProgressViewModel
    @Binding var isGameActive: Bool

    var body: some View {
        ZStack {
            Color.indigo.opacity(0.08)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("\(viewModel.turnLabel) 結果")
                    .font(.title2)
                    .fontWeight(.bold)

                if let turn = viewModel.currentTurn {
                    // Correct answer
                    VStack(spacing: 4) {
                        Text("正解")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(turn.correctRanking.joined(separator: " > "))
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // This turn's scores
                    VStack(spacing: 8) {
                        ForEach(turn.answers, id: \.playerId) { answer in
                            let playerName = viewModel.session.players.first { $0.id == answer.playerId }?.name ?? ""
                            HStack {
                                Text(playerName)
                                    .font(.headline)
                                Spacer()
                                Text("+\(answer.score)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(answer.score == 100 ? .orange : .primary)
                                Text(ScoreService.matchDescription(answer.score))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    // Cumulative standings
                    VStack(spacing: 8) {
                        Text("現在の順位")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(Array(viewModel.sortedResults.enumerated()), id: \.element.id) { index, player in
                            HStack {
                                Text(rankLabel(index + 1))
                                    .frame(width: 30)
                                Text(player.name)
                                    .fontWeight(index == 0 ? .bold : .regular)
                                Spacer()
                                Text("\(player.score)点")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                if viewModel.isLastTurn {
                    Button {
                        viewModel.advanceToNextTurn()
                        isGameActive = false
                    } label: {
                        Text("最終結果を見る")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Button {
                        viewModel.advanceToNextTurn()
                    } label: {
                        Text("次のターンへ")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
    }

    private func rankLabel(_ rank: Int) -> String {
        switch rank {
        case 1: "🥇"
        case 2: "🥈"
        case 3: "🥉"
        default: "\(rank)位"
        }
    }
}
