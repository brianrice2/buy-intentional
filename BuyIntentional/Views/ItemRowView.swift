//
//  ItemRowView.swift
//  shelf
//
//  Created by Brian Rice on 6/11/26.
//


import SwiftUI

struct ItemRowView: View {
    let item: PurchaseItem

    var body: some View {
        HStack(spacing: 12) {
            statusDot

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Text(daysLabel)
                    Text("·")
                    Text("\(item.answeredQuestionCount)/\(item.questions.count) questions")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            StatusBadge(status: item.status)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
        )
    }

    private var statusDot: some View {
        Circle()
            .fill(item.status == .approved ? Color.green : Color.orange)
            .frame(width: 8, height: 8)
    }

    private var daysLabel: String {
        switch item.daysSinceAdded {
        case 0:  return "Today"
        case 1:  return "1 day ago"
        default: return "\(item.daysSinceAdded) days ago"
        }
    }
}