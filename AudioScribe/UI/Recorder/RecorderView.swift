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
        VStack(spacing: 24) {
            WaveformView(level: $viewModel.level)
                .opacity(viewModel.uiState == .recording ? 1 : 0)
                .animation(.easeInOut, value: viewModel.uiState)
            
            if showPlaceholder {
                Text("Tap the record button to begin recording audio + transcription")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Text(title(for: viewModel.uiState))
                .font(.largeTitle)
                .fontWeight(.bold)

            ProgressView(value: viewModel.level)
                .progressViewStyle(.linear)
                .padding(.horizontal)
                .animation(.linear(duration: 0.2), value: viewModel.level)
                .opacity(viewModel.uiState == .recording ? 1 : 0)

            HStack {
                if viewModel.uiState != .recording {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            viewModel.toggleRecord()
                            showPlaceholder = false
                        }
                    }) {
                        Text("🎙️ Record")
                            .padding()
                            .foregroundStyle(Color.white)
                            .font(.headline)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .transition(.opacity)
                }

                if viewModel.uiState == .recording {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            viewModel.stop()
                        }
                    }) {
                        Text("🛑 Stop")
                            .padding()
                            .foregroundStyle(Color.white)
                            .font(.headline)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .transition(.opacity)
                }
            }
        }
        .padding()
        .alert(isPresented: .constant(errorText != nil)) {
            Alert(title: Text("Error"), message: Text(errorText ?? ""), dismissButton: .default(Text("OK")))
        }
        .overlay(alignment: .topLeading) {
            if viewModel.uiState == .recording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .opacity(isBlinking ? 0 : 1)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isBlinking)
                    
                    Text("Recording")
                        .font(.subheadline)
                        .bold()
                }
                .padding(10)
                .background(.ultraThinMaterial, in: Capsule())
                .onAppear {
                    isBlinking = true
                }
            }
        }
    }

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
