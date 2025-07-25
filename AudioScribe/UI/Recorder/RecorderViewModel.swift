//
//  RecorderViewModel.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class RecorderViewModel: ObservableObject {
    @Published private(set) var uiState: RecordingUIState = .idle
    @Published var progress: Double = 0
    
    @Published var level: Float = 0 {
        didSet { level = 0.15 * oldValue + 0.85 * level }
    }
    
    // Public state for the view (tells the UI what to display)
    enum RecordingUIState: Equatable {
        case idle
        case recording
        case paused
        case stopping
        case error(String)
    }
    
    // Dependencies
    private let recorder: AudioRecordingService
    private var cancellables = Set<AnyCancellable>()
    private var subs = Set<AnyCancellable>()
    // 25 MB
    private let diskMonitor  = DiskSpaceMonitor(minFreeBytes: 25 * 1_048_576)
    private var levelSampler: AudioLevelSampler?
    
    init(recorder: AudioRecordingService? = nil) {
        self.recorder = recorder ?? DIContainer.shared.audioRecorder
        bind()
        
        TranscriptionManager.shared.progressPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$progress)
        
        if let engineRecorder = self.recorder as? AVAudioEngineRecorder {
            engineRecorder.levelPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: &$level)
        }
    }
    
    func toggleRecord() {
        switch uiState {
        case .idle:
            guard diskMonitor.hasEnoughSpace else {
                uiState = .error("Not enough free space.")
                return
            }
            
            Task { @MainActor in
                await DIContainer.shared.recordingCoordinator.beginSession()
                
                do {
                    try recorder.start()
                } catch {
                    uiState = .error(error.localizedDescription)
                }
            }
            
        case .paused:
            try? recorder.resume()
            
        case .recording:
            try? recorder.pause()
            
        default:
            break
        }
    }
    
    func stop() {
        uiState = .stopping
        try? recorder.stop()
        
        guard
            let fileURL = (recorder as? AVAudioEngineRecorder)?.lastFileURL,
            let duration = (recorder as? AVAudioEngineRecorder)?.lastDuration
        else {
            return
        }
        
        Task {
            await DIContainer.shared.recordingCoordinator.persistSegment(
                fileURL: fileURL,
                duration: duration
            )
        }
    }
}

// MARK: - Extension to store private

private extension RecorderViewModel {
    func bind() {
        recorder.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .idle: uiState = .idle
                case .recording: uiState = .recording
                case .paused: uiState = .paused
                case .stopped: uiState = .idle
                case .failed(let err): uiState = .error(err.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
}
