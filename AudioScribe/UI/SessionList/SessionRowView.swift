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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session
                      .segments
                      .first?
                      .transcription?
                      .text
                      .trimmingCharacters(in: .whitespacesAndNewlines)
                      ?? "No transcription available"
                )
                .font(.headline)
                .lineLimit(2)
                
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
