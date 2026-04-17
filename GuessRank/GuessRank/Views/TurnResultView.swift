import SwiftUI

struct TurnResultView: View {
    let viewModel: GameProgressViewModel
    @Binding var isGameActive: Bool

    @State private var showAnswers = false
    @State private var showStandings = false
    @State private var hasPerfectMatch = false

    var body: some View {
        ZStack {
            Color.indigo.opacity(0.08)
                .ignoresSafeArea()

            ScrollView {
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
                        if showAnswers {
                            VStack(spacing: 8) {
                                ForEach(turn.answers, id: \.playerId) { answer in
                                    let playerName = viewModel.session.players.first { $0.id == answer.playerId }?.name ?? ""
                                    HStack {
                                        Text(playerName)
                                            .font(.headline)
                                        Spacer()

                                        if answer.score == 100 {
                                            Text("🎯 +\(answer.score)")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.orange)
                                        } else {
                                            Text("+\(answer.score)")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                        }

                                        Text(ScoreService.matchDescription(answer.score))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .background(answer.score == 100 ? Color.orange.opacity(0.1) : Color.clear)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Cumulative standings
                        if showStandings {
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
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }

                    Spacer(minLength: 20)

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
        .onAppear {
            let answers = viewModel.currentTurn?.answers ?? []
            hasPerfectMatch = answers.contains { $0.score == 100 }

            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                showAnswers = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                showStandings = true
            }

            HapticsService.turnComplete()
            if hasPerfectMatch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    HapticsService.perfectMatch()
                }
            }
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
