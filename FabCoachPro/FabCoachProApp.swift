import SwiftUI

@main
struct FabCoachProApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .onAppear {
                    store.load()
                }
        }
    }
    

}
