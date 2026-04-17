import SwiftUI

enum AppScreen {
    case settings
    case game
    case gameClear
    case end
}

struct ContentView: View {
    @State private var screen: AppScreen = .settings
    @State private var setupViewModel = GameSetupViewModel()
    @State private var gameViewModel: GameProgressViewModel?
    @State private var endSnapshot: GameSessionSnapshot?

    var body: some View {
        NavigationStack {
            switch screen {
            case .settings:
                GameSettingsView(viewModel: setupViewModel) {
                    let session = setupViewModel.buildSession()
                    gameViewModel = GameProgressViewModel(session: session)
                    screen = .game
                }

            case .game:
                if let vm = gameViewModel {
                    GameProgressView(
                        viewModel: vm,
                        isGameActive: Binding(
                            get: { screen == .game },
                            set: { if !$0 {
                                endSnapshot = vm.snapshot()
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
            }
        }
    }
}

#Preview {
    ContentView()
}
