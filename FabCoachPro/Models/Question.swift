import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: Int
    let area: Area
    let topic: String?
    let question: String
    
    // bisherige Felder
    let answer: String
    let answerLegacy: String?
    let shortAnswer: String?      // ✅ wieder drin (optional)
    let explanation: String?
    
    // MC (optional)
    let options: [String]?
    let correctIndex: Int?
    
    var isOpenQuestion: Bool {
            answer.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveContains("OFFEN")
        }
    
}

extension Question {
    var displayAnswer: String {
        let s = (shortAnswer ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.isEmpty { return s }

        let a = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        return a.isEmpty ? "Keine Antwort verfügbar" : a
    }

    var isMultipleChoice: Bool {
        guard let opts = options, let idx = correctIndex else { return false }
        return opts.count == 4 && (0..<opts.count).contains(idx)
    }
}
