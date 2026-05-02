import SwiftUI

struct HistoryListView: View {
    let store: GameHistoryStore
    var onDismiss: () -> Void

    var body: some View {
        Group {
            if store.entries.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("まだゲーム履歴がありません")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(store.entries) { entry in
                        NavigationLink {
                            HistoryDetailView(entry: entry)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("🏆 \(entry.winnerName)")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(entry.winnerScore)点")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.orange)
                                }

                                HStack {
                                    Text(entry.playerNames.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(entry.playedAt, style: .date)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("ゲーム履歴")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("閉じる") { onDismiss() }
            }
        }
    }
}
