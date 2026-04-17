import Foundation

enum ScoreService {
    static func calculateScore(correct: [String], answer: [String]) -> Int {
        guard correct.count == answer.count else { return 0 }

        var matchCount = 0
        for i in correct.indices {
            if correct[i] == answer[i] {
                matchCount += 1
            }
        }

        switch matchCount {
        case 3: return 100
        case 2: return 50
        case 1: return 20
        default: return 0
        }
    }

    static func matchDescription(_ score: Int) -> String {
        switch score {
        case 100: "完全一致!"
        case 50: "2つ一致"
        case 20: "1つ一致"
        default: "不一致"
        }
    }
}
