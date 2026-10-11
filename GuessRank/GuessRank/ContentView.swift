import SwiftUI

enum AppScreen {
    case settings
    case game
    case gameClear
    case end
    case history
}

struct ContentView: View {
    @Environment(\.featureFlags) private var featureFlags
    @State private var screen: AppScreen = .settings
    @State private var setupViewModel = GameSetupViewModel()
    @State private var gameViewModel: GameProgressViewModel?
    @State private var endSnapshot: GameSessionSnapshot?
    @State private var historyStore = GameHistoryStore()
    @State private var topicHistoryStore = TopicHistoryStore()
    @State private var topicFeedbackStore = TopicFeedbackStore()

    var body: some View {
        NavigationStack {
            switch screen {
            case .settings:
                GameSettingsView(
                    viewModel: setupViewModel,
                    topicHistoryStore: topicHistoryStore,
                    topicFeedbackStore: topicFeedbackStore,
                    gameHistoryStore: historyStore,
                    onStart: {
                        let session = setupViewModel.buildSession()
                        gameViewModel = GameProgressViewModel(
                            session: session,
                            topicHistory: topicHistoryStore,
                            topicFeedback: topicFeedbackStore,
                            topicSeed: featureFlags.effectiveTopicSeed
                        )
                        screen = .game
                    },
                    onShowHistory: {
                        screen = .history
                    }
                )

            case .game:
                if let vm = gameViewModel {
                    GameProgressView(
                        viewModel: vm,
                        isGameActive: Binding(
                            get: { screen == .game },
                            set: { if !$0 {
                                let snap = vm.snapshot()
                                endSnapshot = snap
                                historyStore.save(snap)
                                screen = .gameClear
                            }}
                        ),
                        onQuit: {
                            gameViewModel = nil
                            screen = .settings
                        }
                    )
                }

            case .gameClear:
                if let snap = endSnapshot {
                    GameClearView(snapshot: snap) {
                        screen = .end
                    }
                }

            case .end:
                if let snap = endSnapshot {
                    EndView(snapshot: snap) {
                        setupViewModel.resetForReplay()
                        gameViewModel = nil
                        endSnapshot = nil
                        screen = .settings
                    }
                }

            case .history:
                HistoryListView(store: historyStore) {
                    screen = .settings
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
