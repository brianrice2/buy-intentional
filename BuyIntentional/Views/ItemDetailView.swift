//
//  ItemDetailView.swift
//  shelf
//
//  Created by Brian Rice on 6/11/26.
//


import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var store: ItemStore
    @Environment(\.dismiss) var dismiss

    // Local working copy — committed on every change
    @State private var item: PurchaseItem
    @State private var newLink = ""
    @State private var newQuestion = ""
    @State private var showingDeleteAlert = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable { case notes, link, question }

    init(item: PurchaseItem) {
        _item = State(initialValue: item)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statusSection
                Divider()
                notesSection
                Divider()
                linksSection
                Divider()
                questionsSection
                Divider()
                deleteSection
            }
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.large)
        .alert("Remove \"\(item.name)\"?", isPresented: $showingDeleteAlert) {
            Button("Remove", role: .destructive) {
                store.delete(item)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }

    // MARK: - Sections

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(label: "Status")
            HStack(spacing: 10) {
                ForEach(PurchaseStatus.allCases, id: \.self) { status in
                    StatusToggleButton(
                        status: status,
                        isSelected: item.status == status
                    ) {
                        item.status = status
                        commit()
                    }
                }
                Spacer()
            }
            Text("Added \(item.dateAdded.formatted(date: .abbreviated, time: .omitted)) · \(item.daysSinceAdded) days ago")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(label: "Notes")
            TextEditor(text: $item.notes)
                .font(.body)
                .frame(minHeight: 80)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .focused($focusedField, equals: .notes)
                .onChange(of: item.notes) { _, _ in commit() }
        }
    }

    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(label: "Links")

            if !item.links.isEmpty {
                VStack(spacing: 6) {
                    ForEach(item.links, id: \.self) { url in
                        LinkRowView(url: url) {
                            item.links.removeAll { $0 == url }
                            commit()
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("https://…", text: $newLink)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .link)
                    .submitLabel(.done)
                    .onSubmit { submitLink() }

                Button("Add", action: submitLink)
                    .disabled(newLink.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(label: "Reflection questions")

            ForEach($item.questions) { $q in
                QuestionCardView(question: $q) {
                    item.questions.removeAll { $0.id == q.id }
                    commit()
                } onChange: {
                    commit()
                }
            }

            HStack(spacing: 8) {
                TextField("Add your own question…", text: $newQuestion)
                    .focused($focusedField, equals: .question)
                    .submitLabel(.done)
                    .onSubmit { submitQuestion() }

                Button("Add", action: submitQuestion)
                    .disabled(newQuestion.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.top, 4)
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            Label("Remove item", systemImage: "trash")
                .font(.subheadline)
        }
        .padding(.top, 4)
    }

    // MARK: - Actions

    private func commit() {
        store.update(item)
    }

    private func submitLink() {
        var url = newLink.trimmingCharacters(in: .whitespaces)
        guard !url.isEmpty else { return }
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            url = "https://" + url
        }
        item.links.append(url)
        commit()
        newLink = ""
    }

    private func submitQuestion() {
        let q = newQuestion.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        item.questions.append(ReflectionQuestion(question: q))
        commit()
        newQuestion = ""
    }
}