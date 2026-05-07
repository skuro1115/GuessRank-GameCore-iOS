import SwiftUI

/// お題ボード — 全員でお題と選択肢を確認する画面
struct TopicView: View {
    let viewModel: GameProgressViewModel

    private let choiceColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]
    private let choiceLabels = ["A", "B", "C", "D", "E", "F"]

    @State private var feedbackMessage: String?

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
                    Text("ターゲット: \(viewModel.targetPlayer.name)")
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
                    if topic.playMode == .hard {
                        // 6 choices in a 2-column grid for compact display
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 8
                        ) {
                            ForEach(Array(topic.choices.enumerated()), id: \.offset) { index, choice in
                                HStack(spacing: 8) {
                                    Text(choiceLabels[index % choiceLabels.count])
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: 26, height: 26)
                                        .background(choiceColors[index % choiceColors.count].opacity(0.8))
                                        .clipShape(Circle())

                                    Text(choice)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .lineLimit(2)

                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 12)
                                .background(.ultraThickMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(topic.choices.enumerated()), id: \.offset) { index, choice in
                                HStack(spacing: 12) {
                                    Text(choiceLabels[index % choiceLabels.count])
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background(choiceColors[index % choiceColors.count].opacity(0.8))
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
                }

                Spacer()

                // Action buttons
                HStack(spacing: 12) {
                    // Pass button — お題が場に合わないときのための安全弁（回数無制限）
                    Button {
                        viewModel.passTopic()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.right")
                            Text("お題を変える")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // Start button
                    Button {
                        viewModel.startTargetInput()
                    } label: {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                            Text("\(viewModel.targetPlayer.name) が好みの順位を決める")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .orange.opacity(0.3), radius: 8, y: 4)
                    }
                    .keyboardShortcut(.return, modifiers: [])
                }
            }
            .padding()

            // Top-right feedback buttons (👍 / ⋯)
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Button {
                            viewModel.toggleLikeCurrentTopic()
                            feedbackMessage = viewModel.isCurrentTopicLiked
                                ? "面白いお題として記録しました"
                                : "「面白い」を取り消しました"
                        } label: {
                            Image(systemName: viewModel.isCurrentTopicLiked
                                ? "hand.thumbsup.fill"
                                : "hand.thumbsup")
                                .font(.title3)
                                .foregroundStyle(viewModel.isCurrentTopicLiked ? .orange : .secondary)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel(viewModel.isCurrentTopicLiked ? "面白いを取り消す" : "面白いお題として記録")
                        .disabled(viewModel.currentTopic == nil)

                        Menu {
                            ForEach(TopicBlockReason.allCases, id: \.self) { reason in
                                Button {
                                    viewModel.blockCurrentTopic(reason: reason)
                                    feedbackMessage = "お題をブロックしました（\(reason.displayName)）"
                                } label: {
                                    Label("ブロック: \(reason.displayName)", systemImage: "hand.raised")
                                }
                            }
                            Button(role: .destructive) {
                                viewModel.blockCurrentTopic(reason: nil)
                                feedbackMessage = "お題をブロックしました"
                            } label: {
                                Label("理由なしでブロック", systemImage: "hand.raised.slash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("その他のFB")
                        .disabled(viewModel.currentTopic == nil)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                Spacer()
            }

            if let message = feedbackMessage {
                VStack {
                    Text(message)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 60)
                    Spacer()
                }
                .transition(.opacity)
                .id(message)
                .task(id: message) {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    withAnimation { feedbackMessage = nil }
                }
            }
        }
    }
}
