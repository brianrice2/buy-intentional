import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ItemStore
    @State private var newQuestion = ""
    @State private var editingQuestion: ReflectionQuestion? = nil
    @State private var showingResetAlert = false
    @FocusState private var addFieldFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                defaultQuestionsSection
                addQuestionSection
                resetSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("Reset to defaults?", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    store.resetDefaultQuestions()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This replaces your current default questions. Items you've already added keep their own questions.")
            }
            .sheet(item: $editingQuestion) { question in
                EditQuestionSheet(question: question) { updated in
                    store.updateDefaultQuestion(updated)
                }
            }
        }
    }

    // MARK: - Sections

    private var defaultQuestionsSection: some View {
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
                .onDelete { offsets in
                    store.deleteDefaultQuestion(at: offsets)
                }
                .onMove { source, destination in
                    store.moveDefaultQuestion(from: source, to: destination)
                }
            }
        } header: {
            Text("Default questions")
        } footer: {
            Text("These questions are added to every new item. Swipe to delete, drag to reorder, tap to edit.")
                .font(.caption)
        }
    }

    private var addQuestionSection: some View {
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
    }

    private var resetSection: some View {
        Section {
            Button("Reset to defaults") {
                showingResetAlert = true
            }
            .foregroundStyle(.orange)
        } footer: {
            Text("Restores the original five questions. Only affects new items going forward.")
                .font(.caption)
        }
    }

    // MARK: - Actions

    private func submitQuestion() {
        let text = newQuestion.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        store.addDefaultQuestion(text)
        newQuestion = ""
        addFieldFocused = false
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
        self.onSave = onSave
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
