//
//  StatusBadge.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/22/25.
//

import SwiftUI

struct StatusBadge: View {
    let status: Transcription.Status
    
    var body: some View {
        Label(status.name, systemImage: icon)
            .labelStyle(.iconOnly)
            .foregroundStyle(color)
            .accessibilityLabel(status.name)
    }
    
    private var icon: String {
        switch status {
        case .done:
            return "checkmark.circle.fill"
        case .processing, .pending:
            return "clock.fill"
        case .failed:
            return "xmark.octagon.fill"
        }
    }
    
    private var color: Color {
        switch status {
        case .done:
            return .green
        case .processing, .pending:
            return .orange
        case .failed:
            return .red
        }
    }
}
