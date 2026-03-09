import SwiftUI

struct QuestionDetailView: View {
    let questions: [Question]
    let index: Int

    @State private var showExplanation = false
    @State private var currentIndex: Int

    // MC-State
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false

    init(questions: [Question], index: Int) {
        self.questions = questions
        self.index = index
        _currentIndex = State(initialValue: index)
    }

    private var question: Question { questions[currentIndex] }

    // robust: MC nur, wenn 4 Optionen + correctIndex gültig
    private var isMC: Bool {
        guard let opts = question.options,
              let correct = question.correctIndex else { return false }
        return opts.count == 4 && (0..<opts.count).contains(correct)
    }

    private func resetLocalStateForNewQuestion() {
        showExplanation = false
        selectedIndex = nil
        showResult = false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                HStack {
                    Text(question.area.rawValue)
                        .font(.caption).bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    if let topic = question.topic,
                       !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(topic)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text("ID \(question.id)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Frage
                Text(question.question)
                    .font(.title2)
                    .fontWeight(.semibold)

                Divider()

                // Antwort-Block (Text oder MC)
                VStack(alignment: .leading, spacing: 10) {

                    Label(
                        isMC ? "Prüfungsfrage (Multiple Choice)" : "Prüfungsantwort",
                        systemImage: isMC ? "list.bullet.circle.fill" : "checkmark.circle.fill"
                    )
                    .font(.caption).bold()
                    .foregroundStyle(isMC ? .blue : .green)

                    if isMC {
                        Text("Wähle die richtige Antwort:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let options = question.options,
                           let correct = question.correctIndex {

                            VStack(spacing: 10) {
                                ForEach(options.indices, id: \.self) { i in
                                    Button {
                                        selectedIndex = i
                                        showResult = true
                                    } label: {
                                        HStack(spacing: 12) {
                                            Text(options[i])
                                                .multilineTextAlignment(.leading)
                                                .foregroundStyle(.primary)

                                            Spacer()

                                            if showResult {
                                                if i == correct {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundStyle(.green)
                                                } else if i == selectedIndex {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundStyle(.red)
                                                }
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            showResult
                                            ? (i == correct
                                               ? Color.green.opacity(0.18)
                                               : (i == selectedIndex ? Color.red.opacity(0.18) : Color(.systemGray6)))
                                            : Color(.systemGray6)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(showResult)
                                }

                                if showResult {
                                    let isCorrect = (selectedIndex == correct)
                                    Text(isCorrect ? "✅ Richtig" : "❌ Falsch")
                                        .font(.caption)
                                        .foregroundStyle(isCorrect ? .green : .red)

                                    Text("Lösung: \(options[correct])")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                    } else {
                        Text(question.displayAnswer)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isMC ? Color.blue.opacity(0.08) : Color.green.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Erklärung (optional)
                if let explanation = question.explanation,
                   !explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                    DisclosureGroup("Erklärung anzeigen", isExpanded: $showExplanation) {
                        Text(explanation)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Navigation innerhalb der Detailansicht
                HStack(spacing: 12) {
                    Button {
                        currentIndex = max(0, currentIndex - 1)
                        resetLocalStateForNewQuestion()
                    } label: {
                        Label("Zurück", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentIndex == 0)

                    Button {
                        currentIndex = min(questions.count - 1, currentIndex + 1)
                        resetLocalStateForNewQuestion()
                    } label: {
                        Label("Nächste", systemImage: "chevron.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentIndex >= questions.count - 1)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Lernkarte")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: currentIndex) { _, _ in
            resetLocalStateForNewQuestion()
        }
    }
    
    private var answerBlock: some View {
        VStack(alignment: .leading, spacing: 10) {

            Label(
                isMC ? "Prüfungsfrage (Multiple Choice)" : "Prüfungsantwort",
                systemImage: isMC ? "list.bullet.circle.fill" : "checkmark.circle.fill"
            )
            .font(.caption).bold()
            .foregroundStyle(isMC ? .blue : .green)

            if isMC {
                Text("Wähle die richtige Antwort:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let options = question.options,
                   let correct = question.correctIndex {

                    VStack(spacing: 10) {
                        ForEach(options.indices, id: \.self) { i in
                            Button {
                                selectedIndex = i
                                showResult = true
                            } label: {
                                HStack(spacing: 12) {
                                    Text(options[i])
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    if showResult {
                                        if i == correct {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                        } else if i == selectedIndex {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    showResult
                                    ? (i == correct
                                       ? Color.green.opacity(0.18)
                                       : (i == selectedIndex ? Color.red.opacity(0.18) : Color(.systemGray6)))
                                    : Color(.systemGray6)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .disabled(showResult)
                        }

                        if showResult {
                            let isCorrect = (selectedIndex == correct)
                            Text(isCorrect ? "✅ Richtig" : "❌ Falsch")
                                .font(.caption)
                                .foregroundStyle(isCorrect ? .green : .red)

                            Text("Lösung: \(options[correct])")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Text(question.displayAnswer)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isMC ? Color.blue.opacity(0.08) : Color.green.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var navBar: some View {
        HStack(spacing: 12) {
            Button {
                currentIndex = max(0, currentIndex - 1)
                resetLocalStateForNewQuestion()
            } label: {
                Label("Zurück", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(currentIndex == 0)

            Button {
                currentIndex = min(questions.count - 1, currentIndex + 1)
                resetLocalStateForNewQuestion()
            } label: {
                Label("Nächste", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(currentIndex >= questions.count - 1)
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
    }
}
