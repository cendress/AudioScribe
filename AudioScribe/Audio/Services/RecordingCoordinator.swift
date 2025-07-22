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
    private(set) var currentSession: RecordingSession?
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func beginSession() {
        let session = RecordingSession()
        context.insert(session)
        currentSession = session
    }
    
    func persistSegment(fileURL: URL, duration: TimeInterval) {
        guard let session = currentSession else {
            assertionFailure("persistSegment called before beginSession()")
            return
        }
        
        let seg = Segment()
        seg.fileURL  = fileURL
        seg.duration = duration
        seg.startedAt = Date()
        session.segments.append(seg)
        
        Task.detached {
            await TranscriptionManager.shared.enqueue(segment: seg)
        }
    }
}
