import SwiftUI

struct RulesView: View {
    var body: some View {
        ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            section(icon: "target", title: "目的", color: .orange) {
                Text("ターゲットの好みの順位を当てるゲーム")
            }

            section(icon: "arrow.trianglehead.2.counterclockwise", title: "流れ", color: .cyan) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. お題を全員で確認")
                    Text("2. ターゲットが好みの順位を決める")
                    Text("3. 予想者がターゲットの順位を予想")
                    Text("4. 結果発表！")
                }
            }

            section(icon: "person.2.fill", title: "役割", color: .green) {
                HStack(spacing: 16) {
                    Label("ターゲット: 好みを決める", systemImage: "crown.fill")
                    Spacer()
                    Label("予想者: 好みを当てる", systemImage: "person.fill.questionmark")
                }
                .font(.caption)
            }

            section(icon: "star.fill", title: "得点", color: .yellow) {
                HStack {
                    Text("完全一致 100点")
                    Spacer()
                    Text("2つ一致 50点")
                    Spacer()
                    Text("1つ一致 20点")
                }
                .font(.caption)
            }

            section(icon: "iphone.gen2", title: "端末の回し方", color: .purple) {
                Text("「○○さんの番です」が出たら端末を渡す。タップするまで中身は見えません。")
            }

            section(icon: "arrow.uturn.right", title: "お題を変える", color: .red) {
                Text("答えにくいお題は「お題を変える」ボタンで何度でも変更できます。")
            }

        }
        .padding()
        }
        .navigationTitle("遊び方")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(icon: String, title: String, color: Color, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            content()
                .font(.caption)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
