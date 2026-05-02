import SwiftUI

struct HistoryDetailView: View {
    let entry: GameHistoryEntry

    private var snapshot: GameSessionSnapshot { entry.snapshot }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date + config
                VStack(spacing: 4) {
                    Text(entry.playedAt, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        Label(snapshot.config.genre.displayName, systemImage: "tag")
                        Label(snapshot.config.difficulty.displayName, systemImage: "speedometer")
                        Label("\(snapshot.totalTurns)ターン", systemImage: "arrow.trianglehead.2.counterclockwise")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // Final ranking
                VStack(spacing: 8) {
                    ForEach(Array(snapshot.sortedResults.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Text(rankLabel(index + 1))
                                .font(.title2)
                                .frame(width: 40)
                            Text(player.name)
                                .font(.headline)
                                .fontWeight(index == 0 ? .bold : .regular)
                            Spacer()
                            Text("\(player.score)点")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(index == 0 ? Color.orange.opacity(0.12) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // Per-player stats
                VStack(spacing: 8) {
                    Text("統計")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ForEach(snapshot.sortedResults) { player in
                        let perfects = snapshot.perfectMatchCount(for: player.id)

                        HStack {
                            Text(player.name)
                            Spacer()
                            Label("\(perfects)回", systemImage: "star.fill")
                                .foregroundStyle(.orange)
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
        }
        .navigationTitle("ゲーム詳細")
        .navigationBarTitleDisplayMode(.inline)
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
