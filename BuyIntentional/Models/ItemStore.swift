import Foundation
import Combine
import SwiftUI

final class ItemStore: ObservableObject {
    @Published var items: [PurchaseItem] = []
    @Published var defaultQuestions: [ReflectionQuestion] = []

    private let itemsKey    = "shelf.items"
    private let defaultsKey = "shelf.defaultQuestions"

    // MARK: - Computed views

    var activeItems: [PurchaseItem] {
        items.filter { $0.status != .rejected }
    }

    var rejectedItems: [PurchaseItem] {
        items.filter { $0.status == .rejected }
    }

    var wishlistTotal: Double {
        activeItems.compactMap { $0.price }.reduce(0, +)
    }

    var savedTotal: Double {
        rejectedItems.compactMap { $0.price }.reduce(0, +)
    }

    init() { load() }

    // MARK: - Item CRUD

    func add(name: String) {
        let questions = defaultQuestions.map { ReflectionQuestion(question: $0.question) }
        let item = PurchaseItem(name: name, questions: questions)
        items.append(item)
        saveItems()
    }

    func update(_ item: PurchaseItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        saveItems()
    }

    /// Marks an item as rejected (soft delete from home list).
    func reject(_ item: PurchaseItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].status = .rejected
        saveItems()
    }

    /// Marks items at given offsets in activeItems as rejected.
    func rejectActive(at offsets: IndexSet) {
        let targets = offsets.map { activeItems[$0].id }
        for id in targets {
            if let idx = items.firstIndex(where: { $0.id == id }) {
                items[idx].status = .rejected
            }
        }
        saveItems()
    }

    /// Permanently deletes a specific item.
    func permanentlyDelete(_ item: PurchaseItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    /// Permanently deletes items at given offsets in rejectedItems.
    func permanentlyDeleteRejected(at offsets: IndexSet) {
        let targets = offsets.map { rejectedItems[$0].id }
        items.removeAll { targets.contains($0.id) }
        saveItems()
    }

    /// Permanently deletes all rejected items.
    func clearAllRejected() {
        items.removeAll { $0.status == .rejected }
        saveItems()
    }

    // MARK: - Default Questions CRUD

    func addDefaultQuestion(_ text: String) {
        defaultQuestions.append(ReflectionQuestion(question: text))
        saveDefaults()
    }

    func updateDefaultQuestion(_ question: ReflectionQuestion) {
        guard let idx = defaultQuestions.firstIndex(where: { $0.id == question.id }) else { return }
        defaultQuestions[idx] = question
        saveDefaults()
    }

    func deleteDefaultQuestion(at offsets: IndexSet) {
        defaultQuestions.remove(atOffsets: offsets)
        saveDefaults()
    }

    func moveDefaultQuestion(from source: IndexSet, to destination: Int) {
        defaultQuestions.move(fromOffsets: source, toOffset: destination)
        saveDefaults()
    }

    func resetDefaultQuestions() {
        defaultQuestions = ReflectionQuestion.defaults
        saveDefaults()
    }

    // MARK: - Persistence

    private func saveItems() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: itemsKey)
    }

    private func saveDefaults() {
        guard let data = try? JSONEncoder().encode(defaultQuestions) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([PurchaseItem].self, from: data) {
            items = decoded
        }
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([ReflectionQuestion].self, from: data) {
            defaultQuestions = decoded
        } else {
            defaultQuestions = ReflectionQuestion.defaults
        }
    }
}
