import SwiftUI

/// ゲームクリア — 全ターン終了後の演出画面。優勝者を大きく発表する。
struct GameClearView: View {
    let snapshot: GameSessionSnapshot
    var onShowDetails: () -> Void

    @State private var showWinner = false
    @State private var showStats = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.10), Color.pink.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text("GAME CLEAR")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(.secondary)

                if let winner = snapshot.winner, showWinner {
                    Text("🏆")
                        .font(.system(size: 72))
                        .scaleEffect(showWinner ? 1.0 : 0.3)

                    Text(winner.name)
                        .font(.system(size: 44, weight: .bold))

                    Text("\(winner.score)点")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.orange)
                }

                if showStats {
                    // Quick stats summary
                    VStack(spacing: 12) {
                        let perfectCount = snapshot.totalPerfectMatches()
                        let turnCount = snapshot.turns.count
                        let playerCount = snapshot.players.count

                        HStack(spacing: 24) {
                            statBadge(value: "\(turnCount)", label: "ターン")
                            statBadge(value: "\(playerCount)", label: "プレイヤー")
                            statBadge(value: "\(perfectCount)", label: "完全一致")
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                Button(action: onShowDetails) {
                    HStack {
                        Text("詳細結果を見る")
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .orange.opacity(0.3), radius: 8, y: 4)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.4).delay(0.3)) {
                showWinner = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                showStats = true
            }
        }
    }

    private func statBadge(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
