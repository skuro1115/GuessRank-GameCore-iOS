import SwiftUI

struct TurnResultView: View {
    let viewModel: GameProgressViewModel
    @Binding var isGameActive: Bool

    // MARK: - Animation state

    /// Phase 1: 予想者の行が公開されたか（全員同時）
    @State private var guessersRevealed = false
    /// Phase 1b: 予想者サークルの公開数（0→1→2→3、3位→2位→1位）
    @State private var guesserCircleCount = 0

    /// Phase 2: ターゲット行が公開されたか
    @State private var targetRevealed = false
    /// Phase 2b: ターゲットサークルの公開数（0→1→2→3）
    @State private var targetCircleCount = 0

    /// Phase 3: 正誤ハイライト
    @State private var showMatches = false

    private static let choiceColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]
    private static let choiceLabels = ["A", "B", "C", "D", "E", "F"]

    // MARK: - Computed helpers

    private var orderedPlayers: [Player] {
        viewModel.session.players.sorted { $0.order < $1.order }
    }

    private var turn: Turn? { viewModel.currentTurn }

    /// ランキング位置 i のサークルが表示されるか
    /// ranking[0]=1位, [1]=2位, [2]=3位 → 3位から表示
    private func isCircleVisible(at rankIndex: Int, circleCount: Int) -> Bool {
        // rankIndex=2(3位) → count>=1 で表示
        // rankIndex=1(2位) → count>=2 で表示
        // rankIndex=0(1位) → count>=3 で表示
        circleCount >= (3 - rankIndex)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.indigo.opacity(0.08)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("\(viewModel.turnLabel) 結果")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)

                if let turn {
                    Text(turn.topic.question)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)

                    choiceLegend(choices: turn.topic.choices)
                        .padding(.bottom, 12)

                    VStack(spacing: 8) {
                        ForEach(orderedPlayers) { player in
                            let isTarget = player.id == turn.targetPlayerId
                            playerRow(player: player, turn: turn, isTarget: isTarget)
                        }
                    }
                }

                Spacer(minLength: 16)

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
                    .keyboardShortcut(.return, modifiers: [])
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
                    .keyboardShortcut(.return, modifiers: [])
                }
            }
            .padding()
        }
        .onAppear { scheduleReveals() }
    }

    // MARK: - Player row

    @ViewBuilder
    private func playerRow(player: Player, turn: Turn, isTarget: Bool) -> some View {
        let originalChoices = turn.topic.choices

        if isTarget {
            targetRow(player: player, turn: turn, originalChoices: originalChoices)
        } else {
            guesserRow(player: player, turn: turn, originalChoices: originalChoices)
        }
    }

    // MARK: - Target row

    private func targetRow(player: Player, turn: Turn, originalChoices: [String]) -> some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text(player.name)
                    .font(.body)
                    .fontWeight(.bold)
            }
            .frame(width: 80, alignment: .leading)
            .lineLimit(1)

            HStack(spacing: 6) {
                ForEach(Array(turn.correctRanking.enumerated()), id: \.offset) { i, choice in
                    if targetRevealed && isCircleVisible(at: i, circleCount: targetCircleCount) {
                        choiceCircle(choice: choice, originalChoices: originalChoices, matchState: .neutral)
                            .transition(.scale(scale: 0.3).combined(with: .opacity))
                    } else {
                        hiddenCircle()
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.65), value: targetCircleCount)

            Spacer()

            Text("正解")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(targetRevealed ? .orange : .clear)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxHeight: .infinity)
        .background(targetRevealed ? Color.orange.opacity(0.12) : Color(.systemGray5).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeOut(duration: 0.3), value: targetRevealed)
    }

    // MARK: - Guesser row

    private func guesserRow(player: Player, turn: Turn, originalChoices: [String]) -> some View {
        let answer = turn.answers.first { $0.playerId == player.id }
        let total = player.score

        return HStack(spacing: 10) {
            Text(player.name)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            if guessersRevealed, let answer {
                HStack(spacing: 6) {
                    ForEach(Array(answer.ranking.enumerated()), id: \.offset) { i, choice in
                        if isCircleVisible(at: i, circleCount: guesserCircleCount) {
                            let isMatch = i < turn.correctRanking.count && turn.correctRanking[i] == choice
                            let state: MatchState = showMatches
                                ? (isMatch ? .matched : .mismatched)
                                : .neutral
                            choiceCircle(choice: choice, originalChoices: originalChoices, matchState: state)
                                .transition(.scale(scale: 0.3).combined(with: .opacity))
                        } else {
                            hiddenCircle()
                        }
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.65), value: guesserCircleCount)

                Spacer()

                if showMatches {
                    if answer.score == 100 {
                        Text("🎯+\(answer.score)")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("+\(answer.score)")
                            .font(.body)
                            .fontWeight(.bold)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Text("計\(total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 42, alignment: .trailing)
                        .transition(.opacity)
                }
            } else {
                hiddenCircles()
                Spacer()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeOut(duration: 0.3), value: guessersRevealed)
        .animation(.easeOut(duration: 0.3), value: showMatches)
    }

    // MARK: - Choice legend

    private func choiceLegend(choices: [String]) -> some View {
        // Choices may be 3 (normal) or 6 (hard); use a flow that wraps when crowded.
        let columnCount = choices.count > 3 ? 3 : choices.count
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount),
            alignment: .leading,
            spacing: 4
        ) {
            ForEach(Array(choices.enumerated()), id: \.offset) { i, choice in
                HStack(spacing: 4) {
                    Text(Self.choiceLabels[i % Self.choiceLabels.count])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Self.choiceColors[i % Self.choiceColors.count].opacity(0.8))
                        .clipShape(Circle())
                    Text(choice)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Hidden circles

    private func hiddenCircles() -> some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { _ in hiddenCircle() }
        }
    }

    private func hiddenCircle() -> some View {
        Text("?")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white.opacity(0.6))
            .frame(width: 32, height: 32)
            .background(Color.gray.opacity(0.4))
            .clipShape(Circle())
    }

    // MARK: - Choice circle

    private enum MatchState: Equatable {
        case neutral, matched, mismatched
    }

    private func choiceCircle(choice: String, originalChoices: [String], matchState: MatchState) -> some View {
        let index = originalChoices.firstIndex(of: choice) ?? 0
        let color = Self.choiceColors[index % Self.choiceColors.count]
        let label = Self.choiceLabels[index % Self.choiceLabels.count]

        return Text(label)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(color.opacity(0.8))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(strokeColor(for: matchState), lineWidth: strokeWidth(for: matchState))
                    .frame(width: 37, height: 37)
            )
            .scaleEffect(matchState == .matched ? 1.15 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: matchState)
    }

    private func strokeColor(for state: MatchState) -> Color {
        switch state {
        case .neutral: .gray.opacity(0.3)
        case .matched: .green
        case .mismatched: .red.opacity(0.4)
        }
    }

    private func strokeWidth(for state: MatchState) -> CGFloat {
        switch state {
        case .neutral: 1.5
        case .matched: 3
        case .mismatched: 1.5
        }
    }

    // MARK: - 3-phase staggered reveal

    private func scheduleReveals() {
        HapticsService.turnComplete()

        let circleInterval: Double = 0.45
        var t: Double = 0.5

        // ── Phase 1: 予想者を全員同時に公開 → サークルを3位→2位→1位 ──
        DispatchQueue.main.asyncAfter(deadline: .now() + t) {
            guessersRevealed = true
        }
        for step in 1...3 {
            let delay = t + circleInterval * Double(step)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation { guesserCircleCount = step }
            }
        }
        t += circleInterval * 3

        // ── Phase 2: ターゲットの正解を公開 → サークルを3位→2位→1位 ──
        t += 0.5
        let targetStart = t
        DispatchQueue.main.asyncAfter(deadline: .now() + targetStart) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                targetRevealed = true
            }
        }
        for step in 1...3 {
            let delay = targetStart + circleInterval * Double(step)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation { targetCircleCount = step }
            }
        }
        t = targetStart + circleInterval * 3

        // ── Phase 3: 正誤ハイライト ──
        t += 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + t) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                showMatches = true
            }
            if let turn, turn.answers.contains(where: { $0.score == 100 }) {
                HapticsService.perfectMatch()
            }
        }
    }
}
