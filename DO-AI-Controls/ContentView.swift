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

                        FeatureButton(title: "Image Generation 2", feature: .imageGeneration2, color: accentColor) {
                            print("Button tapped: Image Generation 2")
                            selectedFeature = .imageGeneration2
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
                        
                        FeatureButton(title: "iOS Native Views", feature: .iOSNativeViews, color: accentColor) {
                            print("iOS Native Views button tapped")
                            selectedFeature = .iOSNativeViews
                        }
                        
                        FeatureButton(title: "iOS Presentation Methods", feature: .presentationMethods, color: accentColor) {
                            print("iOS Presentation Methods button tapped")
                            selectedFeature = .presentationMethods
                        }
                        
                        FeatureButton(title: "Keyboard Accessories", feature: .keyboardAccessories, color: accentColor) {
                            print("Keyboard Accessories button tapped")
                            selectedFeature = .keyboardAccessories
                        }

                        FeatureButton(title: "Sliders", feature: .sliders, color: accentColor) {
                            print("Sliders button tapped")
                            selectedFeature = .sliders
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
                case .imageGeneration2:
                    ImageGenerationView2()
                case .entrySummary:
                    EntrySummaryView()
                case .transcribeAudio:
                    TranscribeAudioView()
                case .photoDescription:
                    PhotoDescriptionView()
                case .captionsDescriptions:
                    CaptionsDescriptionsView()
                case .iOSNativeViews:
                    IOSNativeViewsView()
                case .presentationMethods:
                    PresentationMethodsView()
                case .keyboardAccessories:
                    KeyboardAccessoriesView()
                case .sliders:
                    SlidersView()
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
                KeyboardAwarePanel {
                    CaptionSheetView(
                        caption: captionText,
                        description: mediaDescription,
                        focusCaption: shouldFocusCaption
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width - 32)
                }
            }
            .interactiveDismissDisabled()
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
    case imageGeneration, imageGeneration2, entrySummary, transcribeAudio, photoDescription, captionsDescriptions, iOSNativeViews, presentationMethods, keyboardAccessories, sliders

    var id: String { rawValue }

    var title: String {
        switch self {
        case .imageGeneration: return "Image Generation"
        case .imageGeneration2: return "Image Generation 2"
        case .entrySummary: return "Entry Summary"
        case .transcribeAudio: return "Transcribe Audio"
        case .photoDescription: return "Photo Description"
        case .captionsDescriptions: return "Captions & Descriptions"
        case .iOSNativeViews: return "iOS Native Views"
        case .presentationMethods: return "iOS Presentation Methods"
        case .keyboardAccessories: return "Keyboard Accessories"
        case .sliders: return "Sliders"
        }
    }
}

// Caption & details floating panel
struct CaptionSheetView: View {
    // Data properties
    let caption: String
    let focusCaption: Bool
    @State private var editedCaption: String
    @State private var isFavorite: Bool = false
    
    // Environment properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Focus states
    @FocusState private var isCaptionFocused: Bool
    
    // Sample data (would come from actual photo in real implementation)
    private let dateTaken = Date()
    private let location = "Grand Teton National Park"
    private let placeName = "Jenny Lake Trail"
    
    // Accent color
    let accentColor = Color(hex: "44C0FF")
    
    init(caption: String, description: String = "", focusCaption: Bool = false) {
        self.caption = caption
        self.focusCaption = focusCaption
        self._editedCaption = State(initialValue: caption)
    }
    
    var body: some View {
        // Floating panel design
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Handle at top for visual cue this is draggable
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .cornerRadius(2)
                    .padding(.vertical, 8)
                
                VStack(spacing: 12) {
                    // Date, Time, Time Zone row with Favorite on right
                    HStack(alignment: .center) {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatDate(dateTaken))
                                .font(.subheadline)
                            HStack(spacing: 4) {
                                Text(formatTime(dateTaken))
                                Text("·")
                                Text(timeZoneName())
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Favorite button (heart)
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .secondary)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Location, Place Name row
                    HStack(alignment: .center) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(location)
                                .font(.subheadline)
                            Text(placeName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Caption section (single line)
                    VStack(alignment: .leading, spacing: 10) {
                        // Caption header
                        HStack {
                            Text("Caption")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Caption character count
                            Text("\(editedCaption.count)/280")
                                .font(.caption)
                                .foregroundColor(editedCaption.count > 280 ? .red : .secondary)
                        }
                        .padding(.horizontal)
                        
                        // Caption text field (single line)
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark 
                                      ? Color(.systemGray5) 
                                      : Color(.systemGray6).opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isCaptionFocused ? accentColor : Color.clear, lineWidth: 1.5)
                                )
                            
                            TextField("Add a caption...", text: $editedCaption)
                                .focused($isCaptionFocused)
                                .font(.body)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .contentShape(Rectangle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.top, 8)
            }
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            
            // Close (X) button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                    )
            }
            .padding(.top, 8)
            .padding(.trailing, 12)
        }
        .onAppear {
            // Set focus based on parameter
            if focusCaption {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isCaptionFocused = true
                }
            }
        }
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
    
    private func timeZoneName() -> String {
        return TimeZone.current.abbreviation() ?? "UTC"
    }
}

// Helper to create transparent sheet background
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Keyboard-aware panel that positions content correctly
struct KeyboardAwarePanel<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardActive = false
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Background overlay with tap to dismiss (excluding content area)
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture {
                    // Only dismiss when tapping outside content
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    dismiss()
                }
            
            // Content positioned based on keyboard
            GeometryReader { geometry in
                VStack {
                    if keyboardActive {
                        // When keyboard is shown, position just above it
                        Spacer()
                        content
                            .padding(.bottom, keyboardHeight + 8)
                    } else {
                        // When keyboard is hidden, center in screen
                        Spacer()
                        content
                        Spacer()
                    }
                }
            }
        }
        .background(KeyboardObserver(keyboardHeight: $keyboardHeight, keyboardActive: $keyboardActive))
        .background(ClearBackgroundView())
    }
}

// Observer for keyboard notifications
struct KeyboardObserver: UIViewRepresentable {
    @Binding var keyboardHeight: CGFloat
    @Binding var keyboardActive: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        
        // Add observer for keyboard notifications
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(keyboardHeight: $keyboardHeight, keyboardActive: $keyboardActive)
    }
    
    class Coordinator: NSObject {
        var keyboardHeight: Binding<CGFloat>
        var keyboardActive: Binding<Bool>
        
        init(keyboardHeight: Binding<CGFloat>, keyboardActive: Binding<Bool>) {
            self.keyboardHeight = keyboardHeight
            self.keyboardActive = keyboardActive
        }
        
        @objc func keyboardWillShow(notification: Notification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight.wrappedValue = keyboardFrame.height
                self.keyboardActive.wrappedValue = true
            }
        }
        
        @objc func keyboardWillHide(notification: Notification) {
            self.keyboardHeight.wrappedValue = 0
            self.keyboardActive.wrappedValue = false
        }
    }
}

#Preview {
    ContentView()
}
