import SwiftUI

// MARK: - SettingsView (top-level menu)

struct SettingsView: View {
    @EnvironmentObject var store: ItemStore

    private let feedbackFormURL = URL(string: "https://forms.gle/cHYVV3nQJs1AMZDy7")!

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: DefaultQuestionsView()) {
                        Label("Default questions", systemImage: "questionmark.bubble")
                            .labelStyle(.titleAndIcon)
                    }
                    NavigationLink(destination: RejectedItemsView()) {
                        HStack {
                            Label("Rejected items", systemImage: "xmark.circle")
                                .labelStyle(.titleAndIcon)
                            Spacer()
                            if !store.rejectedItems.isEmpty {
                                Text("\(store.rejectedItems.count)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section {
                    Link(destination: feedbackFormURL) {
                        HStack {
                            Label("Get in touch", systemImage: "bubble.left.and.bubble.right")
                                .foregroundStyle(.primary)
                                .labelStyle(.titleAndIcon)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("Send feedback, report a bug, or request a feature.")
                        .font(.caption)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}

// MARK: - DefaultQuestionsView

struct DefaultQuestionsView: View {
    @EnvironmentObject var store: ItemStore
    @State private var newQuestion      = ""
    @State private var editingQuestion: ReflectionQuestion? = nil
    @State private var showingResetAlert = false
    @FocusState private var addFieldFocused: Bool

    var body: some View {
        List {
            Section {
                if store.defaultQuestions.isEmpty {
                    Text("No default questions. Add one below.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(store.defaultQuestions) { question in
                        QuestionRow(question: question) {
                            editingQuestion = question
                        }
                    }
                    .onDelete { store.deleteDefaultQuestion(at: $0) }
                    .onMove  { store.moveDefaultQuestion(from: $0, to: $1) }
                }
            } header: {
                Text("Default questions")
            } footer: {
                Text("Added to every new item. Swipe to delete, drag to reorder, tap to edit.")
                    .font(.caption)
            }

            Section {
                HStack(spacing: 10) {
                    TextField("New question…", text: $newQuestion)
                        .focused($addFieldFocused)
                        .submitLabel(.done)
                        .onSubmit { submitQuestion() }
                    Button("Add", action: submitQuestion)
                        .disabled(newQuestion.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section {
                Button("Reset to defaults") { showingResetAlert = true }
                    .foregroundStyle(.orange)
            } footer: {
                Text("Restores the original five questions. Only affects new items going forward.")
                    .font(.caption)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Default questions")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset to defaults?", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) { store.resetDefaultQuestions() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This replaces your current default questions. Items you've already added keep their own questions.")
        }
        .sheet(item: $editingQuestion) { question in
            EditQuestionSheet(question: question) { store.updateDefaultQuestion($0) }
        }
    }

    private func submitQuestion() {
        let text = newQuestion.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        store.addDefaultQuestion(text)
        newQuestion = ""
        addFieldFocused = false
    }
}

// MARK: - RejectedItemsView

struct RejectedItemsView: View {
    @EnvironmentObject var store: ItemStore
    @State private var showingClearAlert = false

    var body: some View {
        List {
            if store.rejectedItems.isEmpty {
                Section {
                    Text("No rejected items.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 4)
                }
            } else {
                Section {
                    ForEach(store.rejectedItems) { item in
                        RejectedItemRow(item: item)
                    }
                    .onDelete { store.permanentlyDeleteRejected(at: $0) }
                } header: {
                    Text("Rejected items")
                } footer: {
                    Text("Swipe to permanently delete. These count toward your money saved total.")
                        .font(.caption)
                }

                Section {
                    Button("Clear all rejected items", role: .destructive) {
                        showingClearAlert = true
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Rejected items")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear all rejected items?", isPresented: $showingClearAlert) {
            Button("Clear all", role: .destructive) { store.clearAllRejected() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes \(store.rejectedItems.count) item\(store.rejectedItems.count == 1 ? "" : "s"). This can't be undone.")
        }
    }
}

// MARK: - RejectedItemRow

private struct RejectedItemRow: View {
    let item: PurchaseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.name)
                .font(.body)
                .foregroundStyle(.primary)
            HStack(spacing: 8) {
                Text("Rejected")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
                if let price = item.price {
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text("$\(price, format: .number.precision(.fractionLength(2)))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - QuestionRow

private struct QuestionRow: View {
    let question: ReflectionQuestion
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(question.question)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EditQuestionSheet

struct EditQuestionSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var text: String
    let original: ReflectionQuestion
    let onSave: (ReflectionQuestion) -> Void

    init(question: ReflectionQuestion, onSave: @escaping (ReflectionQuestion) -> Void) {
        self.original = question
        self.onSave   = onSave
        _text = State(initialValue: question.question)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Edit question")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                TextEditor(text: $text)
                    .font(.body)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Edit question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = original
                        updated.question = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.height(260)])
    }
}
