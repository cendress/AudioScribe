//
//  AudioRecordingService.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Combine
import Foundation

enum State: Equatable {
    case idle
    case recording
    case paused
    case stopped
    case failed(Error)

    // Necessary method to conform to Equatable
    static func ==(leftHandSide: State, rightHandSide: State) -> Bool {
        switch (leftHandSide, rightHandSide) {
            // Comparisons of the same type can happen
        case (.idle, .idle),
             (.recording, .recording),
             (.paused, .paused),
             (.stopped, .stopped):
            return true

            // Both error comparisons are marked as failed regardless of what kind of error it is
        case (.failed, .failed):
            return true

        default:
            return false
        }
    }
}


protocol AudioRecordingService: AnyObject {
    var statePublisher: AnyPublisher<State, Never> { get }
    
    func start() throws
    func pause() throws
    func resume() throws
    func stop() throws
}

