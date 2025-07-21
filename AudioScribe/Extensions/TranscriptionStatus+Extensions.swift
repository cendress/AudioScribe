//
//  TranscriptionStatus+Extensions.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import Foundation
import SwiftUI

extension Transcription.Status {
    var name: String {
        String(describing: self).capitalized
    }
}
