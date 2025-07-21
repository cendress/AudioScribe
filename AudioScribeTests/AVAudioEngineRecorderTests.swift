//
//  AVAudioEngineRecorderTests.swift
//  AudioScribeTests
//
//  Created by Christopher Endress on 7/20/25.
//

import Testing
import Combine
import AVFoundation
@testable import AudioScribe

@Suite
struct AVAudioEngineRecorderTests {
  
  @Test
  func pauseAndResume() async throws {
    let recorder = AVAudioEngineRecorder(sessionManager: AudioSessionManager())
    
    // Turn the recorder's publisher into an AsyncSequence
    var iterator = recorder.statePublisher.values.makeAsyncIterator()
    
    // Skip the initial .idle value
    _ = await iterator.next()

    try recorder.start()
    let recordingState =  await iterator.next()
    #expect(recordingState == .recording)
    
    try recorder.pause()
    let pausedState = await iterator.next()
    #expect(pausedState == .paused)
    
    try recorder.resume()
    let resumedState = await iterator.next()
    #expect(resumedState == .recording)
    
    try recorder.stop()
  }
}
