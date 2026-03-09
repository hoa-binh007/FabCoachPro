import Foundation
import SwiftUI
import Combine



    
    @MainActor
    final class AppStore: ObservableObject {
        
        @Published var questions: [Question] = []
        @Published var weakIDs: Set<Int> = [] {
            didSet { saveWeakIDs() }
        }
        
        private let weakKey = "weak_question_ids"
        
        init() {
            loadWeakIDs()
            load()
        }
        
        func load() {
            print("✅ AppStore.load() gestartet")
            
            guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
                print("❌ questions.json nicht im App-Bundle gefunden")
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                
                let decoder = JSONDecoder()
                let loaded = try decoder.decode([Question].self, from: data)
                
                self.questions = loaded.sorted { $0.id < $1.id }
                print("✅ \(questions.count) Fragen geladen")
                
                validateQuestions(loaded)
            } catch {
                print("❌ Fehler beim Laden der questions.json: \(error)")
            }
        }
        
        var openQuestions: [Question] {
            questions.filter { $0.isOpenQuestion }
        }
        
        var openQuestionsByArea: [Area: [Question]] {
            Dictionary(grouping: openQuestions, by: \.area)
        }
        
        var openQuestionCount: Int {
            openQuestions.count
        }
        
        func loadWeakIDs() {
            let arr = UserDefaults.standard.array(forKey: weakKey) as? [Int] ?? []
            weakIDs = Set(arr)
        }
        
        func saveWeakIDs() {
            UserDefaults.standard.set(Array(weakIDs), forKey: weakKey)
        }
        
        func markWeak(_ id: Int) {
            weakIDs.insert(id)
        }
        
        func unmarkWeak(_ id: Int) {
            weakIDs.remove(id)
        }
        
        func isWeak(_ id: Int) -> Bool {
            weakIDs.contains(id)
        }
        
        var groupedByArea: [Area: [Question]] {
            Dictionary(grouping: questions, by: \.area)
        }
        
        private func validateQuestions(_ questions: [Question]) {
            var issues: [String] = []
            
            for q in questions {
                let questionText = q.question.trimmingCharacters(in: .whitespacesAndNewlines)
                let answerText = q.answer.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if questionText.isEmpty {
                    issues.append("ID \(q.id): Frage ist leer")
                }
                
                if answerText.isEmpty {
                    issues.append("ID \(q.id): Antwort ist komplett leer")
                }
                
                if let options = q.options, !options.isEmpty {
                    if q.correctIndex == nil {
                        issues.append("ID \(q.id): MC-Optionen vorhanden, aber correctIndex fehlt")
                    } else if !q.isMultipleChoice {
                        issues.append("ID \(q.id): MC-Daten sind unvollständig oder ungültig")
                    }
                }
            }
            
            if issues.isEmpty {
                print("✅ Daten-Check: Alles in Ordnung.")
            } else {
                print("⚠️ Daten-Check: \(issues.count) Probleme gefunden")
                for issue in issues {
                    print("  - \(issue)")
                }
            }
        }
    }

