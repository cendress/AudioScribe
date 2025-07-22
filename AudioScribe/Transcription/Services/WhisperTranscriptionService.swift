//
//  WhisperTranscriptionService.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation

enum TranscriptionError: Error {
    case missingAPIKey
    case invalidResponse
    case insufficientQuota
}

struct WhisperTranscriptionService: TranscriptionService {
    private let endpoint = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
    private let apiKey: String

    init() throws {
        guard let key = try? KeychainStore.shared.fetch(key: "OPENAI_TOKEN") else {
            throw TranscriptionError.missingAPIKey
        }
        self.apiKey = key
    }

    func transcribe(segment: Segment) async throws -> String {
        // OpenAI response expects raw audio data
        let audioData = try Data(contentsOf: segment.fileURL)

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        func append(_ string: String) {
            body.append(string.data(using: .utf8)!)
        }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
        append("whisper-1\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n")
        append("Content-Type: audio/m4a\r\n\r\n")
        body.append(audioData)
        append("\r\n--\(boundary)--\r\n")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw TranscriptionError.invalidResponse
        }

        if http.statusCode == 429 {
            throw TranscriptionError.insufficientQuota
        } else if http.statusCode != 200 {
            throw TranscriptionError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.text
    }
}
