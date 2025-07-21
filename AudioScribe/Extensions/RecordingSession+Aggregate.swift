//
//  RecordingSession+Aggregate.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import Foundation
import SwiftUI

extension RecordingSession {
    // Look at the segments and return the status
    var aggregateStatus: Transcription.Status {
        if segments.contains(where: { $0.transcription?.status == .failed }) {
            return .failed
        } else if segments.contains(where: { $0.transcription?.status == .pending }) {
            return .pending
        } else if segments.contains(where: { $0.transcription?.status == .processing }) {
            return .processing
        } else {
            return .done
        }
    }

    // A little SF Symbol name for that status
    var aggregateIcon: String {
        switch aggregateStatus {
        case .pending: 
            return "hourglass"
        case .processing: 
            return "clock"
        case .done: 
            return "checkmark.circle"
        case .failed: 
            return "xmark.octagon"
        }
    }

    // A color to go with it
    var aggregateColor: Color {
        switch aggregateStatus {
        case .pending:
            return .gray
        case .processing:
            return .orange
        case .done:
            return .green
        case .failed:
            return .red
        }
    }

    var accessibilityDescription: String {
        let titleText = title ?? "Untitled"
        let dateText = createdAt.formatted()
        let count = segments.count
        let status = aggregateStatus.name
        return "\(titleText) recorded on \(dateText), \(count) segments, status \(status)"
    }
}

