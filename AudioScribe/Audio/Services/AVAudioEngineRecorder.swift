//
//  AVAudioEngineRecorder.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Accelerate
import AVFoundation
import Combine

class AVAudioEngineRecorder: NSObject, AudioRecordingService {
    // Public publisher (broadcasts state changes to the rest of the app)
    private let stateSubject = CurrentValueSubject<State, Never>(.idle)
    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    
    private let levelSubject = CurrentValueSubject<Float,Never>(0)
    var levelPublisher: AnyPublisher<Float,Never> { levelSubject.eraseToAnyPublisher() }
    
    // Whats needed to actually record
    private let sessionManager: AudioSessionManaging
    let engine = AVAudioEngine()
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

        // Prepare file
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                     .appendingPathComponent("Recordings", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(UUID().uuidString)
                     .appendingPathExtension("caf")
        let format = engine.inputNode.outputFormat(forBus: 0)
        file = try AVAudioFile(forWriting: url, settings: format.settings)

        engine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self else { return }

            try? self.file?.write(from: buffer)

            if let channel = buffer.floatChannelData?[0] {
                var sumsq: Float = 0
                vDSP_svesq(channel, 1, &sumsq, vDSP_Length(buffer.frameLength))
                let rms = sqrt(sumsq / Float(buffer.frameLength))
                let scaled = min(rms * 10, 1)
                
                DispatchQueue.main.async {
                    self.levelSubject.send(scaled)
                }
            }
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
