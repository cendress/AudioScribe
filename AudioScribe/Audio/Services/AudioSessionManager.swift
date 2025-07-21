//
//  AudioSessionManager.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import AVFoundation
import Combine

// High level service class that manages audio interruptions
final class AudioSessionManager: AudioSessionManaging {
    private let audioSession = AVAudioSession.sharedInstance()
    private let interruptionSubject = PassthroughSubject<AVAudioSession.InterruptionType, Never>()
    private let routeChangeSubject = PassthroughSubject<AVAudioSession.RouteChangeReason, Never>()
    private var notifTokens = [AnyCancellable]()
    
    init() {
        observeNotifications()
    }
    
    deinit { notifTokens.forEach { $0.cancel() } }
    
    // MARK: - AudioSessionManaging
    
    var interruptionPublisher: AnyPublisher<AVAudioSession.InterruptionType, Never> {
        interruptionSubject.eraseToAnyPublisher()
    }
    
    var routeChangePublisher: AnyPublisher<AVAudioSession.RouteChangeReason, Never> {
        routeChangeSubject.eraseToAnyPublisher()
    }
    
    func configure(for category: AVAudioSession.Category = .playAndRecord, mode: AVAudioSession.Mode = .default, options: AVAudioSession.CategoryOptions = [.allowBluetooth, .defaultToSpeaker, .allowAirPlay]) throws {
        try audioSession.setCategory(category, mode: mode, options: options)
    }
    
    func activate() throws { try audioSession.setActive(true,  options: .notifyOthersOnDeactivation) }
    func deactivate() throws { try audioSession.setActive(false, options: .notifyOthersOnDeactivation) }
}

// MARK: - Private

// Subscribes to potential interruptions
private extension AudioSessionManager {
    func observeNotifications() {
        let center = NotificationCenter.default
        
        center.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] note in
                guard let userInfo = note.userInfo, let typeRaw = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt, let type = AVAudioSession.InterruptionType(rawValue: typeRaw) else { return }
                self?.interruptionSubject.send(type)
            }
            .store(in: &notifTokens)
        
        center.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] note in
                guard let userInfo = note.userInfo, let rRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt, let reason = AVAudioSession.RouteChangeReason(rawValue: rRaw) else { return }
                self?.routeChangeSubject.send(reason)
            }
            .store(in: &notifTokens)
    }
}
