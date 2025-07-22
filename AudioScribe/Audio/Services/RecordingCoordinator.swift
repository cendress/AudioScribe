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
        
        do {
            try context.save()
        } catch {
            print("Failed to save the session.")
        }
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
        
        do {
            try context.save()
        } catch {
            print("Failed to save the segment.")
        }
        
        Task.detached {
            await TranscriptionManager.shared.enqueue(segment: seg)
        }
    }
}
