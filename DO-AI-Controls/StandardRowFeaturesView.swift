//
//  StandardRowFeaturesView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 11/26/25.
//

import SwiftUI

struct StandardRowFeaturesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSections: Set<Int> = [0] // First section expanded by default

    // Accent color
    let accentColor = Color(hex: "44C0FF")

    // Sample sections data
    let sections = [
        SectionData(
            title: "Pinned",
            systemImage: "pin.fill",
            items: ["Vacation 2025", "Family Photos", "Best Moments"]
        ),
        SectionData(
            title: "Albums",
            systemImage: "rectangle.stack",
            items: ["Recent", "Favorites", "Screenshots", "Videos"]
        ),
        SectionData(
            title: "People & Pets",
            systemImage: "person.2",
            items: ["John Doe", "Jane Smith", "Fluffy the Cat", "Max the Dog"]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header row (always visible)
                    HStack {
                        Text("Collections")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Expandable sections
                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        SectionRow(
                            section: section,
                            isExpanded: expandedSections.contains(index),
                            accentColor: accentColor
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if expandedSections.contains(index) {
                                    expandedSections.remove(index)
                                } else {
                                    expandedSections.insert(index)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Model for section data
struct SectionData {
    let title: String
    let systemImage: String
    let items: [String]
}

// Individual section row component
struct SectionRow: View {
    let section: SectionData
    let isExpanded: Bool
    let accentColor: Color
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Button(action: onTap) {
                HStack {
                    // Icon and title
                    HStack(spacing: 12) {
                        Image(systemName: section.systemImage)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .frame(width: 28)

                        Text(section.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            // Expandable content
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                        Button {
                            print("Item tapped: \(item)")
                        } label: {
                            HStack(spacing: 12) {
                                // Placeholder image
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hue: Double(index) / Double(section.items.count), saturation: 0.6, brightness: 0.8),
                                                Color(hue: Double(index) / Double(section.items.count), saturation: 0.4, brightness: 0.9)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.title2)
                                    )

                                // Item title
                                Text(item)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()

                                // Chevron
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary.opacity(0.5))
                            }
                            .padding(.vertical, 8)
                            .padding(.leading, 40) // Indent content
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Divider between items (except last)
                        if index < section.items.count - 1 {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
            }

            // Divider between sections
            Divider()
        }
    }
}

#Preview {
    StandardRowFeaturesView()
}
