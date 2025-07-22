//
//  TranscriptionManager.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Combine
import Foundation
import SwiftData

@MainActor
final class TranscriptionManager {
    static let shared = TranscriptionManager(dataController: DataController.shared)
    
    private let remote: TranscriptionService = (try? WhisperTranscriptionService()) ?? LocalTranscriptionService()
    private let local: TranscriptionService = LocalTranscriptionService()
    
    private var consecutiveFailures = 0
    private let queue = OperationQueue()
    private let context: ModelContext
    
    // Track transcription progress
    private let progressSubject = PassthroughSubject<Double, Never>()
    var progressPublisher: AnyPublisher<Double, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    
    init(dataController: DataController) {
        context = dataController.container.mainContext
        queue.maxConcurrentOperationCount = 3
    }
    
    func enqueue(segment: Segment) {
        let segmentID = segment.id

        queue.addOperation { [weak self] in
            guard let manager = self else { return }

            Task { @MainActor in
                let descriptor = FetchDescriptor<Segment>(predicate: #Predicate<Segment> { $0.id == segmentID })
                guard let fresh = try? manager.context.fetch(descriptor).first else {
                    return
                }

                await manager.runTranscription(for: fresh)
            }
        }
    }

    private func runTranscription(for segment: Segment) async {
        do {
            let text = try await transcribeWithRetry(segment: segment)
            try await update(segment: segment, text: text, status: .done)
            consecutiveFailures = 0
        } catch
            let err as TranscriptionError where err == .insufficientQuota {
                // Immediate fallback on quota exceeded
                do {
                    let localText = try await local.transcribe(segment: segment)
                    try await update(segment: segment, text: localText, status: .done)
                } catch {
                    print("Local transcription fallback failed: \(error)")
                    try? await update(segment: segment, text: "", status: .failed)
                }
            } catch {
            consecutiveFailures += 1
            let newStatus: Transcription.Status =
              (consecutiveFailures >= 5) ? .failed : .processing
            try? await update(segment: segment, text: "", status: newStatus)
            
            if consecutiveFailures >= 5 {
                // Schedule a local fallback, only capturing the UUID
                let segmentID = segment.id
                queue.addOperation { [weak self] in
                    guard self != nil else { return }
                    
                    Task { @MainActor in
                        guard let manager = self else { return }
                        let descriptor = FetchDescriptor<Segment>(predicate: #Predicate<Segment> { $0.id == segmentID })
                        
                        guard let fresh = try? manager.context.fetch(descriptor).first else {
                            return
                        }
                        // Use local speech to text
                        try? await manager.localFallback(segment: fresh)
                    }
                }
            }
        }
    }
    
    private func transcribeWithRetry(segment: Segment, attempt: Int = 0, maxAttempts: Int = 5) async throws -> String {
        let service: TranscriptionService = (consecutiveFailures >= 5) ? local : remote
        
        do {
            return try await service.transcribe(segment: segment)
        } catch {
            guard attempt < maxAttempts else { throw error }
            // exponential backoff
            let delayNanos = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
            try? await Task.sleep(nanoseconds: delayNanos)
            return try await transcribeWithRetry(segment: segment, attempt: attempt + 1, maxAttempts: maxAttempts)
        }
    }
    
    private func localFallback(segment: Segment) async throws {
        let text = try await local.transcribe(segment: segment)
        try await update(segment: segment, text: text, status: .done)
    }
    
    private func update(segment: Segment, text: String, status: Transcription.Status) async throws {
        let transcription = segment.transcription ?? Transcription()
        transcription.text = text
        transcription.status = status
        transcription.updatedAt = .now
        segment.transcription = transcription
        
        try context.save()
    }
}
