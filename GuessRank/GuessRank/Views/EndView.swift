import SwiftUI

/// ファイナルリザルト — 人数に応じて余白を自動調整し1画面に収める
struct EndView: View {
    let snapshot: GameSessionSnapshot
    var onReplay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Ranking with inline stats
            // 全順位を1枚のカードに集約し、共通地で表示する（1位だけを塗り分けない）。
            // 序列は順位ラベルのみで控えめに示す — 全員の得点が「理解度」として意味を持つため。
            VStack(spacing: 0) {
                ForEach(Array(snapshot.sortedResults.enumerated()), id: \.element.id) { index, player in
                    let perfects = snapshot.perfectMatchCount(for: player.id)
                    let best = snapshot.bestTurn(for: player.id)

                    if index > 0 {
                        Divider()
                            .padding(.leading, 62)
                    }

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
                                .foregroundStyle(Color.grGold)

                            if let best {
                                Label("最高\(best.score)点", systemImage: "flame.fill")
                                    .foregroundStyle(.red)
                            }

                            Spacer()
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer(minLength: 12)

            // MARK: - Analytics links
            HStack(spacing: 10) {
                NavigationLink {
                    CompatibilityAnalyticsView(snapshot: snapshot)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "person.2.fill")
                            .font(.title3)
                            .foregroundStyle(Color.grPink)
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
                    .background(Color.grPink.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                NavigationLink {
                    TopicAnalyticsView(snapshot: snapshot)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.title3)
                            .foregroundStyle(Color.grAccent)
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
                    .background(Color.grAccent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
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

/// brand.md / design_explore.md のトークン値（Swift 側トークン層は未導入のため直接定義）
private extension Color {
    /// `--gr-accent` #FF8C00
    static let grAccent = Color(red: 1.0, green: 0x8C / 255, blue: 0)
    /// `--gr-gold` #F59E0B
    static let grGold = Color(red: 0xF5 / 255, green: 0x9E / 255, blue: 0x0B / 255)
    /// `--gr-pink` #FF6B8A
    static let grPink = Color(red: 1.0, green: 0x6B / 255, blue: 0x8A / 255)
}
