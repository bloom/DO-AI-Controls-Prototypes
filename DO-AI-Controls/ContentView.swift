//
//  ContentView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFeature: AIFeature?
    @State private var selectedPhotoIndex: Int?
    @State private var isPhotoViewPresented = false
    @State private var isCaptionSheetPresented = false
    
    // Define app accent color
    let accentColor = Color(hex: "44C0FF")
    
    // Sample captions for the images
    private let imageCaptions = [
        "The photo depicts the interior of a vintage car, showing a view through the front windshield from the driver's perspective. The dashboard is prominent, featuring classic dials and a steering wheel that suggest a mid-20th-century model. Above, the rearview mirror reflects the image of a woman, presumably the driver, capturing a moment of her journey. The sunlit scene outside displays a rural setting with lush greenery, likely an orchard or vineyard, adding a serene backdrop to the interior's nostalgic ambiance.",
        "The photo depicts the interior of a vintage car, showing a view through the front windshield from the driver's perspective. The dashboard is prominent, featuring classic dials and a steering wheel that suggest a mid-20th-century model. Above, the rearview mirror reflects the image of a woman, presumably the driver, capturing a moment of her journey. The sunlit scene outside displays a rural setting with lush greenery, likely an orchard or vineyard, adding a serene backdrop to the interior's nostalgic ambiance."
    ]
    
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
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 18)
                    
                    // Sample images in landscape orientation
                    VStack(spacing: 20) {
                        // First sample image with caption
                        ZStack(alignment: .bottom) {
                            Button {
                                selectedPhotoIndex = 0
                                isPhotoViewPresented = true
                            } label: {
                                Image("sample")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Caption overlay
                            Button {
                                selectedPhotoIndex = 0
                                isCaptionSheetPresented = true
                            } label: {
                                Text(imageCaptions[0])
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        // Second sample image with caption
                        ZStack(alignment: .bottom) {
                            Button {
                                selectedPhotoIndex = 1
                                isPhotoViewPresented = true
                            } label: {
                                Image("sample")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Caption overlay
                            Button {
                                selectedPhotoIndex = 1
                                isCaptionSheetPresented = true
                            } label: {
                                Text(imageCaptions[1])
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
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
                }
            }
            .sheet(isPresented: $isPhotoViewPresented) {
                if let index = selectedPhotoIndex {
                    PhotoDetailView(photoIndex: index, isPresented: $isPhotoViewPresented)
                }
            }
            .sheet(isPresented: $isCaptionSheetPresented) {
                if let index = selectedPhotoIndex {
                    CaptionSheetView(caption: imageCaptions[index])
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
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
    @State private var isCaptionSheetPresented = false
    
    // Sample metadata for the images
    private let metadata = [
        PhotoMetadata(
            caption: "The photo depicts the interior of a vintage car, showing a view through the front windshield from the driver's perspective. The dashboard is prominent, featuring classic dials and a steering wheel that suggest a mid-20th-century model. Above, the rearview mirror reflects the image of a woman, presumably the driver, capturing a moment of her journey. The sunlit scene outside displays a rural setting with lush greenery, likely an orchard or vineyard, adding a serene backdrop to the interior's nostalgic ambiance.",
            dateTaken: Date(timeIntervalSince1970: 1710234567),
            location: "Grand Teton National Park, Wyoming",
            camera: "iPhone 13 Pro",
            photoDetails: "f/1.6 4.2mm ISO32",
            filename: "IMG_2024_03_25_0835.jpg"
        ),
        PhotoMetadata(
            caption: "The photo depicts the interior of a vintage car, showing a view through the front windshield from the driver's perspective. The dashboard is prominent, featuring classic dials and a steering wheel that suggest a mid-20th-century model. Above, the rearview mirror reflects the image of a woman, presumably the driver, capturing a moment of her journey. The sunlit scene outside displays a rural setting with lush greenery, likely an orchard or vineyard, adding a serene backdrop to the interior's nostalgic ambiance.",
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
                    // Photo
                    Image("sample")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Caption with favorite button
                    HStack(alignment: .top) {
                        // Caption display (limited to 2 lines)
                        Button {
                            isCaptionSheetPresented = true
                        } label: {
                            Text(captionText)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.5))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Favorite button
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .white)
                                .font(.title3)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                )
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 16)
                    
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
            }
            .sheet(isPresented: $isCaptionSheetPresented) {
                CaptionSheetView(caption: captionText)
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
}

// Photo metadata model
struct PhotoMetadata {
    let caption: String
    let dateTaken: Date
    let location: String
    let camera: String
    let photoDetails: String
    let filename: String
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

// Caption sheet view
struct CaptionSheetView: View {
    let caption: String
    @State private var editedCaption: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    init(caption: String) {
        self.caption = caption
        self._editedCaption = State(initialValue: caption)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                TextEditor(text: $editedCaption)
                    .focused($isTextFieldFocused)
                    .foregroundColor(.primary)
                    .frame(minHeight: geometry.size.height - 40) // Account for safe areas
                    .padding()
            }
            .navigationTitle("Photo Caption")
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