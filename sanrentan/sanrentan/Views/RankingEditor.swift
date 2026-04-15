import SwiftUI

struct RankingEditor: View {
    @Binding var items: [String]
    var accentColor: Color = .accentColor

    private let rankLabels = ["1st", "2nd", "3rd"]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                HStack(spacing: 12) {
                    Text(rankLabels[index])
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 24)
                        .background(accentColor.opacity(index == 0 ? 1.0 : index == 1 ? 0.7 : 0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Text(item)
                        .font(.title3)
                        .fontWeight(.medium)

                    Spacer()

                    Button {
                        moveUp(index)
                    } label: {
                        Image(systemName: "chevron.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(index == 0 ? Color(.systemGray4) : accentColor)
                    }
                    .disabled(index == 0)

                    Button {
                        moveDown(index)
                    } label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundStyle(index == items.count - 1 ? Color(.systemGray4) : accentColor)
                    }
                    .disabled(index == items.count - 1)
                }
                .padding()
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func moveUp(_ index: Int) {
        guard index > 0 else { return }
        items.swapAt(index, index - 1)
    }

    private func moveDown(_ index: Int) {
        guard index < items.count - 1 else { return }
        items.swapAt(index, index + 1)
    }
}
