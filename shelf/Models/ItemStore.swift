import Foundation
import Combine
import SwiftUI

final class ItemStore: ObservableObject {
    @Published var items: [PurchaseItem] = []

    private let key = "shelf.items"

    init() {
        load()
    }

    // MARK: - CRUD

    func add(name: String) {
        let item = PurchaseItem(name: name)
        items.append(item)
        save()
    }

    func update(_ item: PurchaseItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(_ item: PurchaseItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([PurchaseItem].self, from: data)
        else { return }
        items = decoded
    }
}
