//
//  DIContainer.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation

@MainActor
struct DIContainer {
    static let shared = DIContainer()
    
    let audioSessionManager: AudioSessionManaging
    let audioRecorder: AudioRecordingService
    let dataController: DataController
    let transcriptionManager: TranscriptionManager
    let recordingCoordinator: RecordingCoordinator
    
    private init() {
        let sessionManager = AudioSessionManager()
        audioSessionManager = sessionManager
        audioRecorder = AVAudioEngineRecorder(sessionManager: sessionManager)
        
        dataController = DataController.shared
        
        let context = dataController.container.mainContext
        recordingCoordinator = RecordingCoordinator(context: context)
        
        transcriptionManager = TranscriptionManager(dataController: dataController)
    }
}
