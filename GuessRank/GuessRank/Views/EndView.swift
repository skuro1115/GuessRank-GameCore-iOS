import SwiftUI

/// ファイナルリザルト — 人数に応じて余白を自動調整し1画面に収める
struct EndView: View {
    let snapshot: GameSessionSnapshot
    var onReplay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Ranking with inline stats
            VStack(spacing: 8) {
                ForEach(Array(snapshot.sortedResults.enumerated()), id: \.element.id) { index, player in
                    let perfects = snapshot.perfectMatchCount(for: player.id)
                    let best = snapshot.bestTurn(for: player.id)

                    VStack(spacing: 5) {
                        HStack(spacing: 10) {
                            Text(rankLabel(index + 1))
                                .font(.title2)
                                .frame(width: 36)

                            Text(player.name)
                                .font(.body)
                                .fontWeight(index == 0 ? .bold : .medium)

                            Spacer()

                            Text("\(player.score)点")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        HStack(spacing: 12) {
                            Spacer().frame(width: 36)

                            Label("\(perfects)回", systemImage: "star.fill")
                                .foregroundStyle(.orange)

                            if let best {
                                Label("最高\(best.score)点", systemImage: "flame.fill")
                                    .foregroundStyle(.red)
                            }

                            Spacer()
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(index == 0 ? Color.orange.opacity(0.12) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Spacer(minLength: 12)

            // MARK: - Analytics links
            HStack(spacing: 10) {
                NavigationLink {
                    CompatibilityAnalyticsView(snapshot: snapshot)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "person.2.fill")
                            .font(.title3)
                            .foregroundStyle(.pink)
                        Text("相性分析")
                            .font(.body)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 26)
                    .background(Color.pink.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                NavigationLink {
                    TopicAnalyticsView(snapshot: snapshot)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                        Text("お題分析")
                            .font(.body)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 26)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding()
        .navigationTitle("ゲーム結果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onReplay) {
                    Label("もう1回", systemImage: "arrow.counterclockwise")
                }
                .keyboardShortcut(.return, modifiers: [])
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
