import SwiftUI

/// お題ボード — 全員でお題と選択肢を確認する画面
struct TopicView: View {
    let viewModel: GameProgressViewModel

    private let choiceColors: [Color] = [.red, .blue, .green]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.12), Color.yellow.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Turn badge
                Text(viewModel.turnLabel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                // Questioner
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.orange)
                    Text("出題者: \(viewModel.questioner.name)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                // Topic question
                if let topic = viewModel.currentTopic {
                    Text(topic.question)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Choices
                    VStack(spacing: 12) {
                        ForEach(Array(topic.choices.enumerated()), id: \.offset) { index, choice in
                            HStack(spacing: 12) {
                                Text(["A", "B", "C"][index])
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(choiceColors[index].opacity(0.8))
                                    .clipShape(Circle())

                                Text(choice)
                                    .font(.title3)
                                    .fontWeight(.medium)

                                Spacer()
                            }
                            .padding()
                            .background(.ultraThickMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }

                Spacer()

                Button {
                    viewModel.startQuestionerInput()
                } label: {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                        Text("\(viewModel.questioner.name) が順位を決める")
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
    }
}
