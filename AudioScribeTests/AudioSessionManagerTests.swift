//
//  AudioSessionManagerTests.swift
//  AudioScribeTests
//
//  Created by Christopher Endress on 7/20/25.
//

import AVFoundation
import Combine
import Testing
@testable import AudioScribe

@Suite
struct AudioSessionManagerTests {
  
    @Test
    func configuresCategoryCorrectly() throws {
        let manager = AudioSessionManager()
        try manager.configure(
          for: .playAndRecord,
          mode: .default,
          options: [.allowBluetooth]
        )
        
        // If no error is thrown, the test passes
    }

    @Test
    func publishesInterruptionEvents() {
        let manager = AudioSessionManager()
        var received: AVAudioSession.InterruptionType? = nil
        // Subscribe to interruption events
        let cancellable = manager.interruptionPublisher
            .sink { received = $0 }

        // Fire a fake “began” interruption
        NotificationCenter.default.post(
          name: AVAudioSession.interruptionNotification,
          object: nil,
          userInfo: [
            AVAudioSessionInterruptionTypeKey:
              AVAudioSession.InterruptionType.began.rawValue
          ]
        )

        // Assert that we saw the “began” event
        #expect(received == .began)

        cancellable.cancel()
    }
}
