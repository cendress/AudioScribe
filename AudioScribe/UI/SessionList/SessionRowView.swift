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
                Text(session.title ?? "Untitled")
                    .font(.headline)
                
                Text(session.createdAt.formatted(.dateTime
                    .month(.abbreviated)
                    .day()
                    .year()
                    .hour()
                    .minute()
                )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: session.aggregateIcon)
                .foregroundStyle(session.aggregateColor)
            
            Image(systemName: "chevron.right")
        }
        .accessibilityLabel("\(session.accessibilityDescription)")
    }
}

#Preview {
    SessionRowView(session: RecordingSession())
}
