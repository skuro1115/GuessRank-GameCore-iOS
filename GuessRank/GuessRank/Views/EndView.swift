import SwiftUI

/// ファイナルリザルト — 最終順位 + 個人統計。将来の分析可視化の拡張ポイント。
struct EndView: View {
    let snapshot: GameSessionSnapshot
    var onReplay: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Final ranking
                VStack(spacing: 12) {
                    Text("最終順位")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ForEach(Array(snapshot.sortedResults.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Text(rankLabel(index + 1))
                                .font(.title2)
                                .frame(width: 50)

                            Text(player.name)
                                .font(.title3)
                                .fontWeight(index == 0 ? .bold : .regular)

                            Spacer()

                            Text("\(player.score)点")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(index == 0 ? Color.orange.opacity(0.15) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // MARK: - Per-player stats
                VStack(spacing: 12) {
                    Text("個人統計")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ForEach(snapshot.sortedResults) { player in
                        let perfects = snapshot.perfectMatchCount(for: player.id)
                        let best = snapshot.bestTurn(for: player.id)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(player.name)
                                .font(.headline)

                            HStack(spacing: 16) {
                                statItem(icon: "star.fill", value: "\(perfects)回", label: "完全一致", color: .orange)

                                if let best {
                                    statItem(
                                        icon: "flame.fill",
                                        value: "\(best.score)点",
                                        label: "ベストターン",
                                        color: .red
                                    )
                                }

                                statItem(icon: "trophy.fill", value: "\(player.score)点", label: "合計", color: .yellow)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                // MARK: - Future analytics placeholder
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis.ascending")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("詳しい分析は今後のアップデートで追加予定")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // MARK: - Replay
                Button(action: onReplay) {
                    Text("もう1回")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("ゲーム結果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func rankLabel(_ rank: Int) -> String {
        switch rank {
        case 1: "🥇"
        case 2: "🥈"
        case 3: "🥉"
        default: "\(rank)位"
        }
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
