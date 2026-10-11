import SwiftUI

struct GameSettingsView: View {
    @Bindable var viewModel: GameSetupViewModel
    var topicHistoryStore: TopicHistoryStore
    var topicFeedbackStore: TopicFeedbackStore
    var gameHistoryStore: GameHistoryStore
    var onStart: () -> Void
    var onShowHistory: () -> Void

    @Environment(\.featureFlags) private var featureFlags
    @FocusState private var focusedIndex: Int?
    @State private var showTopicSettings = false
    @State private var dataResetTarget: DataResetTarget?

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
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("プレイモード")
                        Text(viewModel.playMode.shortDescription)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Picker("プレイモード", selection: $viewModel.playMode) {
                        ForEach(PlayMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
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

            if featureFlags.isEnabled(.devModeEnabled) {
                developerSection
            }

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
                Button {
                    showTopicSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { onShowHistory() } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .sheet(isPresented: $showTopicSettings) {
            TopicSettingsView(
                topicHistoryStore: topicHistoryStore,
                topicFeedbackStore: topicFeedbackStore
            ) {
                showTopicSettings = false
            }
        }
        .onTapGesture { focusedIndex = nil }
    }

    @ViewBuilder
    private var developerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("開発者", systemImage: "hammer.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.purple)

            if featureFlags.isEnabled(.quickStartEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("クイックスタート")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        ForEach(QuickStartPreset.allPresets) { preset in
                            Button {
                                viewModel.applyQuickStartPreset(preset)
                                onStart()
                            } label: {
                                Text(preset.displayName)
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .tint(.purple)
                        }
                    }
                }
            }

            if featureFlags.isEnabled(.dataResetEnabled) {
                HStack(spacing: 6) {
                    Text("データ")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Menu {
                        Button("お題履歴") { dataResetTarget = .topicHistory }
                        Button("お題FB（ブロック+面白い）") { dataResetTarget = .topicFeedback }
                        Button("ゲーム履歴") { dataResetTarget = .gameHistory }
                        Divider()
                        Button("全データ", role: .destructive) { dataResetTarget = .all }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("リセット…")
                        }
                        .font(.caption)
                    }
                    .menuStyle(.borderlessButton)
                    .tint(.purple)
                }
            }

            devToggle(.fastModeEnabled, label: "高速モード（4x）")
            devToggle(.debugOverlayEnabled, label: "デバッグオーバーレイ")
            devToggle(.seedFixEnabled, label: "シード固定")

            if featureFlags.isEnabled(.seedFixEnabled) {
                HStack(spacing: 6) {
                    Text("シード")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    TextField("シード値", value: seedBinding, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .font(.caption)
                        .frame(maxWidth: 120)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.purple.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .alert(
            "リセット確認",
            isPresented: dataResetAlertBinding,
            presenting: dataResetTarget
        ) { target in
            Button("リセット", role: .destructive) { performReset(target) }
            Button("キャンセル", role: .cancel) {}
        } message: { target in
            Text(target.confirmationMessage)
        }
    }

    private func flagBinding(_ flag: FeatureFlag) -> Binding<Bool> {
        Binding(
            get: { featureFlags.isEnabled(flag) },
            set: { featureFlags.setEnabled(flag, $0) }
        )
    }

    private var seedBinding: Binding<Int> {
        Binding(
            get: { featureFlags.topicSeed },
            set: { featureFlags.topicSeed = $0 }
        )
    }

    @ViewBuilder
    private func devToggle(_ flag: FeatureFlag, label: String) -> some View {
        Toggle(isOn: flagBinding(flag)) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .toggleStyle(.switch)
        .tint(.purple)
        .controlSize(.mini)
    }

    private var dataResetAlertBinding: Binding<Bool> {
        Binding(
            get: { dataResetTarget != nil },
            set: { if !$0 { dataResetTarget = nil } }
        )
    }

    private func performReset(_ target: DataResetTarget) {
        switch target {
        case .topicHistory:
            topicHistoryStore.clear()
        case .topicFeedback:
            topicFeedbackStore.clearAll()
        case .gameHistory:
            gameHistoryStore.clearAll()
        case .all:
            topicHistoryStore.clear()
            topicFeedbackStore.clearAll()
            gameHistoryStore.clearAll()
        }
        dataResetTarget = nil
    }

    private func playerNameBinding(at index: Int) -> Binding<String> {
        Binding(
            get: { index < viewModel.playerNames.count ? viewModel.playerNames[index] : "" },
            set: { if index < viewModel.playerNames.count { viewModel.playerNames[index] = $0 } }
        )
    }
}

/// 開発者モードのデータリセット対象。
private enum DataResetTarget: String, Identifiable {
    case topicHistory
    case topicFeedback
    case gameHistory
    case all

    var id: String { rawValue }

    var confirmationMessage: String {
        switch self {
        case .topicHistory:
            "プレイ済みお題の履歴を全件削除します。元に戻せません。"
        case .topicFeedback:
            "ブロック設定と「面白い」評価を全件削除します。元に戻せません。"
        case .gameHistory:
            "ゲーム履歴を全件削除します。元に戻せません。"
        case .all:
            "全ての永続データ（お題履歴・FB・ゲーム履歴）を削除します。元に戻せません。"
        }
    }
}
