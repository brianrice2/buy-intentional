//
//  StatusBadge.swift
//  shelf
//
//  Created by Brian Rice on 6/11/26.
//


import SwiftUI

// MARK: - StatusBadge

struct StatusBadge: View {
    let status: PurchaseStatus

    var body: some View {
        Text(status.label)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(borderColor, lineWidth: 0.5))
    }

    private var backgroundColor: Color {
        switch status {
        case .waiting:  return Color.orange.opacity(0.12)
        case .approved: return Color.green.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .waiting:  return .orange
        case .approved: return .green
        }
    }

    private var borderColor: Color {
        switch status {
        case .waiting:  return Color.orange.opacity(0.3)
        case .approved: return Color.green.opacity(0.3)
        }
    }
}

// MARK: - StatusToggleButton

struct StatusToggleButton: View {
    let status: PurchaseStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(status.label)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(isSelected ? selectedBg : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? selectedFg : .secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(isSelected ? selectedBorder : Color.clear, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var selectedBg: Color {
        switch status {
        case .waiting:  return Color.orange.opacity(0.12)
        case .approved: return Color.green.opacity(0.12)
        }
    }

    private var selectedFg: Color {
        switch status {
        case .waiting:  return .orange
        case .approved: return .green
        }
    }

    private var selectedBorder: Color {
        switch status {
        case .waiting:  return Color.orange.opacity(0.3)
        case .approved: return Color.green.opacity(0.3)
        }
    }
}

// MARK: - SectionHeader

struct SectionHeader: View {
    let label: String

    var body: some View {
        Text(label.uppercased())
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.tertiary)
            .kerning(0.6)
    }
}

// MARK: - LinkRowView

struct LinkRowView: View {
    let url: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "link")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if let u = URL(string: url) {
                Link(url, destination: u)
                    .font(.subheadline)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } else {
                Text(url)
                    .font(.subheadline)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - QuestionCardView

struct QuestionCardView: View {
    @Binding var question: ReflectionQuestion
    let onDelete: () -> Void
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(question.question)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            TextEditor(text: $question.answer)
                .font(.body)
                .frame(minHeight: 54)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(.separator).opacity(0.4), lineWidth: 0.5)
                )
                .onChange(of: question.answer) { _, _ in onChange() }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}