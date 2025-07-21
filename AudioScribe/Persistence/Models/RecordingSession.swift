//
//  RecordingSession.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation
import SwiftData

@Model final class RecordingSession {
    @Attribute(.unique) var id = UUID()
    var createdAt = Date()
    var title: String?
    @Relationship(deleteRule: .cascade) var segments = [Segment]()
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        title: String? = nil,
        segments: [Segment] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.segments = segments
    }
}
