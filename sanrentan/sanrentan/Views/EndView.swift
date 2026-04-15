import SwiftUI

struct EndView: View {
    let viewModel: GameProgressViewModel
    var onReplay: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("ゲーム終了!")
                .font(.largeTitle)
                .fontWeight(.bold)

            let sorted = viewModel.sortedResults

            VStack(spacing: 12) {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, player in
                    HStack {
                        Text(rankLabel(index + 1))
                            .font(.title2)
                            .frame(width: 50)

                        Text(player.name)
                            .font(.title3)
                            .fontWeight(index == 0 ? .bold : .regular)

                        Spacer()

                        Text("\(player.score)点")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(index == 0 ? Color.orange.opacity(0.15) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Spacer()

            Button(action: onReplay) {
                Text("もう1回")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .navigationTitle("最終結果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
