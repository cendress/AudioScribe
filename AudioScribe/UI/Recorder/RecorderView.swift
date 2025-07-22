//
//  RecorderView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import SwiftUI

struct RecorderView: View {
    @StateObject private var viewModel = RecorderViewModel()
    @SwiftUI.State private var showPlaceholder = true
    @SwiftUI.State private var isBlinking = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                WaveformView(level: $viewModel.level)
                    .opacity(viewModel.uiState == .recording ? 1 : 0)
                    .animation(.easeInOut, value: viewModel.uiState)
                
                if showPlaceholder {
                    Text("Tap the record button to begin recording audio")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            
            Spacer()
            
                if viewModel.uiState != .recording {
                    CustomButtonView(imageName: "mic.fill", title: "Record Audio") {
                        withAnimation {
                            viewModel.toggleRecord()
                            showPlaceholder = false
                        }
                    }
                    .transition(.opacity)
                }
                
                if viewModel.uiState == .recording {
                    CustomButtonView(imageName: "stop.fill", title: "Stop") {
                        withAnimation {
                            viewModel.stop()
                        }
                    }
                    .transition(.opacity)
                }
        }
        .padding()
        .alert(isPresented: .constant(errorText != nil)) {
            Alert(title: Text("Error"), message: Text(errorText ?? ""), dismissButton: .default(Text("OK")))
        }
        .overlay(alignment: .topTrailing) {
            if viewModel.uiState == .recording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    // Restart blink each time recording state starts
                        .opacity(isBlinking ? 0 : 1)
                    
                    Text("Rec".uppercased())
                        .font(.subheadline)
                        .bold()
                    
                }
                .padding(10)
                .background(.ultraThinMaterial, in: .capsule)
                .onAppear { isBlinking = true }
            }
        }
        .padding(.horizontal, 16)
        .onChange(of: viewModel.uiState) { oldState, newState in
            if newState == .recording {
                isBlinking = false
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isBlinking = true
                }
            }
            
            if newState == .idle {
                withAnimation {
                    showPlaceholder = true
                }
            }
        }
    }
    
    // Helper methods
    private var errorText: String? {
        if case .error(let text) = viewModel.uiState { return text } else { return nil }
    }
    
    private func title(for state: RecorderViewModel.RecordingUIState) -> String {
        switch state {
        case .idle: return "Ready"
        case .recording: return "Recording…"
        case .paused: return "Paused"
        case .stopping: return "Stopping…"
        case .error: return "Error"
        }
    }
}

#Preview {
    RecorderView()
}
