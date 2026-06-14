import SwiftUI

@main
struct BuyIntentionalApp: App {
    @StateObject private var store = ItemStore()

    var body: some Scene {
        WindowGroup {
            ItemListView()
                .environmentObject(store)
        }
    }
}
