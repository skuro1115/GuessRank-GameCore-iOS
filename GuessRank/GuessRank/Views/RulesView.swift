import SwiftUI

struct RulesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Goal
                section(icon: "target", title: "ゲームの目的", color: .orange) {
                    Text("出題者の「好みの順位」を当てるゲームです。\n友達の価値観をどれだけ理解しているかを競います。")
                }

                // MARK: - Turn flow
                section(icon: "arrow.trianglehead.2.counterclockwise", title: "1ターンの流れ", color: .cyan) {
                    VStack(alignment: .leading, spacing: 12) {
                        flowStep(number: 1, text: "お題が表示される（全員で確認）")
                        flowStep(number: 2, text: "出題者が自分の好みの順位を決める")
                        flowStep(number: 3, text: "回答者が出題者の順位を予想する")
                        flowStep(number: 4, text: "結果発表！")
                    }
                }

                // MARK: - Roles
                section(icon: "person.2.fill", title: "役割", color: .green) {
                    VStack(alignment: .leading, spacing: 8) {
                        roleRow(icon: "crown.fill", role: "出題者", desc: "お題に対して自分の好みの1位〜3位を決めます", color: .orange)
                        roleRow(icon: "person.fill.questionmark", role: "回答者", desc: "出題者がどの順番で好きかを予想します", color: .cyan)
                    }
                }

                // MARK: - Scoring
                section(icon: "star.fill", title: "得点", color: .yellow) {
                    VStack(spacing: 8) {
                        scoreRow(label: "完全一致（三連単）", points: "100点", highlight: true)
                        scoreRow(label: "2つ一致", points: "50点", highlight: false)
                        scoreRow(label: "1つ一致", points: "20点", highlight: false)
                        scoreRow(label: "不一致", points: "0点", highlight: false)
                    }
                }

                // MARK: - Winner
                section(icon: "trophy.fill", title: "勝敗", color: .orange) {
                    Text("全ターン終了後、合計スコアが最も高いプレイヤーが優勝です。")
                }

                // MARK: - Device passing
                section(icon: "iphone.gen2", title: "端末の回し方", color: .purple) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("スマホ1台をみんなで回して遊びます。")
                        Text("• 「○○さんの番です」と表示されたら端末を渡す")
                        Text("• タップするまで回答画面は見えません")
                        Text("• 入力が終わると自動で次の人の画面に切り替わります")
                    }
                }

                // MARK: - Pass feature
                section(icon: "arrow.uturn.right", title: "お題のパス", color: .red) {
                    Text("遊びにくいお題は「パス」で別のお題に変更できます。\nお題画面の右下にパスボタンがあります。")
                }
            }
            .padding()
        }
        .navigationTitle("遊び方")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Components

    private func section(icon: String, title: String, color: Color, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)
            content()
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func flowStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.cyan)
                .clipShape(Circle())
            Text(text)
                .font(.subheadline)
        }
    }

    private func roleRow(icon: String, role: String, desc: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(role).font(.subheadline).fontWeight(.semibold)
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func scoreRow(label: String, points: String, highlight: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(points)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(highlight ? .orange : .primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
