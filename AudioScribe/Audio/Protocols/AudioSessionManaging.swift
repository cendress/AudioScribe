//
//  AudioSessionManaging.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import AVFoundation
import Combine
import Foundation

protocol AudioSessionManaging: AnyObject {
    var interruptionPublisher: AnyPublisher<AVAudioSession.InterruptionType, Never> { get }
    var routeChangePublisher: AnyPublisher<AVAudioSession.RouteChangeReason, Never> { get }
    
    func configure(for category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws
    
    func activate() throws
    func deactivate() throws
}
