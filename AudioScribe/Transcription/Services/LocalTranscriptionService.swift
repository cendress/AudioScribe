//
//  LocalTranscriptionService.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Speech

struct LocalTranscriptionService: TranscriptionService {
    func transcribe(segment: Segment) async throws -> String {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        let request = SFSpeechURLRecognitionRequest(url: segment.fileURL)
        let result = try await recognizer.recognitionResult(for: request)
        return result.bestTranscription.formattedString
    }
}


extension SFSpeechRecognizer {
    func recognitionResult(for request: SFSpeechRecognitionRequest) async throws -> SFSpeechRecognitionResult {
        return try await withCheckedThrowingContinuation { continuation in
            // Start the task and keep the returned SFSpeechRecognitionTask alive if you ever want to cancel it manually.
            _ = self.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result, result.isFinal {
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
