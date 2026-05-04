import SwiftUI

struct RankingEditor: View {
    @Binding var items: [String]
    var accentColor: Color = .accentColor
    var originalChoices: [String] = []

    @GestureState private var dragState = DragState.inactive
    @State private var activeIndex: Int?

    private static let choiceColors: [Color] = [.red, .blue, .green]
    private static let choiceLabels = ["A", "B", "C"]

    private let rankLabels = ["1st", "2nd", "3rd"]
    private let rowHeight: CGFloat = 76
    private let rowSpacing: CGFloat = 10

    private var rowStep: CGFloat { rowHeight + rowSpacing }

    var body: some View {
        ZStack {
            VStack(spacing: rowSpacing) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    rowView(index: index, item: item)
                        .offset(y: offsetFor(index: index))
                        .scaleEffect(activeIndex == index && dragState.isActive ? 1.05 : 1.0)
                        .shadow(
                            color: activeIndex == index && dragState.isActive ? .black.opacity(0.2) : .clear,
                            radius: 8, y: 3
                        )
                        .zIndex(activeIndex == index ? 1 : 0)
                        .gesture(
                            DragGesture()
                                .updating($dragState) { value, state, _ in
                                    state = .dragging(translation: value.translation.height)
                                }
                                .onChanged { _ in
                                    if activeIndex == nil {
                                        activeIndex = index
                                    }
                                }
                                .onEnded { value in
                                    let translation = value.translation.height
                                    let steps = Int(round(translation / rowStep))
                                    let clampedSteps = max(-index, min(items.count - 1 - index, steps))

                                    if clampedSteps != 0 {
                                        let targetIndex = index + clampedSteps
                                        withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                                            items.move(
                                                fromOffsets: IndexSet(integer: index),
                                                toOffset: targetIndex > index ? targetIndex + 1 : targetIndex
                                            )
                                        }
                                    }
                                    activeIndex = nil
                                }
                        )
                        .animation(.spring(duration: 0.35, bounce: 0.15), value: activeIndex)
                }
            }
        }
    }

    private func rowView(index: Int, item: String) -> some View {
        let choiceIndex = originalChoices.firstIndex(of: item) ?? 0

        return HStack(spacing: 14) {
            Text(rankLabels[index])
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 40, height: 28)
                .background(accentColor.opacity(index == 0 ? 1.0 : index == 1 ? 0.7 : 0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            // Choice color badge
            if !originalChoices.isEmpty {
                Text(Self.choiceLabels[choiceIndex])
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Self.choiceColors[choiceIndex].opacity(0.8))
                    .clipShape(Circle())
            }

            Text(item)
                .font(.title2)
                .fontWeight(.medium)

            Spacer()

            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(minHeight: rowHeight)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func offsetFor(index: Int) -> CGFloat {
        guard activeIndex == index, case .dragging(let translation) = dragState else {
            return 0
        }
        return translation
    }
}

private enum DragState: Equatable {
    case inactive
    case dragging(translation: CGFloat)

    var isActive: Bool {
        if case .dragging = self { return true }
        return false
    }
}
