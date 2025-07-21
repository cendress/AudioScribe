//
//  Transcription.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation
import SwiftData

@Model final class Transcription {
    @Attribute(.unique) var id = UUID()
    var text: String = ""
    var updatedAt = Date()
    var status: Status = Status.pending
    
    enum Status: Int, Codable, CaseIterable {
        case pending, processing, done, failed
    }
    
    init(
        id: UUID = UUID(),
        text: String = "",
        updatedAt: Date = Date(),
        status: Status = .pending
    ) {
        self.id = id
        self.text = text
        self.updatedAt = updatedAt
        self.status = status
    }
}
