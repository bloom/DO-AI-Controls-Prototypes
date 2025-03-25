//
//  TranscribeAudioView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/25/25.
//

import SwiftUI

struct TranscribeAudioView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRecording: Bool = false
    @State private var isTranscribing: Bool = false
    @State private var transcription: String = ""
    
    // Define accent color
    let accentColor = Color(hex: "44C0FF")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Record audio to generate a text transcription.")
                        .padding(.horizontal)
                    
                    VStack {
                        Button(action: {
                            isRecording.toggle()
                            if !isRecording {
                                // Simulate transcription after stopping recording
                                isTranscribing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    transcription = "This is a simulated transcription of your audio recording. It demonstrates how spoken words would be converted to text."
                                    isTranscribing = false
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(isRecording ? Color.red : accentColor)
                                    .frame(width: 80, height: 80)
                                
                                if isRecording {
                                    Circle()
                                        .stroke(Color.red.opacity(0.5), lineWidth: 2)
                                        .frame(width: 100, height: 100)
                                }
                                
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            }
                        }
                        
                        Text(isRecording ? "Tap to stop recording" : "Tap to start recording")
                            .foregroundColor(isRecording ? .red : .primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    
                    if isTranscribing {
                        ProgressView("Transcribing...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if !transcription.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Transcription")
                                .font(.headline)
                                .foregroundColor(accentColor)
                            
                            Text(transcription)
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
            .navigationTitle("Transcribe Audio")
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
    TranscribeAudioView()
}