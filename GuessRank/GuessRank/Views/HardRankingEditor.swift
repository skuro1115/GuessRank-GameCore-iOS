import SwiftUI

/// ハードモード用ランキング入力 — 6つの選択肢から上位3つを選んでスロットに配置する。
///
/// インタラクション:
/// - 未選択の選択肢タップ → 次の空きスロットに入る
/// - 選択済みの選択肢タップ → スロットから外れる
/// - 埋まったスロットタップ → そのスロットだけ外れる
struct HardRankingEditor: View {
    @Binding var ranking: [String]
    let choices: [String]
    var accentColor: Color = .accentColor

    private let slotCount = 3
    private let slotLabels = ["1位", "2位", "3位"]
    private static let choiceColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]
    private static let choiceLabels = ["A", "B", "C", "D", "E", "F"]

    var body: some View {
        VStack(spacing: 18) {
            // Slots row (top 3 selected)
            HStack(spacing: 8) {
                ForEach(0..<slotCount, id: \.self) { index in
                    slotView(index)
                }
            }

            // Choices grid
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(Array(choices.enumerated()), id: \.offset) { index, choice in
                    choiceTile(index: index, choice: choice)
                }
            }
        }
    }

    private var rankingSet: Set<String> { Set(ranking) }
    private var isFull: Bool { ranking.count >= slotCount }

    @ViewBuilder
    private func slotView(_ index: Int) -> some View {
        let item: String? = index < ranking.count ? ranking[index] : nil
        Button {
            if item != nil {
                ranking.remove(at: index)
            }
        } label: {
            VStack(spacing: 4) {
                Text(slotLabels[index])
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(accentColor.opacity(index == 0 ? 1.0 : index == 1 ? 0.7 : 0.4))
                    .clipShape(Capsule())

                if let item {
                    Text(item)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                } else {
                    Text("—")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 76)
            .padding(.vertical, 8)
            .background(item != nil ? accentColor.opacity(0.18) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(item != nil ? accentColor : Color(.systemGray4), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(item == nil)
    }

    private func choiceTile(index: Int, choice: String) -> some View {
        let isSelected = rankingSet.contains(choice)
        let badgeColor = Self.choiceColors[index % Self.choiceColors.count]
        let label = Self.choiceLabels[index % Self.choiceLabels.count]
        let canTap = isSelected || !isFull

        return Button {
            if isSelected {
                ranking.removeAll { $0 == choice }
            } else if !isFull {
                ranking.append(choice)
            }
        } label: {
            HStack(spacing: 10) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(badgeColor.opacity(0.85))
                    .clipShape(Circle())

                Text(choice)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                if let rankIndex = ranking.firstIndex(of: choice) {
                    Text("\(rankIndex + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(accentColor)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(isSelected ? accentColor.opacity(0.15) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!canTap)
        .opacity(canTap ? 1.0 : 0.5)
        .keyboardShortcut(KeyEquivalent(Character(String(index + 1))), modifiers: [])
    }
}
