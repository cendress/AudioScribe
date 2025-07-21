//
//  DataController.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation
import SwiftData

@MainActor
final class DataController {
    static let shared = DataController()
    
    let container: ModelContainer
    
    private init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        container = try! ModelContainer(for: RecordingSession.self, configurations: config)
    }
}

