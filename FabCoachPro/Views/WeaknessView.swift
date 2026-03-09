import SwiftUI

struct WeaknessView: View {
    
    @EnvironmentObject var store: AppStore
    
    @State private var currentIndex: Int = 0
    @State private var showAnswer: Bool = false
    
    private var weakQuestions: [Question] {
        store.questions.filter { store.weakIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            if weakQuestions.isEmpty {
                
                ContentUnavailableView(
                    "Keine Schwächen",
                    systemImage: "checkmark.circle",
                    description: Text("Du hast aktuell keine markierten Fragen.")
                )
                
            } else {
                
                weaknessContent(for: weakQuestions[currentIndex])
                    .navigationTitle("Schwächen")
                    .navigationBarTitleDisplayMode(.large)
                    .background(Color(.systemGroupedBackground))
            }
        }
    }
    
    private func weaknessContent(for question: Question) -> some View {
        
        VStack(spacing: 16) {
            
            Text("Frage \(currentIndex + 1) von \(weakQuestions.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ScrollView {
                
                VStack(spacing: 16) {
                    
                    Text(question.area.title)
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Frage")
                            .font(.headline)
                        
                        Text(question.question)
                            .font(.title3.weight(.semibold))
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    if showAnswer {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("Antwort")
                                .font(.headline)
                                .foregroundStyle(.green)
                            
                            Text(question.displayAnswer)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding()
            }
            
            if !showAnswer {
                
                Button {
                    showAnswer = true
                } label: {
                    Text("Antwort anzeigen")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal)
                
            } else {
                
                HStack {
                    
                    Button {
                        store.weakIDs.remove(question.id)
                        nextQuestion()
                    } label: {
                        Label("Gewusst", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    
                    Button {
                        nextQuestion()
                    } label: {
                        Label("Weiter üben", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func nextQuestion() {
        
        showAnswer = false
        
        if currentIndex < weakQuestions.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
}
