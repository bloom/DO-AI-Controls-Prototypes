//
//  ImageGenerationView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI
import PhotosUI

// Image item model
struct GeneratedImage: Identifiable {
    let id = UUID()
    var isLoading: Bool
    var image: Image?
}

// Using a class for ImageGenerationView to support @objc methods for UIKit callbacks
final class ImageGenerationViewWrapper: NSObject {
    // Singleton instance for UIKit callbacks
    static let shared = ImageGenerationViewWrapper()
    
    // Callback for image saving result
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Handle the result (in a real app, you'd want to show a success or error message)
        if error != nil {
            print("Error saving image: \(String(describing: error))")
            // In a real app: show error alert
        } else {
            print("Image saved successfully")
            // In a real app: show success message
        }
    }
}

struct ImageGenerationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var customPrompt: String = ""
    @State private var isGenerating: Bool = false
    @State private var currentPage: Int = 0
    @State private var selectedStyle: ImageStyle = .none
    @State private var useEntryAsPrompt: Bool = true
    @State private var isSharePresented: Bool = false
    @State private var shareImage: UIImage?
    // Start with just two placeholders:
    // 1. The current/visible one (which will immediately load)
    // 2. The next one (off-screen, ready to be loaded when scrolled to)
    @State private var generatedImages: [GeneratedImage] = [
        GeneratedImage(isLoading: false, image: nil), // Initial placeholder (will load immediately)
        GeneratedImage(isLoading: false, image: nil)  // Next placeholder (off-screen)
    ]
    
    // Define accent color
    let accentColor = Color(hex: "44C0FF")
    
    // Sample styles
    let styles: [ImageStyle] = [
        .none, .painting, .watercolor, .retro, .cartoon, 
        .threeD, .eighties, .minimalist, .sketch, .vintage
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image carousel
                    VStack(spacing: 10) {
                        TabView(selection: $currentPage) {
                            ForEach(Array(generatedImages.enumerated()), id: \.element.id) { index, imageItem in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(width: UIScreen.main.bounds.width * 0.6)
                                    
                                    if imageItem.isLoading {
                                        ProgressView()
                                    } else if let image = imageItem.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.width * 0.6)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .contextMenu {
                                                Button {
                                                    saveImageToPhotoLibrary(index: index)
                                                } label: {
                                                    Label("Save to Photos", systemImage: "photo.on.rectangle")
                                                }
                                                
                                                Button {
                                                    shareImage(index: index)
                                                } label: {
                                                    Label("Share", systemImage: "square.and.arrow.up")
                                                }
                                            }
                                    } else {
                                        Text("Image \(index + 1)")
                                    }
                                }
                                .tag(index)
                                .onAppear {
                                    // Delay the actions slightly to allow animation to complete
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        // Only perform special onAppear actions when this page becomes visible
                                        if index == currentPage {
                                            // 1. Add a new placeholder if this is the last one
                                            checkAndAddNextPlaceholder(currentIndex: index)
                                            
                                            // 2. If this is an empty placeholder, start generating
                                            if index < generatedImages.count && 
                                               !generatedImages[index].isLoading && 
                                               generatedImages[index].image == nil {
                                                generateImage(atIndex: index)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .id(generatedImages.count) // Force TabView to reinitialize when number of items changes
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: UIScreen.main.bounds.width * 0.6)
                        .onChange(of: currentPage) { newIndex in
                            // Delay to allow animation to complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                checkAndAddNextPlaceholder(currentIndex: newIndex)
                            }
                        }
                        
                        // Page indicator dots - simple row with just visible dots
                        HStack(spacing: 8) {
                            ForEach(Array(generatedImages.indices), id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? accentColor : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 5)
                    }
                    
                    // Style picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Style")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(styles, id: \.self) { style in
                                    StyleButton(style: style, isSelected: selectedStyle == style) {
                                        selectedStyle = style
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Entry as prompt toggle
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Use entry as prompt", isOn: $useEntryAsPrompt)
                            .tint(accentColor)
                            .padding(.horizontal)
                    }
                    
                    // Custom prompt field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom prompt")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        TextField("Describe additional details...", text: $customPrompt, axis: .vertical)
                            .lineLimit(3...5)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        // Find the next available placeholder
                        let nextIndex = findNextAvailablePlaceholder()
                        
                        // Set generating state to true to disable button
                        isGenerating = true
                        
                        // Mark it as loading before animation begins to prevent flashing
                        if nextIndex < generatedImages.count && !generatedImages[nextIndex].isLoading {
                            // Pre-set to loading state so the animation is smooth
                            generatedImages[nextIndex].isLoading = true
                        }
                        
                        // Advance to that placeholder with a smooth animation
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentPage = nextIndex
                        }
                        
                        // Complete the generation after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // The actual generation happens in the loading state
                            generateImageContent(atIndex: nextIndex)
                        }
                    }) {
                        Text("Generate Image")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isGenerating ? accentColor.opacity(0.4) : accentColor)
                            .cornerRadius(10)
                    }
                    .disabled(isGenerating)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Image Generation")
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Insert") {
                        // Insert action would go here
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .foregroundColor(accentColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $isSharePresented) {
            if let imageToShare = shareImage {
                ActivityViewController(activityItems: [imageToShare])
            }
        }
        .onAppear {
            // Ensure we have at least two placeholders
            if generatedImages.isEmpty {
                generatedImages.append(contentsOf: [
                    GeneratedImage(isLoading: false, image: nil),
                    GeneratedImage(isLoading: false, image: nil)
                ])
            }
        }
    }
    
    // Helper methods
    private func checkAndAddNextPlaceholder(currentIndex: Int) {
        // Only add a new placeholder if we're at the last available one
        // This ensures only one placeholder exists at a time
        if currentIndex == generatedImages.count - 1 {
            // We're at the last placeholder, add exactly one more
            generatedImages.append(GeneratedImage(isLoading: false, image: nil))
        }
        
        // If we're viewing an empty placeholder (not loading), start generating
        if currentIndex < generatedImages.count && 
           !generatedImages[currentIndex].isLoading && 
           generatedImages[currentIndex].image == nil {
            generateImage(atIndex: currentIndex)
        }
    }
    
    // Find the next available placeholder (empty image slot)
    private func findNextAvailablePlaceholder() -> Int {
        // First look for any existing placeholder
        for (index, image) in generatedImages.enumerated() {
            if image.image == nil && !image.isLoading {
                return index
            }
        }
        
        // If no placeholder exists, return the last index 
        // (which will create a new placeholder via onChange)
        return generatedImages.count - 1
    }
    
    // This method sets the loading state and calls the content generation
    private func generateImage(atIndex index: Int) {
        guard index < generatedImages.count else { return }
        
        // Set the image to loading state
        generatedImages[index].isLoading = true
        isGenerating = true
        
        // Delay the actual generation to allow for smooth animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generateImageContent(atIndex: index)
        }
    }
    
    // This method actually generates the image content
    private func generateImageContent(atIndex index: Int) {
        guard index < generatedImages.count else { return }
        
        // Simulate image generation with random colors 
        // (in a real app, this would call your API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Create a simulated generated image with a random color
            let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
            let randomColor = colors.randomElement() ?? .gray
            
            let uiImage = UIImage.gradientImage(
                bounds: CGRect(x: 0, y: 0, width: 400, height: 400),
                colors: [
                    UIColor(randomColor.opacity(0.7)),
                    UIColor(randomColor)
                ]
            )
            
            if let uiImage = uiImage {
                // Update the image in our array
                generatedImages[index].image = Image(uiImage: uiImage)
                generatedImages[index].isLoading = false
                
                // Re-enable the Generate button with animation
                withAnimation {
                    isGenerating = false
                }
            }
        }
    }
    
    // Save image to photo library
    private func saveImageToPhotoLibrary(index: Int) {
        guard index < generatedImages.count,
              let image = generatedImages[index].image,
              let uiImage = convertImageToUIImage(from: image) else { return }
        
        // Save directly to photo album (iOS will prompt for permission if needed)
        UIImageWriteToSavedPhotosAlbum(uiImage, ImageGenerationViewWrapper.shared, #selector(ImageGenerationViewWrapper.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // Share image
    private func shareImage(index: Int) {
        guard index < generatedImages.count,
              let image = generatedImages[index].image,
              let uiImage = convertImageToUIImage(from: image) else { return }
        
        shareImage = uiImage
        isSharePresented = true
    }
    
    // Helper to convert SwiftUI Image to UIImage
    private func convertImageToUIImage(from image: Image) -> UIImage? {
        // For demo purposes, we will return a simulated image from the currently selected index
        // In a real app, you would need to extract the UIImage from your Image properly
        
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
        let randomColor = colors[currentPage % colors.count]
        
        return UIImage.gradientImage(
            bounds: CGRect(x: 0, y: 0, width: 400, height: 400),
            colors: [
                UIColor(randomColor.opacity(0.7)),
                UIColor(randomColor)
            ]
        )
    }
}

// UIActivityViewController wrapper for SwiftUI
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Style selection button
struct StyleButton: View {
    let style: ImageStyle
    let isSelected: Bool
    let action: () -> Void
    
    // Define accent color
    let accentColor = Color(hex: "44C0FF")
    
    var body: some View {
        Button(action: action) {
            Text(style.displayName)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? accentColor.opacity(0.2) : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? accentColor : .gray)
        }
        .buttonStyle(.plain)
    }
}

// Image style enum
enum ImageStyle: String, CaseIterable, Hashable {
    case none
    case painting
    case watercolor
    case retro
    case cartoon
    case threeD
    case eighties
    case minimalist
    case sketch
    case vintage
    
    var displayName: String {
        switch self {
        case .none: return "No Style"
        case .threeD: return "3D"
        case .eighties: return "80s"
        default: return rawValue.capitalized
        }
    }
}

// Extension to generate gradient images for our simulation
extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}

#Preview {
    ImageGenerationView()
}