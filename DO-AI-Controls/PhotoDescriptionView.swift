//
//  PhotoDescriptionView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI
import PhotosUI

struct PhotoDescriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var isGeneratingDescription: Bool = false
    @State private var description: String = ""
    
    // Define accent color
    let accentColor = Color(hex: "44C0FF")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Select a photo to generate a description.")
                        .padding(.horizontal)
                    
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Text("Select Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(accentColor)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .onChange(of: selectedItem) { oldValue, newValue in
                            Task {
                                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = Image(uiImage: uiImage)
                                    // Simulate generating description
                                    isGeneratingDescription = true
                                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                                    description = "A beautiful landscape photo featuring mountains in the background with a serene lake in the foreground. The colors suggest it was taken during golden hour."
                                    isGeneratingDescription = false
                                }
                            }
                        }
                    
                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(Text("Photo will appear here"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    if isGeneratingDescription {
                        ProgressView("Generating description...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if !description.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(accentColor)
                            
                            Text(description)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Photo Description")
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
}

#Preview {
    PhotoDescriptionView()
}