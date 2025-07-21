//
//  SegmentingRecorder.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import AVFoundation
import Combine

final class SegmentingRecorder: AVAudioEngineRecorder {
    private let segmentLength: TimeInterval
    // Used to save metadata to db
    private let coordinator: RecordingCoordinator
    
    private var startDate = Date()
    private var timer: AnyCancellable?
    
    init(sessionManager: AudioSessionManaging,
         coordinator: RecordingCoordinator,
         segmentLength: TimeInterval = 30) {
        self.segmentLength = segmentLength
        self.coordinator   = coordinator
        super.init(sessionManager: sessionManager)
    }
    
    override func start() throws {
        try super.start()
        startDate = Date()
        scheduleTimer()
    }
    override func stop() throws {
        timer?.cancel()
        try super.stop()
    }
    
    // Close current file and start new one
    private func rollFile() {
        guard let oldFile = self.file else { return }
        
        let duration = Date().timeIntervalSince(startDate)
        let path = oldFile.url
        
        // Close & nil the file so parent opens a new one on next buffer
        self.file = nil
        startDate = Date()
        
        // Persist in SwiftData
        Task {
            await coordinator.persistSegment(fileURL: path, duration: duration)
        }
    }
    
    private func scheduleTimer() {
        timer = Timer.publish(every: segmentLength, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.rollFile() }
    }
}
