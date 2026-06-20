import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var store: ItemStore
    @Environment(\.dismiss) var dismiss

    @State private var item: PurchaseItem
    @State private var priceText    = ""
    @State private var newLink      = ""
    @State private var newQuestion  = ""
    @State private var showingRejectAlert = false
    @State private var showingEditName    = false
    @State private var editedName         = ""
    @FocusState private var focusedField: Field?
    @FocusState private var nameFieldFocused: Bool

    enum Field: Hashable { case price, notes, link, question }

    init(item: PurchaseItem) {
        _item = State(initialValue: item)
        // Seed priceText from existing price if present
        if let p = item.price {
            _priceText = State(initialValue: String(format: "%.2f", p))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statusSection
                Divider()
                priceSection
                Divider()
                notesSection
                Divider()
                linksSection
                Divider()
                questionsSection
                Divider()
                rejectSection
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editedName = item.name
                    showingEditName = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditName) {
            editNameSheet
        }
        .alert("Reject \"\(item.name)\"?", isPresented: $showingRejectAlert) {
            Button("Reject", role: .destructive) {
                store.reject(item)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will move the item to your rejected list. You can permanently delete it from Settings.")
        }
    }

    // MARK: - Sections

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(label: "Status")
            HStack(spacing: 10) {
                ForEach(PurchaseStatus.allCases, id: \.self) { status in
                    StatusToggleButton(status: status, isSelected: item.status == status) {
                        item.status = status
                        commit()
                    }
                }
                Spacer()
            }
            Text("Added \(item.dateAdded.formatted(date: .abbreviated, time: .omitted)) · \(item.daysSinceAdded)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(label: "Price")
            HStack {
                Text("$")
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $priceText)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                    .onChange(of: priceText) { _, newVal in
                        // Strip non-numeric characters except decimal
                        let filtered = newVal.filter { $0.isNumber || $0 == "." }
                        if filtered != newVal { priceText = filtered }
                        item.price = Double(filtered)
                        commit()
                    }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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

    private var rejectSection: some View {
        Button(role: .destructive) {
            showingRejectAlert = true
        } label: {
            Label("Reject item", systemImage: "xmark.circle")
                .font(.subheadline)
        }
        .padding(.top, 4)
    }

    private var editNameSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Item name")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                TextField("Item name", text: $editedName)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .focused($nameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { submitNameEdit() }

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Edit name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingEditName = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { submitNameEdit() }
                        .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { nameFieldFocused = true }
        }
        .presentationDetents([.height(200)])
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

    private func submitNameEdit() {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        item.name = trimmed
        commit()
        showingEditName = false
    }
}
