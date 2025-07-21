//
//  SessionDetailViewModel.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import Combine
import Foundation
import SwiftData

@MainActor
final class SessionDetailViewModel: ObservableObject {
    @Published private(set) var segments: [Segment] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let sessionID: UUID
    private let context: ModelContext
    
    init(
        session: RecordingSession,
        context: ModelContext? = nil
    ) {
        self.sessionID = session.id
        self.context   = context ?? DataController.shared.container.mainContext
        
        fetchSegments()
        observeSegmentChanges()
    }
    
    private func fetchSegments() {
        // Pull everything sorted by date
        let descriptor = FetchDescriptor<Segment>(
            sortBy: [ SortDescriptor(\.startedAt, order: .forward) ]
        )
        let all = (try? context.fetch(descriptor)) ?? []
        // Then keep only those matching our session
        segments = all.filter { $0.recordingSession?.id == sessionID }
    }
    
    private func observeSegmentChanges() {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextObjectsDidChange)
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchSegments()
            }
            .store(in: &cancellables)
    }
}
