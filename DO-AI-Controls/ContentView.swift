//
//  ContentView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFeature: AIFeature?
    
    // Define app accent color
    let accentColor = Color(hex: "44C0FF")
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                Text("AI Features")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
                    .padding(.bottom, 20)
                
                FeatureButton(title: "Image Generation", feature: .imageGeneration, color: accentColor) {
                    selectedFeature = .imageGeneration
                }
                
                FeatureButton(title: "Entry Summary", feature: .entrySummary, color: accentColor) {
                    selectedFeature = .entrySummary
                }
                
                FeatureButton(title: "Transcribe Audio", feature: .transcribeAudio, color: accentColor) {
                    selectedFeature = .transcribeAudio
                }
                
                FeatureButton(title: "Photo Description", feature: .photoDescription, color: accentColor) {
                    selectedFeature = .photoDescription
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Day One AI")
            .sheet(item: $selectedFeature) { feature in
                switch feature {
                case .imageGeneration:
                    ImageGenerationView()
                case .entrySummary:
                    EntrySummaryView()
                case .transcribeAudio:
                    TranscribeAudioView()
                case .photoDescription:
                    PhotoDescriptionView()
                }
            }
        }
        .tint(accentColor)
    }
}

struct FeatureButton: View {
    let title: String
    let feature: AIFeature
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(maxWidth: 280)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                )
                .foregroundColor(color)
        }
        .buttonStyle(.plain)
    }
}

enum AIFeature: String, Identifiable {
    case imageGeneration, entrySummary, transcribeAudio, photoDescription
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .imageGeneration: return "Image Generation"
        case .entrySummary: return "Entry Summary"
        case .transcribeAudio: return "Transcribe Audio"
        case .photoDescription: return "Photo Description"
        }
    }
}

#Preview {
    ContentView()
}
