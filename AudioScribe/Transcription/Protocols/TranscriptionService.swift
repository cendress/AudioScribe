//
//  TranscriptionService.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation

protocol TranscriptionService {
    func transcribe(segment: Segment) async throws -> String
}
