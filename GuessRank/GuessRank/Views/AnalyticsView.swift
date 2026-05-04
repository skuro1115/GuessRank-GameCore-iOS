import SwiftUI

// MARK: - 相性分析

struct CompatibilityAnalyticsView: View {
    let snapshot: GameSessionSnapshot

    var body: some View {
        VStack(spacing: 16) {
            // Best match pair
            if let best = AnalyticsService.bestMatchPair(snapshot: snapshot) {
                HStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundStyle(.pink)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最も気が合うコンビ")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(best.playerA.name) & \(best.playerB.name)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Text("\(Int(best.mutualScore))点")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.pink)
                }
                .padding(12)
                .background(Color.pink.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Pairwise matrix
            pairwiseSection

            // Predictability
            predictabilitySection

            Spacer()
        }
        .padding()
        .navigationTitle("相性分析")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pairwiseSection: some View {
        VStack(spacing: 8) {
            Label("推測理解度", systemImage: "person.2.fill")
                .font(.subheadline)
                .fontWeight(.semibold)

            let pairs = AnalyticsService.pairwiseScores(snapshot: snapshot)
            let players = snapshot.players

            Grid(alignment: .center, horizontalSpacing: 3, verticalSpacing: 3) {
                GridRow {
                    Text("")
                        .frame(width: 44)
                    ForEach(players) { p in
                        Text(String(p.name.prefix(3)))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .frame(width: 44)
                    }
                }
                ForEach(players) { guesser in
                    GridRow {
                        Text(String(guesser.name.prefix(3)))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .frame(width: 44)

                        ForEach(players) { target in
                            if guesser.id == target.id {
                                Text("-")
                                    .font(.caption2)
                                    .frame(width: 44, height: 30)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            } else {
                                let score = pairs.first {
                                    $0.guesser.id == guesser.id && $0.target.id == target.id
                                }?.averageScore ?? 0
                                Text("\(Int(score))")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .frame(width: 44, height: 30)
                                    .background(scoreColor(score).opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                }
            }

            Text("行: 予想者 → 列: ターゲット")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var predictabilitySection: some View {
        VStack(spacing: 8) {
            Label("読まれやすさ", systemImage: "eye.fill")
                .font(.subheadline)
                .fontWeight(.semibold)

            let results = AnalyticsService.predictability(snapshot: snapshot)
                .sorted { $0.averageScoreAgainst > $1.averageScoreAgainst }

            ForEach(results, id: \.player.id) { result in
                HStack {
                    Text(result.player.name)
                        .font(.caption)
                    Spacer()
                    Text(result.label)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(predictabilityColor(result).opacity(0.15))
                        .clipShape(Capsule())
                    Text("\(Int(result.averageScoreAgainst))点")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 40, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return .green }
        if score >= 40 { return .yellow }
        return .red
    }

    private func predictabilityColor(_ result: PlayerPredictability) -> Color {
        if result.averageScoreAgainst >= 60 { return .green }
        if result.averageScoreAgainst >= 30 { return .yellow }
        return .purple
    }
}

// MARK: - お題分析

struct TopicAnalyticsView: View {
    let snapshot: GameSessionSnapshot

    var body: some View {
        VStack(spacing: 16) {
            let ranking = AnalyticsService.surpriseRanking(snapshot: snapshot)

            // Summary
            if let top = ranking.first {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.bubble.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("最も意外だったお題")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(top.question)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Full ranking
            VStack(spacing: 8) {
                Label("サプライズランキング", systemImage: "list.number")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ForEach(Array(ranking.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 20)

                        Text(item.question)
                            .font(.caption)
                            .lineLimit(1)

                        Spacer()

                        Text("平均\(Int(item.averageScore))点")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("意外度 \(Int(item.surpriseIndex))")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(index == 0 ? Color.orange.opacity(0.06) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                if ranking.isEmpty {
                    Text("データがありません")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Spacer()
        }
        .padding()
        .navigationTitle("お題分析")
        .navigationBarTitleDisplayMode(.inline)
    }
}
