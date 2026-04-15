import SwiftUI

enum AppScreen {
    case settings
    case game
    case end
}

struct ContentView: View {
    @State private var screen: AppScreen = .settings
    @State private var setupViewModel = GameSetupViewModel()
    @State private var gameViewModel: GameProgressViewModel?

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
                            set: { if !$0 { screen = .end } }
                        ),
                        onQuit: {
                            gameViewModel = nil
                            screen = .settings
                        }
                    )
                }

            case .end:
                if let vm = gameViewModel {
                    EndView(viewModel: vm) {
                        setupViewModel.resetForReplay()
                        gameViewModel = nil
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
