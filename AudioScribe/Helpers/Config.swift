//
//  Config.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation

enum Config {
    static var openAIToken: String {
        Bundle.main.object(forInfoDictionaryKey: "OpenAIToken") as? String ?? ""
    }
}

