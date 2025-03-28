//
//  EntrySummaryView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI

struct EntrySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var entryText: String = ""
    @State private var summary: String = ""
    @State private var keywords: [String] = []
    @State private var mood: String = ""
    @State private var isGeneratingSummary: Bool = false
    @State private var selectedTab: SummaryTab = .summary
    @FocusState private var isTextFieldFocused: Bool
    
    // Define accent color
    let accentColor = Color(hex: "44C0FF")
    
    enum SummaryTab: String, CaseIterable {
        case summary = "Summary"
        case keywords = "Keywords"
        case mood = "Mood"
    }
    
    // Sample journal entry for testing
    let sampleEntry = "Today was a beautiful day at the beach with Sarah. We arrived early to beat the crowds and were rewarded with a perfect sunrise over the water. The waves were gentle, and we spent hours swimming and collecting seashells. For lunch, we had sandwiches at that little cafe we discovered last summer - their avocado BLT is still amazing. On the way home, we stopped at the farmers market and bought fresh strawberries. I'm sunburned but happy - days like these remind me how important it is to take breaks and enjoy simple pleasures."
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                if !summary.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(SummaryTab.allCases, id: \.self) { tab in
                            TabButton(
                                title: tab.rawValue,
                                isSelected: selectedTab == tab,
                                action: { selectedTab = tab }
                            )
                            .accentColor(accentColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if summary.isEmpty {
                            // Entry instructions
                            VStack(alignment: .leading, spacing: 6) {
                                Text("How it works:")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    InstructionRow(number: 1, text: "Paste or type your journal entry")
                                    InstructionRow(number: 2, text: "Generate a concise summary")
                                    InstructionRow(number: 3, text: "See mood analysis and key themes")
                                }
                                .padding(.vertical, 4)
                            }
                            .padding(.horizontal)
                            
                            // Text input area
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your journal entry")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $entryText)
                                        .focused($isTextFieldFocused)
                                        .font(.body)
                                        .padding(12)
                                        .frame(minHeight: 150)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.5))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(isTextFieldFocused ? accentColor : Color.clear, lineWidth: 1.5)
                                        )
                                        .padding(.horizontal)
                                    
                                    if entryText.isEmpty {
                                        Text("Type or paste your journal entry here...")
                                            .foregroundColor(.secondary)
                                            .font(.body)
                                            .padding(.horizontal, 28)
                                            .padding(.top, 20)
                                            .allowsHitTesting(false)
                                    }
                                }
                                
                                // Fill with sample text button
                                Button {
                                    entryText = sampleEntry
                                } label: {
                                    Text("Use sample text")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Generate button
                            Button(action: {
                                isTextFieldFocused = false
                                isGeneratingSummary = true
                                // Simulate summary generation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    generateSampleResults()
                                    isGeneratingSummary = false
                                }
                            }) {
                                HStack {
                                    if isGeneratingSummary {
                                        ProgressView()
                                            .tint(.white)
                                            .padding(.trailing, 8)
                                    } else {
                                        Image(systemName: "sparkles")
                                            .font(.headline)
                                    }
                                    
                                    Text(isGeneratingSummary ? "Generating..." : "Generate Summary")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(accentColor)
                                )
                            }
                            .disabled(entryText.isEmpty || isGeneratingSummary)
                            .padding(.horizontal)
                            .padding(.top, 6)
                        } else {
                            // Results content based on selected tab
                            VStack {
                                switch selectedTab {
                                case .summary:
                                    SummaryView(summary: summary, accentColor: accentColor)
                                case .keywords:
                                    KeywordsView(keywords: keywords, accentColor: accentColor)
                                case .mood:
                                    MoodView(mood: mood, accentColor: accentColor)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            
                            // Action buttons
                            if !summary.isEmpty {
                                HStack(spacing: 12) {
                                    Button {
                                        // Copy to clipboard
                                        let textToCopy: String
                                        switch selectedTab {
                                        case .summary:
                                            textToCopy = summary
                                        case .keywords:
                                            textToCopy = keywords.joined(separator: ", ")
                                        case .mood:
                                            textToCopy = mood
                                        }
                                        UIPasteboard.general.string = textToCopy
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                            .font(.footnote.weight(.medium))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(
                                                Capsule()
                                                    .fill(Color(.systemGray5))
                                            )
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        // Reset and start over
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            summary = ""
                                            keywords = []
                                            mood = ""
                                            selectedTab = .summary
                                        }
                                    } label: {
                                        Label("New Summary", systemImage: "arrow.counterclockwise")
                                            .font(.footnote.weight(.medium))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(
                                                Capsule()
                                                    .fill(accentColor.opacity(0.15))
                                            )
                                            .foregroundColor(accentColor)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Entry Summary")
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // Generate sample results for demonstration
    private func generateSampleResults() {
        // Sample summary
        summary = "A day at the beach with Sarah that included swimming, collecting seashells, and having lunch at a favorite cafe. The trip included a stop at a farmers market before returning home sunburned but content. The entry reflects appreciation for taking breaks and enjoying simple pleasures."
        
        // Sample keywords
        keywords = ["Beach day", "Sarah", "Swimming", "Seashells", "Cafe lunch", "Farmers market", "Strawberries", "Sunburn", "Simple pleasures"]
        
        // Sample mood
        mood = "Joyful and content. The entry expresses appreciation for a day of relaxation and connection, with themes of gratitude and mindfulness about taking time to enjoy life's simple pleasures."
    }
}

// Helper views

// Tab button for navigation
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var accentColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? accentColor : .clear)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Instruction row with number
struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// Summary tab content
struct SummaryView: View {
    let summary: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Summary")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(accentColor)
            }
            
            Text(summary)
                .font(.body)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
}

// Keywords tab content
struct KeywordsView: View {
    let keywords: [String]
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Keywords & Themes")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "tag")
                    .foregroundColor(accentColor)
            }
            
            FlowLayout(spacing: 8) {
                ForEach(keywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.footnote)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(accentColor.opacity(0.15))
                        )
                        .foregroundColor(accentColor)
                }
            }
        }
    }
}

// Mood tab content
struct MoodView: View {
    let mood: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Mood Analysis")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "heart")
                    .foregroundColor(accentColor)
            }
            
            Text(mood)
                .font(.body)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
}

// Flow layout for keywords
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? 0
        
        var height: CGFloat = 0
        var width: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if rowWidth + size.width + spacing > containerWidth && rowWidth > 0 {
                // Move to next row
                width = max(width, rowWidth - spacing)
                height += rowHeight + spacing
                rowWidth = size.width + spacing
                rowHeight = size.height
            } else {
                // Stay on same row
                rowWidth += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
        
        // Account for the last row
        width = max(width, rowWidth - spacing)
        height += rowHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let containerWidth = bounds.width
        
        var rowX: CGFloat = bounds.minX
        var rowY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if rowX + size.width > bounds.maxX && rowX > bounds.minX {
                // Move to next row
                rowX = bounds.minX
                rowY += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(at: CGPoint(x: rowX, y: rowY), proposal: ProposedViewSize(size))
            rowX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    EntrySummaryView()
}