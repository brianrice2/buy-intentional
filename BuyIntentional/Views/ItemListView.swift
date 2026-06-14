import SwiftUI

struct ItemListView: View {
    @EnvironmentObject var store: ItemStore
    @State private var showingAddSheet  = false
    @State private var showingSettings  = false
    @State private var showingStats     = false
//    @State private var shareURL: IdentifiableURL? = nil
    @State private var newItemName = ""

    var body: some View {
        NavigationStack {
            Group {
                if store.activeItems.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("BuyIntentional")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 4) {
                        Button { showingSettings = true } label: {
                            Image(systemName: "gearshape")
                        }
                        Button { showingStats = true } label: {
                            Image(systemName: "chart.bar")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 4) {
//                        if !store.activeItems.isEmpty {
//                            Button {
//                                shareURL = IdentifiableURL(url: HTMLExporter.tempFile(for: store.activeItems))
//                            } label: {
//                                Image(systemName: "square.and.arrow.up")
//                            }
//                        }
                        Button { showingAddSheet = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet)  { addSheet }
            .sheet(isPresented: $showingSettings)  { SettingsView() }
            .sheet(isPresented: $showingStats)      { StatsView() }
//            .sheet(item: $shareURL) { identifiable in
//                ShareSheet(items: [identifiable.url])
//                    .presentationDetents([.medium, .large])
//            }
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(store.activeItems) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ItemRowView(item: item)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .onDelete { offsets in
                store.rejectActive(at: offsets)
            }
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("Nothing here yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap + to add something you're considering buying.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("What are you considering?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                TextField("Item name", text: $newItemName)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .submitLabel(.done)
                    .onSubmit { submitAdd() }

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Add item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newItemName = ""
                        showingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { submitAdd() }
                        .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.height(200)])
    }

    private func submitAdd() {
        let name = newItemName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        store.add(name: name)
        newItemName = ""
        showingAddSheet = false
    }
}
