import SwiftUI

struct GameSettingsView: View {
    @Bindable var viewModel: GameSetupViewModel
    var onStart: () -> Void
    var onShowHistory: () -> Void

    @FocusState private var focusedIndex: Int?

    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Game config
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("プレイヤー数")
                    Spacer()
                    Picker("人数", selection: Binding(
                        get: { viewModel.playerCount },
                        set: { viewModel.updatePlayerCount($0) }
                    )) {
                        ForEach(2...6, id: \.self) { n in
                            Text("\(n)人").tag(n)
                        }
                    }
                    .pickerStyle(.menu)
                }
                HStack {
                    Text("サイクル数")
                    Spacer()
                    Picker("サイクル", selection: $viewModel.cycleCount) {
                        ForEach(1...3, id: \.self) { n in Text("\(n)").tag(n) }
                    }
                    .pickerStyle(.menu)
                }
                HStack {
                    Text("ジャンル")
                    Spacer()
                    Picker("ジャンル", selection: $viewModel.genre) {
                        ForEach(Genre.allCases, id: \.self) { g in Text(g.displayName).tag(g) }
                    }
                    .pickerStyle(.menu)
                }
                HStack {
                    Text("難易度")
                    Spacer()
                    Picker("難易度", selection: $viewModel.difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { d in Text(d.displayName).tag(d) }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
            }
            .font(.subheadline)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 12) {
                Text("\(viewModel.totalTurns)ターン")
                Text(viewModel.estimatedTimeText)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // MARK: - Player names
            VStack(alignment: .leading, spacing: 8) {
                Text("プレイヤー名")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ForEach(Array(viewModel.playerNames.enumerated()), id: \.offset) { index, _ in
                    HStack(spacing: 8) {
                        Text("\(index + 1).")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 24)
                        TextField("プレイヤー\(index + 1)", text: playerNameBinding(at: index))
                            .textFieldStyle(.roundedBorder)
                            .font(.subheadline)
                            .focused($focusedIndex, equals: index)
                            .submitLabel(index < viewModel.playerNames.count - 1 ? .next : .done)
                            .onChange(of: viewModel.playerNames) {
                                if index < viewModel.playerNames.count,
                                   viewModel.playerNames[index].count > GameSetupViewModel.maxNameLength {
                                    viewModel.playerNames[index] = String(viewModel.playerNames[index].prefix(GameSetupViewModel.maxNameLength))
                                }
                            }
                            .onSubmit {
                                if index < viewModel.playerNames.count - 1 {
                                    focusedIndex = index + 1
                                } else {
                                    focusedIndex = nil
                                }
                            }
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if !viewModel.canStartGame {
                Text("全員の名前を入力してください（重複不可）")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()

            Button(action: onStart) {
                Text("ゲームを始める")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canStartGame ? Color.accentColor : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.canStartGame)
        }
        .padding()
        .navigationTitle("ゲーム設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink { RulesView() } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { onShowHistory() } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .onTapGesture { focusedIndex = nil }
    }

    private func playerNameBinding(at index: Int) -> Binding<String> {
        Binding(
            get: { index < viewModel.playerNames.count ? viewModel.playerNames[index] : "" },
            set: { if index < viewModel.playerNames.count { viewModel.playerNames[index] = $0 } }
        )
    }
}
