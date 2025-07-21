//
//  RootView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct RootView: View {
    @SwiftUI.State private var globalProgress: Double = 0
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .onReceive(TranscriptionManager.shared.progressPublisher) {
            globalProgress = $0
        }
        .overlay(alignment: .top) {
            if globalProgress > 0 && globalProgress < 1 {
                ProgressView(value: globalProgress).progressViewStyle(.linear)
                    .frame(height: 2)
            }
        }
    }
}

#Preview {
    RootView()
}
