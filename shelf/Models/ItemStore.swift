import Foundation
import Combine
import SwiftUI

final class ItemStore: ObservableObject {
    @Published var items: [PurchaseItem] = []
    @Published var defaultQuestions: [ReflectionQuestion] = []

    private let itemsKey     = "shelf.items"
    private let defaultsKey  = "shelf.defaultQuestions"

    init() {
        load()
    }

    // MARK: - Item CRUD

    func add(name: String) {
        // New items get a fresh copy of the current default questions (no answers)
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

    func delete(_ item: PurchaseItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
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
