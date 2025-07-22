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
    
    init(session: RecordingSession) {
        self._viewModel = StateObject(wrappedValue: SessionDetailViewModel(session: session))
        self.session = session
    }
    
    var body: some View {
        sessionList
            .navigationTitle(session.title ?? "Session")
    }
    
    private var sessionList: some View {
        List {
            ForEach(viewModel.segments) { segment in
                SegmentRowView(segment: segment)
            }
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
