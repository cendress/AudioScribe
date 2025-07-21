//
//  SessionListViewModel.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import Combine
import Foundation
import SwiftData

@MainActor
final class SessionListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filterStatus: Transcription.Status? = nil
    @Published private(set) var displayed: [RecordingSession] = []
    @Published private(set) var isRefreshing = false
    
    // Necessary for pagination mechanic
    private let pageSize = 25
    private var page = 0
    
    // Dependencies
    private let context: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: ModelContext? = nil) {
        self.context = context ?? DataController.shared.container.mainContext
        bindSearch()
        Task { await reload(reset: true) }
    }
    
    // Fetch the next “page” of sessions
    func reload(reset: Bool) async {
        if reset {
            page = 0
            displayed.removeAll()
        }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        // Fetch*all sessions sorted by date (newest first)
        let sort = [ SortDescriptor(\RecordingSession.createdAt, order: .reverse) ]
        let descriptor = FetchDescriptor<RecordingSession>(sortBy: sort)
        
        do {
            let allSessions = try context.fetch(descriptor)
            
            //  Filter by searchText & filterStatus
            let filtered = allSessions.filter { session in
                let matchesText: Bool = searchText.isEmpty
                || (session.title?.localizedStandardContains(searchText) ?? false)
                || session.segments.contains {
                    $0.transcription?.text
                        .localizedStandardContains(searchText) ?? false
                }
                
                let matchesStatus: Bool = filterStatus == nil
                || session.segments.contains {
                    $0.transcription?.status == filterStatus
                }
                
                return matchesText && matchesStatus
            }
            
            // Page out the next slice
            let start = page * pageSize
            let end   = min(start + pageSize, filtered.count)
            if start < end {
                displayed += filtered[start..<end]
                page += 1
            }
        } catch {
            print("SessionList reload failed:", error)
        }
    }
    
    private func bindSearch() {
        Publishers
            .CombineLatest(
                $searchText.removeDuplicates(),
                $filterStatus
            )
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in
                Task { await self?.reload(reset: true) }
            }
            .store(in: &cancellables)
    }
}
