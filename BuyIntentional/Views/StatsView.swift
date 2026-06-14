import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: ItemStore

    var body: some View {
        NavigationStack {
            List {
                savingsSection
                wishlistSection
                insightSection
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
            Text("Sum of prices on all rejected items with a price set.")
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
            Text("Sum of prices on all active items with a price set.")
                .font(.caption)
        }
    }

    private var insightSection: some View {
        Section {
            let total = store.savedTotal + store.wishlistTotal
            if total > 0 {
                let pct = Int((store.savedTotal / total) * 100)
                StatRow(
                    icon: "brain.head.profile",
                    iconColor: .purple,
                    label: "Decisions avoided",
                    value: "\(pct)%",
                    detail: "of tracked spend was rejected"
                )
            } else {
                Text("Add prices to items to see insights.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 4)
            }
        } header: {
            Text("Insights")
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
