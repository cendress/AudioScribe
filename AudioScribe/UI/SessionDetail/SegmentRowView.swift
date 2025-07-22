//
//  SegmentRowView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/22/25.
//

import AVKit
import SwiftUI

struct SegmentRowView: View {
    let segment: Segment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(segment.startedAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                StatusBadge(status: segment.transcription?.status ?? .pending)
            }
            
            Group {
                if let text = segment.transcription?.text, !text.isEmpty {
                    Text(text)
                        .font(.body)
                        .opacity(1)
                } else if segment.transcription?.status == .failed {
                    Text("Audio transcription failed. Please try again.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .opacity(1)
                } else {
                    BouncyDotView()
                        .opacity(1)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: segment.transcription?.status)
        }
        .listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
        .contextMenu {
            ShareLink(item: segment.fileURL) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        
    }
}

#Preview {
    let dummy = Segment(
        startedAt: Date().addingTimeInterval(-60),
        duration: 10,
        fileURL: URL(string: "https://example.com")!,
        transcription: Transcription(text: "Hello World", status: .done)
    )
    
    return List {
        SegmentRowView(
            segment: dummy
        )
    }
}
