//
//  SlidersView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 11/22/25.
//

import SwiftUI

struct SlidersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sliderValue: Double = 0

    // Define accent color
    let accentColor = Color(hex: "44C0FF")

    // Slider states based on position
    enum SliderState: Int, CaseIterable {
        case disabled = 0
        case veryUnhappy = 1
        case unhappy = 2
        case neutral = 3
        case happy = 4
        case veryHappy = 5

        var emoji: String {
            switch self {
            case .disabled: return "😶"
            case .veryUnhappy: return "😢"
            case .unhappy: return "😟"
            case .neutral: return "😐"
            case .happy: return "🙂"
            case .veryHappy: return "😀"
            }
        }

        var color: Color {
            switch self {
            case .disabled: return Color.gray.opacity(0.3)
            case .veryUnhappy: return Color(red: 0.8, green: 0.2, blue: 0.2) // Red
            case .unhappy: return Color(red: 0.9, green: 0.4, blue: 0.2) // Orange
            case .neutral: return Color(red: 0.95, green: 0.75, blue: 0.2) // Yellow
            case .happy: return Color(red: 0.7, green: 0.85, blue: 0.3) // Yellow-green
            case .veryHappy: return Color(red: 0.3, green: 0.75, blue: 0.4) // Green
            }
        }

        var isEnabled: Bool {
            return self != .disabled
        }
    }

    var currentState: SliderState {
        let roundedValue = Int(sliderValue.rounded())
        return SliderState(rawValue: roundedValue) ?? .disabled
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                // Native SwiftUI Slider component
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            Slider(value: $sliderValue, in: 0...5, step: 1) {
                                Text("Rating")
                            } onEditingChanged: { editing in
                                if !editing {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        sliderValue = sliderValue.rounded()
                                    }
                                }
                            }
                            .tint(currentState.color)
                            .padding(.leading, 24)

                            // Emoji indicator
                            Text(currentState.emoji)
                                .font(.system(size: 32))
                                .frame(width: 44)
                                .padding(.trailing, 16)
                        }
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .padding(.horizontal)
                    }

                    // State label
                    Text(stateLabel)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .navigationTitle("Sliders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var stateLabel: String {
        switch currentState {
        case .disabled: return "Disabled"
        case .veryUnhappy: return "Very Unhappy"
        case .unhappy: return "Unhappy"
        case .neutral: return "Neutral"
        case .happy: return "Happy"
        case .veryHappy: return "Very Happy"
        }
    }
}

#Preview {
    SlidersView()
}
