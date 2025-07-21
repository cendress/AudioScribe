//
//  RecorderView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import SwiftUI

struct RecorderView: View {
    @StateObject private var viewModel = RecorderViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Text(title(for: viewModel.uiState))
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if viewModel.uiState == .recording {
                ProgressView(value: viewModel.level)
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
            }
            
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.toggleRecord()
                }) {
                    Text("🎙️ Record")
                        .padding()
                        .foregroundStyle(Color.white)
                        .font(.headline)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                if viewModel.uiState == .recording || viewModel.uiState == .paused {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        viewModel.stop()
                    }) {
                        Text("🛑 Stop")
                            .padding()
                            .foregroundStyle(Color.white)
                            .font(.headline)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: .constant(errorText != nil)) {
            Alert(title: Text("Error"), message: Text(errorText ?? ""), dismissButton: .default(Text("OK")))
        }
    }
    
    private var errorText: String? {
        if case .error(let text) = viewModel.uiState { return text } else { return nil }
    }
    
    // Helper methods
    private func title(for state: RecorderViewModel.RecordingUIState) -> String {
        switch state {
        case .idle:   return "Ready"
        case .recording: return "Recording…"
        case .paused: return "Paused"
        case .stopping: return "Stopping…"
        case .error:  return "Error"
        }
    }
}


#Preview {
    RecorderView()
}
