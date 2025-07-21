//
//  Segment.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation
import SwiftData

@Model final class Segment {
    @Attribute(.unique) var id = UUID()
    var startedAt = Date()
    var duration: TimeInterval = 0
    var fileURL: URL = URL(fileURLWithPath: "")
    var transcription: Transcription?
    
    @Relationship(inverse: \RecordingSession.segments)
    var recordingSession: RecordingSession?
    
    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        duration: TimeInterval = 0,
        fileURL: URL = URL(fileURLWithPath: ""),
        transcription: Transcription? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.duration = duration
        self.fileURL = fileURL
        self.transcription = transcription
    }
}
