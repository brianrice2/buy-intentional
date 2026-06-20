import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: ItemStore

    var body: some View {
        NavigationStack {
            List {
                savingsSection
                wishlistSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Sections

    private var savingsSection: some View {
        Section {
            StatRow(
                icon: "checkmark.seal.fill",
                iconColor: .green,
                label: "Money saved",
                value: formatted(store.savedTotal),
                detail: "\(store.rejectedItems.count) item\(store.rejectedItems.count == 1 ? "" : "s") rejected"
            )
        } header: {
            Text("Savings")
        } footer: {
            Text("You've saved this much money by deciding not to go through with a purchase (requires a price to be set).")
                .font(.caption)
        }
    }

    private var wishlistSection: some View {
        Section {
            StatRow(
                icon: "cart.fill",
                iconColor: .blue,
                label: "Wishlist total",
                value: formatted(store.wishlistTotal),
                detail: "\(store.activeItems.count) item\(store.activeItems.count == 1 ? "" : "s") on the list"
            )
        } header: {
            Text("Current wishlist")
        } footer: {
            Text("Your wishlist costs this much in total.")
                .font(.caption)
        }
    }

    // MARK: - Helpers

    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

// MARK: - StatRow

private struct StatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let detail: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 6)
    }
}
