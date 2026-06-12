import SwiftUI

@main
struct ShelfApp: App {
    @StateObject private var store = ItemStore()

    var body: some Scene {
        WindowGroup {
            ItemListView()
                .environmentObject(store)
        }
    }
}
