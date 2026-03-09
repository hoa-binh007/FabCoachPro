import SwiftUI

struct ExamView: View {
    @EnvironmentObject var store: AppStore

    @State private var examQuestions: [Question] = []
    @State private var currentIndex: Int = 0
    @State private var showAnswer: Bool = false
    @State private var examStarted: Bool = false

    private let questionsPerArea = 10

    private var currentQuestion: Question? {
        guard examStarted,
              !examQuestions.isEmpty,
              currentIndex < examQuestions.count else { return nil }
        return examQuestions[currentIndex]
    }

    var body: some View {
        NavigationStack {
            Group {
                if !examStarted {
                    startView
                } else if examQuestions.isEmpty {
                    ContentUnavailableView(
                        "Keine Prüfungsfragen verfügbar",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Bitte prüfe, ob Fragen geladen wurden.")
                    )
                } else if currentIndex >= examQuestions.count {
                    finishedView
                } else if let question = currentQuestion {
                    examContent(for: question)
                }
            }
            .navigationTitle("Prüfung")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Start
    private var startView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checklist")
                .font(.system(size: 54))
                .foregroundStyle(.blue)

            Text("Prüfungsmodus")
                .font(.largeTitle.bold())

            Text("Es werden \(questionsPerArea) Fragen pro Fach gemischt. Offene Fragen werden automatisch ausgeschlossen.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            Button {
                startExam()
            } label: {
                Text("Prüfung starten")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.bottom, 24)
    }

    // MARK: - Ende
    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Prüfung beendet")
                .font(.largeTitle.bold())

            Text("Du hast \(examQuestions.count) Fragen bearbeitet.")
                .foregroundStyle(.secondary)

            Button {
                startExam()
            } label: {
                Text("Neu starten")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.bottom, 24)
    }

    // MARK: - Inhalt
    private func examContent(for question: Question) -> some View {
        let progress = Double(currentIndex + 1) / Double(max(examQuestions.count, 1))

        return VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Frage \(currentIndex + 1) von \(examQuestions.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(Int(progress * 100)) %")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: progress)
                    .tint(badgeColor(for: question.area))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            areaBadge(for: question.area)

                            Spacer()

                            if store.weakIDs.contains(question.id) {
                                Label("Schwäche", systemImage: "exclamationmark.circle.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.orange)
                            }
                        }

                        if let topic = question.topic,
                           !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(topic)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    FlipCardView(
                        isFlipped: showAnswer,
                        front: {
                            VStack(alignment: .leading, spacing: 14) {
                                Label("Frage", systemImage: "questionmark.circle")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(question.question)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: 0)

                                HStack {
                                    Spacer()
                                    Text("Tippe auf „Antwort anzeigen“")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 260, alignment: .topLeading)
                            .padding(18)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        },
                        back: {
                            VStack(alignment: .leading, spacing: 14) {
                                Label("Antwort", systemImage: "checkmark.circle")
                                    .font(.headline)
                                    .foregroundStyle(.green)

                                Text(question.displayAnswer)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)

                                if let explanation = question.explanation,
                                   !explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Divider().padding(.vertical, 2)

                                    Text("Erklärung")
                                        .font(.headline)

                                    Text(explanation)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 260, alignment: .topLeading)
                            .padding(18)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                    )
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.35), value: showAnswer)
                }
                .padding(.bottom, 8)
            }

            if !showAnswer {
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showAnswer = true
                    }
                } label: {
                    Text("Antwort anzeigen")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(badgeColor(for: question.area))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            } else {
                HStack(spacing: 12) {
                    Button {
                        markAsWeak(question)
                        nextQuestion()
                    } label: {
                        Label("Nicht gewusst", systemImage: "exclamationmark.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    Button {
                        markAsKnown(question)
                        nextQuestion()
                    } label: {
                        Label(
                            currentIndex == examQuestions.count - 1 ? "Beenden" : "Gewusst",
                            systemImage: "checkmark.circle"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Badge
    @ViewBuilder
    private func areaBadge(for area: Area) -> some View {
        Text(area.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(badgeColor(for: area).opacity(0.15))
            .foregroundStyle(badgeColor(for: area))
            .clipShape(Capsule())
    }

    private func badgeColor(for area: Area) -> Color {
        switch area {
        case .pruefungsfach1:
            return .blue
        case .pruefungsfach2:
            return .green
        case .pruefungsfach3:
            return .orange
        case .pruefungsfach4:
            return .purple
        }
    }

    // MARK: - Logik
    private func startExam() {
        let usableQuestions = store.questions.filter { !$0.isOpenQuestion }

        var mixed: [Question] = []

        for area in Area.allCases {
            let perArea = usableQuestions
                .filter { $0.area == area }
                .shuffled()
                .prefix(questionsPerArea)

            mixed.append(contentsOf: perArea)
        }

        examQuestions = mixed.shuffled()
        currentIndex = 0
        showAnswer = false
        examStarted = true
    }

    private func nextQuestion() {
        showAnswer = false
        currentIndex += 1
    }

    private func markAsWeak(_ question: Question) {
        store.weakIDs.insert(question.id)
    }

    private func markAsKnown(_ question: Question) {
        store.weakIDs.remove(question.id)
    }
}

// MARK: - Flip Card
private struct FlipCardView<Front: View, Back: View>: View {
    let isFlipped: Bool
    let front: Front
    let back: Back

    init(
        isFlipped: Bool,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self.isFlipped = isFlipped
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
    }
}
