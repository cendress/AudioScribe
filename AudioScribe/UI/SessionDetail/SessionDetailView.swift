//
//  SessionDetailView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import AVKit
import SwiftUI

struct SessionDetailView: View {
    @StateObject private var viewModel: SessionDetailViewModel
    private let session: RecordingSession
    
    @SwiftUI.State private var playingItem: PlayItem?
    
    init(session: RecordingSession) {
        self._viewModel = StateObject(wrappedValue: SessionDetailViewModel(session: session))
        self.session = session
    }
    
    var body: some View {
        sessionList
            .navigationTitle(session.title ?? "Session")
            .toolbar {
                Button(action: UIImpactFeedbackGenerator(style: .light).impactOccurred) {
                    EditButton()
                }
            }
            .sheet(item: $playingItem) { item in
                VideoPlayer(player: AVPlayer(url: item.url))
                    .ignoresSafeArea()
            }
    }
    
    private var sessionList: some View {
        List {
            ForEach(viewModel.segments) { segment in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(segment.startedAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        StatusBadge(status: segment.transcription?.status ?? .pending)
                    }
                    
                    if let text = segment.transcription?.text, !text.isEmpty {
                        Text(text)
                    } else {
                        Text("Transcribing…")
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
                .contextMenu {
                    Button("Play Segment") {
                        playingItem = PlayItem(url: segment.fileURL)
                    }
                    
                    ShareLink(item: segment.fileURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

private struct StatusBadge: View {
    let status: Transcription.Status
    
    var body: some View {
        Label(status.name, systemImage: icon)
            .labelStyle(.iconOnly)
            .foregroundStyle(color)
            .accessibilityLabel(status.name)
    }
    
    private var icon: String {
        switch status {
        case .done:             
            return "checkmark.circle.fill"
        case .processing, .pending: 
            return "clock.fill"
        case .failed:           
            return "xmark.octagon.fill"
        }
    }
    
    private var color: Color {
        switch status {
        case .done:
            return .green
        case .processing, .pending:
            return .orange
        case .failed:
            return .red
        }
    }
}

#Preview {
    let dummy = Segment(
        startedAt: Date().addingTimeInterval(-60),
        duration: 10,
        fileURL: URL(string: "https://www.example.com/audio.mp3")!,
        transcription: Transcription(text: "Hello world", status: .done)
    )
    
    let session = RecordingSession(title: "Demo Session", segments: [dummy])
    
    NavigationStack {
        SessionDetailView(session: session)
    }
}
