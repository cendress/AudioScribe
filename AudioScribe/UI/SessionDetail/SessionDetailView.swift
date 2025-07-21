//
//  SessionDetailView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI
import AVKit

struct SessionDetailView: View {
    @StateObject private var vm: SessionDetailViewModel
    private let session: RecordingSession
    
    @SwiftUI.State private var playingItem: PlayItem?
    
    init(session: RecordingSession) {
        self._vm = StateObject(wrappedValue: SessionDetailViewModel(session: session))
        self.session = session
    }
    
    var body: some View {
        sessionList
            .navigationTitle(session.title ?? "Session")
            .toolbar { EditButton() }
            .sheet(item: $playingItem) { item in
                VideoPlayer(player: AVPlayer(url: item.url))
                    .edgesIgnoringSafeArea(.all)
            }
    }
    
    private var sessionList: some View {
        List {
            ForEach(vm.segments) { seg in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(seg.startedAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        StatusBadge(status: seg.transcription?.status ?? .pending)
                    }
                    
                    if let txt = seg.transcription?.text, !txt.isEmpty {
                        Text(txt)
                            .font(.body)
                    } else {
                        Text("Transcribing…")
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
                .contextMenu {
                    Button("Play Segment") {
                        playingItem = PlayItem(url: seg.fileURL)
                    }
                    ShareLink(item: seg.fileURL) {
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
        case .done:             return "checkmark.circle.fill"
        case .processing, .pending: return "clock.fill"
        case .failed:           return "xmark.octagon.fill"
        }
    }
    
    private var color: Color {
        switch status {
        case .done:             return .green
        case .processing, .pending: return .orange
        case .failed:           return .red
        }
    }
}

#Preview {
    let dummySeg = Segment(
        startedAt: Date().addingTimeInterval(-60),
        duration: 10,
        fileURL: URL(string: "https://www.example.com/audio.mp3")!,
        transcription: Transcription(text: "Hello world", status: .done)
    )
    let session = RecordingSession(title: "Demo Session", segments: [dummySeg])
    NavigationStack {
        SessionDetailView(session: session)
    }
}


