import SwiftUI

// MARK: - Haupt-Lernansicht (Kategorien-Übersicht)
struct LearnView: View {
    @EnvironmentObject var store: AppStore

    private var totalQuestions: Int {
        store.questions.count
    }

    private var weakQuestions: Int {
        store.questions.filter { store.weakIDs.contains($0.id) }.count
    }

    private var openQuestions: Int {
        store.questions.filter(\.isOpenQuestion).count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deine Prüfungsvorbereitung")
                            .font(.title2.bold())

                        Text("Lerne nach Fach, wiederhole Schwächen und bereite dich gezielt auf die Prüfung vor.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(Color.clear)
                }

                Section("Übersicht") {
                    statRow(
                        title: "Fragen gesamt",
                        value: "\(totalQuestions)",
                        color: .blue,
                        systemImage: "books.vertical"
                    )

                    statRow(
                        title: "Schwächen",
                        value: "\(weakQuestions)",
                        color: .orange,
                        systemImage: "exclamationmark.circle"
                    )

                    statRow(
                        title: "Offene Fragen",
                        value: "\(openQuestions)",
                        color: .purple,
                        systemImage: "questionmark.circle"
                    )
                }

                Section("Kategorien") {
                    ForEach(Area.allCases, id: \.self) { area in
                        let count = store.groupedByArea[area]?.count ?? 0

                        NavigationLink {
                            AreaQuestionListView(area: area)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: icon(for: area))
                                    .foregroundStyle(color(for: area))
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(area.title)
                                        .font(.headline)

                                    Text(subtitle(for: area))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline.weight(.medium))
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Lernen")
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.insetGrouped)
        }
    }

    private func subtitle(for area: Area) -> String {
        switch area {
        case .pruefungsfach1:
            return "Retten, Erstversorgung & Schwimmen"
        case .pruefungsfach2:
            return "Badebetrieb"
        case .pruefungsfach3:
            return "Bädertechnik"
        case .pruefungsfach4:
            return "Wirtschafts- & Sozialkunde"
        }
    }

    private func color(for area: Area) -> Color {
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

    private func icon(for area: Area) -> String {
        switch area {
        case .pruefungsfach1:
            return "cross.case"
        case .pruefungsfach2:
            return "figure.pool.swim"
        case .pruefungsfach3:
            return "gearshape.2"
        case .pruefungsfach4:
            return "building.columns"
        }
    }

    @ViewBuilder
    private func statRow(title: String, value: String, color: Color, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Fragenliste pro Bereich
struct AreaQuestionListView: View {
    @EnvironmentObject var store: AppStore
    let area: Area

    private var items: [Question] {
        store.groupedByArea[area] ?? []
    }

    var body: some View {
        List(items) { q in
            NavigationLink {
                let deck = store.questions
                let startIndex = deck.firstIndex(of: q) ?? 0
                QuestionDetailView(questions: deck, index: startIndex)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Frage \(q.id)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let topic = q.topic,
                           !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(topic)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        if q.isOpenQuestion {
                            Text("OFFEN")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        } else if store.weakIDs.contains(q.id) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }

                    Text(q.question)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(area.title)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }
}

// MARK: - Detailansicht (Lernkarte mit Kurzantwort + Erklärung)
