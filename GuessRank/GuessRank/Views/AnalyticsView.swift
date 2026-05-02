import SwiftUI

struct AnalyticsView: View {
    let snapshot: GameSessionSnapshot

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // MARK: - Best match pair
                if let best = AnalyticsService.bestMatchPair(snapshot: snapshot) {
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.title)
                            .foregroundStyle(.pink)
                        Text("最も気が合うコンビ")
                            .font(.headline)
                        Text("\(best.playerA.name) & \(best.playerB.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("相互理解度: \(Int(best.mutualScore))点")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // MARK: - Pairwise scores
                pairwiseSection

                // MARK: - Predictability
                predictabilitySection

                // MARK: - Surprise ranking
                surpriseSection
            }
            .padding()
        }
        .navigationTitle("分析")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Pairwise Scores

    private var pairwiseSection: some View {
        VStack(spacing: 12) {
            Label("推測理解度", systemImage: "person.2.fill")
                .font(.headline)

            let pairs = AnalyticsService.pairwiseScores(snapshot: snapshot)
            let players = snapshot.players

            // Matrix grid
            Grid(alignment: .center, horizontalSpacing: 4, verticalSpacing: 4) {
                // Header row
                GridRow {
                    Text("")
                        .frame(width: 50)
                    ForEach(players) { p in
                        Text(String(p.name.prefix(4)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 50)
                    }
                }

                // Data rows
                ForEach(players) { respondent in
                    GridRow {
                        Text(String(respondent.name.prefix(4)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 50)

                        ForEach(players) { questioner in
                            if respondent.id == questioner.id {
                                Text("-")
                                    .font(.caption)
                                    .frame(width: 50, height: 36)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            } else {
                                let score = pairs.first {
                                    $0.fromPlayer.id == respondent.id && $0.toPlayer.id == questioner.id
                                }?.averageScore ?? 0
                                Text("\(Int(score))")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 50, height: 36)
                                    .background(scoreColor(score).opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                }
            }

            Text("行: 回答者 → 列: 出題者 への平均スコア")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Predictability

    private var predictabilitySection: some View {
        VStack(spacing: 12) {
            Label("読まれやすさ", systemImage: "eye.fill")
                .font(.headline)

            let results = AnalyticsService.predictability(snapshot: snapshot)
                .sorted { $0.averageScoreAgainst > $1.averageScoreAgainst }

            ForEach(results, id: \.player.id) { result in
                HStack {
                    Text(result.player.name)
                        .font(.subheadline)
                    Spacer()

                    Text(result.label)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(predictabilityColor(result).opacity(0.15))
                        .clipShape(Capsule())

                    Text("\(Int(result.averageScoreAgainst))点")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(width: 50, alignment: .trailing)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Surprise Ranking

    private var surpriseSection: some View {
        VStack(spacing: 12) {
            Label("サプライズお題", systemImage: "exclamationmark.bubble.fill")
                .font(.headline)

            let ranking = AnalyticsService.surpriseRanking(snapshot: snapshot)

            ForEach(Array(ranking.prefix(3).enumerated()), id: \.offset) { index, item in
                HStack {
                    Text("\(index + 1).")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.question)
                            .font(.subheadline)
                        Text("平均 \(Int(item.averageScore))点")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("意外度 \(Int(item.surpriseIndex))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }

            if ranking.isEmpty {
                Text("データがありません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

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
