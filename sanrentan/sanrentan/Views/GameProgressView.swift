import SwiftUI

struct GameProgressView: View {
    @State var viewModel: GameProgressViewModel
    @Binding var isGameActive: Bool
    var onQuit: () -> Void

    @State private var showQuitConfirm = false

    var body: some View {
        Group {
            switch viewModel.phase {
            case .showTopic:
                TopicView(viewModel: viewModel)
            case .rankingInput(_, let isCovered):
                if isCovered {
                    CoverView(viewModel: viewModel)
                } else {
                    RankingInputView(viewModel: viewModel)
                }
            case .showResult:
                TurnResultView(viewModel: viewModel, isGameActive: $isGameActive)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showQuitConfirm = true
                } label: {
                    Image(systemName: "xmark")
                        .fontWeight(.semibold)
                }
            }
        }
        .alert("ゲームを中断しますか?", isPresented: $showQuitConfirm) {
            Button("続ける", role: .cancel) {}
            Button("中断する", role: .destructive) {
                onQuit()
            }
        } message: {
            Text("現在の進行状況は失われます")
        }
    }
}
