import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore

    private var totalQuestions: Int {
        store.questions.count
    }

    private var openQuestions: Int {
        store.questions.filter(\.isOpenQuestion).count
    }

    private var answeredQuestions: Int {
        totalQuestions - openQuestions
    }

    private var weakQuestionsCount: Int {
        store.questions.filter { store.weakIDs.contains($0.id) }.count
    }

    private var knownQuestionsCount: Int {
        max(answeredQuestions - weakQuestionsCount, 0)
    }

    private var learningProgress: Double {
        guard answeredQuestions > 0 else { return 0 }
        return Double(knownQuestionsCount) / Double(answeredQuestions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    progressCard
                    areaStatsCard
                    weakInfoCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Lernstatistik")
                .font(.title2.bold())

            HStack(spacing: 12) {
                statBox(
                    title: "Gesamt",
                    value: "\(totalQuestions)",
                    color: .blue
                )

                statBox(
                    title: "Beantwortbar",
                    value: "\(answeredQuestions)",
                    color: .green
                )
            }

            HStack(spacing: 12) {
                statBox(
                    title: "Schwächen",
                    value: "\(weakQuestionsCount)",
                    color: .orange
                )

                statBox(
                    title: "Offen",
                    value: "\(openQuestions)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Fortschritt")
                .font(.title3.bold())

            HStack {
                Text("Sicher gewusst")
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(learningProgress * 100)) %")
                    .fontWeight(.semibold)
            }

            ProgressView(value: learningProgress)
                .tint(.green)

            Text("Berechnung: beantwortbare Fragen minus aktuelle Schwächen.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var areaStatsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Fächer")
                .font(.title3.bold())

            ForEach(Area.allCases) { area in
                let all = questions(in: area).count
                let open = questions(in: area).filter(\.isOpenQuestion).count
                let weak = questions(in: area).filter { store.weakIDs.contains($0.id) }.count

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(area.title)
                            .font(.headline)

                        Text("\(all) Fragen • \(weak) Schwächen • \(open) offen")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Circle()
                        .fill(color(for: area))
                        .frame(width: 12, height: 12)
                }

                if area != Area.allCases.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var weakInfoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hinweis")
                .font(.title3.bold())

            Text("Fragen, die du im Prüfungsmodus mit „Nicht gewusst“ markierst, erscheinen automatisch im Bereich „Schwächen“.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func questions(in area: Area) -> [Question] {
        store.questions.filter { $0.area == area }
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

    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
