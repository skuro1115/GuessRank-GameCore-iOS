import SwiftUI

/// お題に関する設定: プレイ済みお題のリセットとブロック管理。
struct TopicSettingsView: View {
    let topicHistoryStore: TopicHistoryStore
    let topicFeedbackStore: TopicFeedbackStore
    var onDismiss: () -> Void

    @State private var playedCount: Int = 0
    @State private var blockedEntries: [TopicFeedback] = []
    @State private var likedEntries: [TopicFeedback] = []
    @State private var exportFileURL: URL?
    @State private var showResetConfirmation = false
    @State private var showClearBlocksConfirmation = false
    @State private var showClearLikesConfirmation = false
    @State private var resetFeedback: String?

    private var topicLookup: [String: Topic] {
        Dictionary(uniqueKeysWithValues: TopicService.allTopics.map { ($0.id, $0) })
    }

    private var totalCount: Int { TopicService.totalTopicCount }
    private var remainingCount: Int { max(0, totalCount - playedCount) }
    private var isExhausted: Bool { totalCount > 0 && playedCount >= totalCount }
    private var isNearExhaustion: Bool {
        totalCount > 0 && !isExhausted && remainingCount <= max(5, totalCount / 20)
    }

    var body: some View {
        NavigationStack {
            List {
                if isExhausted {
                    Section {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("全てのお題をプレイ済みです")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("履歴をリセットすると同じお題が再び選ばれます。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.orange.opacity(0.1))
                } else if isNearExhaustion {
                    Section {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundStyle(.yellow)
                            Text("残り \(remainingCount) 件のお題で全てプレイ済みになります。")
                                .font(.caption)
                        }
                    }
                    .listRowBackground(Color.yellow.opacity(0.08))
                }

                Section {
                    HStack {
                        Label("プレイ済みお題", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(playedCount) / \(totalCount)件")
                            .foregroundStyle(.secondary)
                    }

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("履歴をリセット", systemImage: "arrow.counterclockwise")
                    }
                    .disabled(playedCount == 0)
                } header: {
                    Text("お題履歴")
                } footer: {
                    Text("プレイ済みのお題は次回ゲームで重複しないよう自動的に避けます。リセットすると全てのお題が再び選ばれる対象になります。")
                }

                Section {
                    if blockedEntries.isEmpty {
                        Text("ブロック中のお題はありません")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(blockedEntries) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(topicLookup[entry.topicId]?.question ?? entry.topicId)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                    if let reason = entry.blockReason {
                                        Text(reason.displayName)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Button("解除") {
                                    topicFeedbackStore.unblock(entry.topicId)
                                    refresh()
                                }
                                .font(.caption)
                                .buttonStyle(.bordered)
                            }
                        }

                        Button(role: .destructive) {
                            showClearBlocksConfirmation = true
                        } label: {
                            Label("全て解除", systemImage: "trash")
                        }
                    }
                } header: {
                    Text("ブロック中のお題（\(blockedEntries.count)件）")
                } footer: {
                    Text("ブロック中のお題は今後のゲームで選ばれません。お題画面の「⋯」メニューからブロックできます。")
                }

                Section {
                    if likedEntries.isEmpty {
                        Text("「面白い」として記録されたお題はありません")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(likedEntries) { entry in
                            HStack {
                                Text(topicLookup[entry.topicId]?.question ?? entry.topicId)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                Spacer()
                                Button("解除") {
                                    topicFeedbackStore.unlike(entry.topicId)
                                    refresh()
                                }
                                .font(.caption)
                                .buttonStyle(.bordered)
                            }
                        }

                        Button(role: .destructive) {
                            showClearLikesConfirmation = true
                        } label: {
                            Label("全て解除", systemImage: "trash")
                        }
                    }
                } header: {
                    Text("「面白い」お題（\(likedEntries.count)件）")
                } footer: {
                    Text("お題画面の「👍」ボタンで記録できます。今後のゲーム選定には影響しません。")
                }

                if let exportFileURL {
                    Section {
                        ShareLink(
                            item: exportFileURL,
                            preview: SharePreview("GuessRank フィードバック")
                        ) {
                            Label("FBデータをエクスポート", systemImage: "square.and.arrow.up")
                        }
                    } header: {
                        Text("データエクスポート")
                    } footer: {
                        Text("ブロック・「面白い」のFBをJSONファイルとして書き出します。送信は行いません。機種変更時の引き継ぎや、開発者へのフィードバック共有にご利用ください。")
                    }
                }

                if let feedback = resetFeedback {
                    Section {
                        Text(feedback)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("お題管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { onDismiss() }
                }
            }
            .onAppear { refresh() }
            .alert("履歴をリセットしますか？", isPresented: $showResetConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("リセット", role: .destructive) {
                    topicHistoryStore.clear()
                    resetFeedback = "履歴をリセットしました"
                    refresh()
                }
            } message: {
                Text("プレイ済みのお題リストが空になります。元に戻せません。")
            }
            .alert("ブロックを全て解除しますか？", isPresented: $showClearBlocksConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("解除", role: .destructive) {
                    topicFeedbackStore.clearBlocks()
                    resetFeedback = "ブロックを全て解除しました"
                    refresh()
                }
            } message: {
                Text("ブロック中のお題が全てゲームに復帰します。")
            }
            .alert("「面白い」記録を全て解除しますか？", isPresented: $showClearLikesConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("解除", role: .destructive) {
                    topicFeedbackStore.clearLikes()
                    resetFeedback = "「面白い」記録を全て解除しました"
                    refresh()
                }
            } message: {
                Text("「面白い」として記録した内容が全て削除されます。")
            }
        }
    }

    private func refresh() {
        playedCount = topicHistoryStore.count
        blockedEntries = topicFeedbackStore.blockedEntries.sorted { $0.recordedAt > $1.recordedAt }
        likedEntries = topicFeedbackStore.likedEntries.sorted { $0.recordedAt > $1.recordedAt }
        exportFileURL = makeExportFile()
    }

    /// FBエントリを一時ディレクトリに JSON ファイルとして書き出し、ShareLink 用の URL を返す。
    /// エントリが空、または書き込みに失敗した場合は nil。
    private func makeExportFile() -> URL? {
        guard !topicFeedbackStore.entries.isEmpty,
              let data = topicFeedbackStore.exportJSON() else {
            return nil
        }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateString = formatter.string(from: Date())
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("guessrank_feedback_\(dateString).json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
