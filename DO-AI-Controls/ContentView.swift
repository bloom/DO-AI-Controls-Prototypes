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
    let caption: String
    let description: String
    let focusCaption: Bool
    @State private var editedCaption: String
    @State private var editedDescription: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCaptionFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    
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
                    // Caption label and text field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Caption")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        TextField("Add a caption...", text: $editedCaption)
                            .focused($isCaptionFocused)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.horizontal)
                    }
                    .padding(.top, 12)
                    
                    // Media description field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Media Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Gray background with auto-expanding height TextEditor
                        GeometryReader { geometry in
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.15))
                                
                                TextEditor(text: $editedDescription)
                                    .focused($isDescriptionFocused)
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(Color.clear)
                                    .frame(
                                        minHeight: calculateTextHeight(
                                            text: editedDescription,
                                            width: geometry.size.width
                                        )
                                    )
                            }
                        }
                        .frame(height: min(600, max(300, calculateTextHeight(text: editedDescription, width: UIScreen.main.bounds.width - 50))))
                        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                    }
                    .padding(.horizontal)
                    
                    // Add extra space to ensure content scrolls behind keyboard
                    Spacer(minLength: 300)
                }
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}