//
//  RootView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct RootView: View {
    @SwiftUI.State private var selection = 0
    @SwiftUI.State private var globalProgress: Double = 0
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack { RecorderView() }
                .tabItem { Label("Record", systemImage: "mic") }
                .tag(0)
            
            NavigationStack { SessionListView() }
                .tabItem { Label("Sessions", systemImage: "list.bullet.rectangle") }
                .tag(1)
        }
        .tint(Color("LightBlueColor"))
        .onReceive(TranscriptionManager.shared.progressPublisher) {
            globalProgress = $0
        }
        .overlay(alignment: .top) {
            if globalProgress > 0 && globalProgress < 1 {
                ProgressView(value: globalProgress).progressViewStyle(.linear)
                    .frame(height: 2)
            }
        }
        .onChange(of: selection) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

#Preview {
    RootView()
}
