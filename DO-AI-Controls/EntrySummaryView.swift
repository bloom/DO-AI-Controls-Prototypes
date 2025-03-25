//
//  EntrySummaryView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI

struct EntrySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entryText: String = ""
    @State private var summary: String = ""
    @State private var isGeneratingSummary: Bool = false
    
    // Define accent color
    let accentColor = Color(hex: "44C0FF")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter your journal text below to generate a summary.")
                        .padding(.horizontal)
                    
                    TextField("Type or paste your journal entry here...", text: $entryText, axis: .vertical)
                        .lineLimit(5...10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        isGeneratingSummary = true
                        // Simulate summary generation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            summary = "This is a simulated summary of your journal entry. It captures the key moments and emotions expressed in your writing."
                            isGeneratingSummary = false
                        }
                    }) {
                        Text("Generate Summary")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(accentColor)
                            .cornerRadius(10)
                    }
                    .disabled(entryText.isEmpty || isGeneratingSummary)
                    .padding(.horizontal)
                    
                    if isGeneratingSummary {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Summary")
                                .font(.headline)
                                .foregroundColor(accentColor)
                            
                            Text(summary)
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
}

#Preview {
    EntrySummaryView()
}