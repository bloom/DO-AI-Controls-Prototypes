//
//  CaptionsDescriptionsView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI

struct CaptionsDescriptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoIndex: Int = 0
    @State private var isPhotoViewPresented = false
    @State private var isCaptionSheetPresented = false
    @State private var shouldFocusCaption = false
    @State private var isQuickLookPresented = false
    
    // Define app accent color
    let accentColor = Color(hex: "44C0FF")
    
    // Sample image metadata
    private let imageMetadata = [
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
            caption: "Morning hike through the redwoods",
            mediaDescription: "This photograph captures a serene forest trail winding through towering redwood trees. Shafts of golden morning light filter through the dense canopy, creating dramatic beams that illuminate the misty atmosphere. The path is carpeted with fallen leaves and soft moss, giving it a lush, inviting appearance. Tall redwood trunks rise majestically on either side, their reddish-brown bark contrasting with the various shades of green from surrounding ferns and underbrush. The perspective draws the viewer into the scene, suggesting a peaceful journey through this ancient, majestic woodland.",
            dateTaken: Date(timeIntervalSince1970: 1710345678),
            location: "Redwood National Park, California",
            camera: "iPhone 13 Pro",
            photoDetails: "f/1.6 4.2mm ISO50",
            filename: "IMG_2024_03_26_1748.jpg"
        ),
        PhotoMetadata(
            caption: "Coffee at the harbor with Tom",
            mediaDescription: "This image depicts a cozy coffee shop scene overlooking a harbor. In the foreground, a wooden table holds two artisanal coffee cups - one appears to be a latte with decorative foam art, while the other looks like a black coffee. A small plate with partially eaten pastries sits between them. Beyond the table is a large window providing a panoramic view of a picturesque harbor, where several sailboats and small fishing vessels are moored in calm blue water. The morning light reflects off the water's surface, creating a peaceful ambiance. The composition suggests an intimate conversation between friends enjoying coffee while appreciating the serene maritime view.",
            dateTaken: Date(timeIntervalSince1970: 1710456789),
            location: "Marina Bay, San Francisco",
            camera: "iPhone 13 Pro",
            photoDetails: "f/1.6 4.2mm ISO40",
            filename: "IMG_2024_03_27_0932.jpg"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Look button
                    Button {
                        isQuickLookPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "eye")
                            Text("Quick Look")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(accentColor.opacity(0.1))
                        )
                        .foregroundColor(accentColor)
                    }
                    .padding(.horizontal, 18)
                    
                    // First sample image with caption and info icon
                    ZStack {
                        // Image with button
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
                        
                        // Info icon overlay (top right)
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    selectedPhotoIndex = 0
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
                            Spacer()
                        }
                        
                        // Caption overlay (bottom)
                        VStack {
                            Spacer()
                            Button {
                                selectedPhotoIndex = 0
                                shouldFocusCaption = true
                                isCaptionSheetPresented = true
                            } label: {
                                Text(imageMetadata[0].caption)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    // Second sample image with caption and info icon
                    ZStack {
                        // Image with button
                        Button {
                            selectedPhotoIndex = 1
                            isPhotoViewPresented = true
                        } label: {
                            Image("sample1")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Info icon overlay (top right)
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    selectedPhotoIndex = 1
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
                            Spacer()
                        }
                        
                        // Caption overlay (bottom)
                        VStack {
                            Spacer()
                            Button {
                                selectedPhotoIndex = 1
                                shouldFocusCaption = true
                                isCaptionSheetPresented = true
                            } label: {
                                Text(imageMetadata[1].caption)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    // Third sample image with caption and info icon
                    ZStack {
                        // Image with button
                        Button {
                            selectedPhotoIndex = 2
                            isPhotoViewPresented = true
                        } label: {
                            Image("sample2")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Info icon overlay (top right)
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    selectedPhotoIndex = 2
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
                            Spacer()
                        }
                        
                        // Caption overlay (bottom)
                        VStack {
                            Spacer()
                            Button {
                                selectedPhotoIndex = 2
                                shouldFocusCaption = true
                                isCaptionSheetPresented = true
                            } label: {
                                Text(imageMetadata[2].caption)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
            .navigationTitle("Captions & Descriptions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .sheet(isPresented: $isPhotoViewPresented) {
                LocalPhotoDetailView(photoIndex: selectedPhotoIndex, isPresented: $isPhotoViewPresented, metadata: imageMetadata)
            }
            .sheet(isPresented: $isCaptionSheetPresented) {
                CaptionSheetView(
                    caption: imageMetadata[selectedPhotoIndex].caption,
                    description: imageMetadata[selectedPhotoIndex].mediaDescription,
                    focusCaption: shouldFocusCaption
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $isQuickLookPresented) {
                QuickLookFullScreen(imageSources: ["sample", "sample1", "sample2"])
            }
        }
    }
}

// Local implementation of PhotoDetailView
struct LocalPhotoDetailView: View {
    let photoIndex: Int
    @Binding var isPresented: Bool
    let metadata: [PhotoMetadata]
    @State private var isFavorite: Bool = false
    @State private var captionText: String = ""
    @State private var mediaDescription: String = ""
    @State private var isCaptionSheetPresented = false
    @State private var shouldFocusCaption = false
    
    // Different image sources based on index
    private var imageName: String {
        switch photoIndex {
        case 0: return "sample"
        case 1: return "sample1"
        case 2: return "sample2"
        default: return "sample"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Photo with info icon overlay
                    ZStack(alignment: .topTrailing) {
                        Image(imageName)
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
}

// Simpler QuickLook implementation
struct QuickLookFullScreen: View {
    @Environment(\.dismiss) private var dismiss
    var imageSources: [String]
    
    var body: some View {
        NavigationView {
            TabView {
                ForEach(imageSources, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    CaptionsDescriptionsView()
}