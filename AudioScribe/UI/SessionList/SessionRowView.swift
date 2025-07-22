//
//  SessionRowView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct SessionRowView: View {
    let session: RecordingSession
    
    var body: some View {
        HStack {
            Image(systemName: "waveform.circle.fill")
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 8) {
                if let text = session
                    .segments
                    .first?
                    .transcription?
                    .text
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                   !text.isEmpty
                {
                    Text(text)
                        .font(.headline)
                        .lineLimit(2)
                } else if session.segments.first?.transcription?.status == .failed {
                    Text("Audio transcription failed. Please try again.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                } else {
                    BouncyDotView()
                }
                
                Text(session.createdAt.formatted(.dateTime
                    .month(.abbreviated)
                    .day()
                    .year()
                    .hour()
                    .minute()
                ))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .padding(.leading, 16)
        }
        .accessibilityLabel("\(session.accessibilityDescription)")
    }
}

#Preview {
    SessionRowView(session: RecordingSession())
}
