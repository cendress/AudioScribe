//
//  RecordingCoordinator.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation
import SwiftData

actor RecordingCoordinator {
    private let context: ModelContext
    private(set) var currentSession: RecordingSession
    
    init(context: ModelContext) {
        self.context = context
        let session = RecordingSession()
        currentSession = session
        context.insert(session)
    }
    
    func persistSegment(fileURL: URL, duration: TimeInterval) {
        let seg = Segment()
        seg.fileURL  = fileURL
        seg.duration = duration
        seg.startedAt = Date()
        currentSession.segments.append(seg)
        
        Task.detached {
            await TranscriptionManager.shared.enqueue(segment: seg)
        }
    }
}

