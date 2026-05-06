import SwiftUI

/// お題に関する設定: プレイ済みお題のリセットやブロック管理（次フェーズで拡張）。
struct TopicSettingsView: View {
    let topicHistoryStore: TopicHistoryStore
    var onDismiss: () -> Void

    @State private var playedCount: Int = 0
    @State private var showResetConfirmation = false
    @State private var resetFeedback: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("プレイ済みお題", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(playedCount)件")
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
        }
    }

    private func refresh() {
        playedCount = topicHistoryStore.count
    }
}
