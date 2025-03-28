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
            ScrollView {
                VStack(spacing: 16) {
                    // Feature buttons top aligned
                    VStack(spacing: 16) {
                        FeatureButton(title: "Image Generation", feature: .imageGeneration, color: accentColor) {
                            print("Button tapped: Image Generation")
                            selectedFeature = .imageGeneration
                        }
                        
                        FeatureButton(title: "Entry Summary", feature: .entrySummary, color: accentColor) {
                            selectedFeature = .entrySummary
                        }
                        
                        FeatureButton(title: "Transcribe Audio", feature: .transcribeAudio, color: accentColor) {
                            print("Transcribe Audio button tapped")
                            selectedFeature = .transcribeAudio
                        }
                        
                        FeatureButton(title: "Photo Description", feature: .photoDescription, color: accentColor) {
                            print("Photo Description button tapped")
                            selectedFeature = .photoDescription
                        }
                        
                        FeatureButton(title: "Captions & Descriptions", feature: .captionsDescriptions, color: accentColor) {
                            print("Captions & Descriptions button tapped")
                            selectedFeature = .captionsDescriptions
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 18)
                    

                }
            }
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
                case .captionsDescriptions:
                    CaptionsDescriptionsView()
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
        Button {
            print("Button tapped: \(title)")
            action()
        } label: {
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
        .buttonStyle(.automatic)
    }
}

// Photo detail view for full screen viewing
struct PhotoDetailView: View {
    let photoIndex: Int
    @Binding var isPresented: Bool
    @State private var isFavorite: Bool = false
    @State private var captionText: String = ""
    @State private var mediaDescription: String = ""
    @State private var isCaptionSheetPresented = false
    @State private var shouldFocusCaption = false
    
