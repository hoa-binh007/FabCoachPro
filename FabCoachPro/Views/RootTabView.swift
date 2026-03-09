import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        TabView {
            LearnView()
                .tabItem { Label("Lernen", systemImage: "book") }

            ExamView()
                .tabItem { Label("Prüfung", systemImage: "checklist") }

            WeaknessView()
                .tabItem { Label("Schwächen", systemImage: "chart.bar") }

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person") }
        }
    }
}
