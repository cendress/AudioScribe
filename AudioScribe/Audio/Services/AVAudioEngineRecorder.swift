//
//  AVAudioEngineRecorder.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import AVFoundation
import Combine

class AVAudioEngineRecorder: NSObject, AudioRecordingService {
    // Public publisher (broadcasts state changes to the rest of the app)
    private let stateSubject = CurrentValueSubject<State, Never>(.idle)
    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    
    // Whats needed to actually record
    private let sessionManager: AudioSessionManaging
    private let engine = AVAudioEngine()
    var file: AVAudioFile?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionManager: AudioSessionManaging) {
        self.sessionManager = sessionManager
        super.init()
        bindSessionEvents()
    }
    
    // MARK: - AudioRecordingService
    
    func start() throws {
        try sessionManager.activate()
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Recordings", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
        file = try AVAudioFile(forWriting: url, settings: engine.inputNode.outputFormat(forBus: 0).settings)
        
        engine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: engine.inputNode.outputFormat(forBus: 0)) { [weak self] buffer, _ in
            try? self?.file?.write(from: buffer)
        }
        
        try engine.start()
        stateSubject.send(.recording)
    }
    
    func pause() throws {
        engine.pause()
        stateSubject.send(.paused)
    }
    
    func resume() throws {
        try engine.start()
        stateSubject.send(.recording)
    }
    
    func stop() throws {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try sessionManager.deactivate()
        file = nil
        stateSubject.send(.stopped)
    }
}

// MARK: - Observing interruptions / route changes (headphones, phone calls, etc.)

private extension AVAudioEngineRecorder {
    private func bindSessionEvents() {
        sessionManager.interruptionPublisher
            .sink { [weak self] type in
                switch type {
                case .began: try? self?.pause()
                case .ended: try? self?.resume()
                @unknown default: break
                }
            }
            .store(in: &cancellables)
        
        // Only pause on specific route changes
        sessionManager.routeChangePublisher
            .sink { [weak self] reason in
                guard let self = self else { return }
                // Only pause if the old device became unavailable
                if reason == .oldDeviceUnavailable {
                    try? self.pause()
                }
            }
            .store(in: &cancellables)
    }
}