    // Sample metadata for the images
    private let metadata = [
        PhotoMetadata(
            caption: "Jana and I parked in the orchard",
            mediaDescription: "The photo depicts the interior of a vintage car, showing a view through the front windshield from the driver's perspective. The dashboard is prominent, featuring classic dials and a steering wheel that suggest a mid-20th-century model. Above, the rearview mirror reflects the image of a woman, presumably the driver, capturing a moment of her journey. The sunlit scene outside displays a rural setting with lush greenery, likely an orchard or vineyard, adding a serene backdrop to the interior's nostalgic ambiance.",
            dateTaken: Date(timeIntervalSince1970: 1710234567),
            location: "Grand Teton National Park, Wyoming",
            camera: "iPhone 13 Pro",
            photoDetails: "f/1.6 4.2mm ISO32",
            filename: "IMG_2024_03_25_0835.jpg"
        ),
        PhotoMetadata(
            caption: "Jana and I parked in the orchard",
            mediaDescription: "The photo depicts the interior of a vintage car, showing a view through the front windshield from the driver's perspective. The dashboard is prominent, featuring classic dials and a steering wheel that suggest a mid-20th-century model. Above, the rearview mirror reflects the image of a woman, presumably the driver, capturing a moment of her journey. The sunlit scene outside displays a rural setting with lush greenery, likely an orchard or vineyard, adding a serene backdrop to the interior's nostalgic ambiance.",
            dateTaken: Date(timeIntervalSince1970: 1710345678),
            location: "Lake Louise, Banff National Park",
            camera: "iPhone 13 Pro",
            photoDetails: "f/1.6 4.2mm ISO50",
            filename: "IMG_2024_03_26_1748.jpg"
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Photo with info icon overlay
                    ZStack(alignment: .topTrailing) {
                        Image("sample")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Small info button in corner of image
                        Button {
                            shouldFocusCaption = false
                            isCaptionSheetPresented = true
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.white)
                                .font(.footnote)
                                .padding(6)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding(8)
                    }
                    
                    // Caption and favorite button
                    HStack {
                        // Caption display (single line)
                        Button {
                            shouldFocusCaption = true
                            isCaptionSheetPresented = true
                        } label: {
                            Text(captionText)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Favorite button
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .white)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.6))
                    
                    // Photo metadata in smaller text
                    VStack(alignment: .leading, spacing: 8) {
                        // Date and time
                        HStack {
                            Image(systemName: "calendar")
                                .frame(width: 20)
                                .font(.footnote)
                            
                            VStack(alignment: .leading) {
                                Text(formatDate(metadata[photoIndex].dateTaken))
                                    .font(.caption)
                                Text(formatTime(metadata[photoIndex].dateTaken))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Location
                        HStack {
                            Image(systemName: "location")
                                .frame(width: 20)
                                .font(.footnote)
                            Text(metadata[photoIndex].location)
                                .font(.caption)
                        }
                        
                        // Camera details
                        HStack {
                            Image(systemName: "camera")
                                .frame(width: 20)
                                .font(.footnote)
                            
                            VStack(alignment: .leading) {
                                Text(metadata[photoIndex].camera)
                                    .font(.caption)
                                Text(metadata[photoIndex].photoDetails)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Filename
                        HStack {
                            Image(systemName: "doc")
                                .frame(width: 20)
                                .font(.footnote)
                            Text(metadata[photoIndex].filename)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .foregroundColor(.white)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                captionText = metadata[photoIndex].caption
                mediaDescription = metadata[photoIndex].mediaDescription
            }
            .sheet(isPresented: $isCaptionSheetPresented) {
                CaptionSheetView(
                    caption: captionText,
                    description: mediaDescription,
                    focusCaption: shouldFocusCaption
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .colorScheme(.dark)
    }
    
    // Helper functions for formatting date and time
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Helper function to calculate text height
    private func calculateTextHeight(text: String, width: CGFloat) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        let textView = UITextView()
        textView.font = font
        textView.text = text
        let size = CGSize(width: width - 16, height: .infinity) // 16 for padding
        let estimatedSize = textView.sizeThatFits(size)
        return estimatedSize.height + 32 // add extra padding
    }
}

// Photo metadata model
struct PhotoMetadata {
    var caption: String
    let mediaDescription: String
    let dateTaken: Date
    let location: String
    let camera: String
    let photoDetails: String
    let filename: String
}

enum AIFeature: String, Identifiable {
    case imageGeneration, entrySummary, transcribeAudio, photoDescription, captionsDescriptions
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .imageGeneration: return "Image Generation"
        case .entrySummary: return "Entry Summary"
        case .transcribeAudio: return "Transcribe Audio"
        case .photoDescription: return "Photo Description"
        case .captionsDescriptions: return "Captions & Descriptions"
        }
    }
}

// Caption sheet view
struct CaptionSheetView: View {
    // Data properties
    let caption: String
    let description: String
    let focusCaption: Bool
    @State private var editedCaption: String
    @State private var editedDescription: String
    @State private var isAIGenerated: Bool = true
    @State private var showsWordCount: Bool = false
    
    // Environment properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Focus states
    @FocusState private var isCaptionFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    
    // Accent color
    let accentColor = Color(hex: "44C0FF")
    
    // Word count computed property
    var wordCount: Int {
        editedDescription.split(separator: " ").count
    }
    
    // Helper function to calculate text height
    private func calculateTextHeight(text: String, width: CGFloat) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let textView = UITextView()
        textView.font = font
        textView.text = text
        let size = CGSize(width: width - 32, height: .infinity) // 32 for padding
        let estimatedSize = textView.sizeThatFits(size)
        return estimatedSize.height + 24 // add extra padding
    }
    
    init(caption: String, description: String = "", focusCaption: Bool = false) {
        self.caption = caption
        self.description = description
        self.focusCaption = focusCaption
        self._editedCaption = State(initialValue: caption)
        self._editedDescription = State(initialValue: description)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header info badge at the top
                    if isAIGenerated {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(accentColor)
                            Text("AI Generated")
                                .font(.footnote.weight(.medium))
                                .foregroundColor(accentColor)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(accentColor.opacity(0.1))
                        )
                        .padding(.top, 8)
                    }
                    
                    // Caption section
                    VStack(alignment: .leading, spacing: 10) {
                        // Caption header
                        HStack {
                            Text("Caption")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Caption character count
                            Text("\(editedCaption.count)/280")
                                .font(.caption)
                                .foregroundColor(editedCaption.count > 280 ? .red : .secondary)
                        }
                        .padding(.horizontal)
                        
                        // Caption text field
                        ZStack(alignment: .topLeading) {
                            if editedCaption.isEmpty {
                                Text("Add a caption...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $editedCaption)
                                .focused($isCaptionFocused)
                                .font(.body)
                                .foregroundColor(.primary)
                                .frame(minHeight: 44, maxHeight: 120)
                                .padding(4)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark 
                                      ? Color(.systemGray6) 
                                      : Color(.systemGray6).opacity(0.5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isCaptionFocused ? accentColor : Color.clear, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Media Description section
                    VStack(alignment: .leading, spacing: 10) {
                        // Description header with word count toggle
                        HStack {
                            Text("Media Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if showsWordCount {
                                // Word count badge
                                Text("\(wordCount) words")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray5))
                                    )
                            }
                            
                            // Word count toggle
                            Button {
                                showsWordCount.toggle()
                            } label: {
                                Image(systemName: showsWordCount ? "number.circle.fill" : "number.circle")
                                    .foregroundColor(showsWordCount ? accentColor : .secondary)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Description text editor
                        ZStack(alignment: .topLeading) {
                            if editedDescription.isEmpty {
                                Text("Add a description...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            
                            GeometryReader { geometry in
                                TextEditor(text: $editedDescription)
                                    .focused($isDescriptionFocused)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(
                                        minHeight: max(150, calculateTextHeight(
                                            text: editedDescription,
                                            width: geometry.size.width
                                        ))
                                    )
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .padding(8)
                            }
                            .frame(minHeight: 150)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark 
                                      ? Color(.systemGray6) 
                                      : Color(.systemGray6).opacity(0.5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isDescriptionFocused ? accentColor : Color.clear, lineWidth: 2)
                        )
                        .padding(.horizontal)
                        
                        // Actions row
                        HStack {
                            // Regenerate button
                            Button {
                                // Regenerate description action
                            } label: {
                                Label("Regenerate", systemImage: "arrow.clockwise")
                                    .font(.footnote.weight(.medium))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule()
                                    .fill(accentColor.opacity(0.1))
                            )
                            
                            Spacer()
                            
                            // Copy button
                            Button {
                                UIPasteboard.general.string = editedDescription
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                                    .font(.footnote.weight(.medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray5))
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                // Set focus based on parameter
                if focusCaption {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isCaptionFocused = true
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(accentColor)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}