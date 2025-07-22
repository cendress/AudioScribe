//
//  RootView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct RootView: View {
    @SwiftUI.State private var selection = 0
    
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
        .onChange(of: selection) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

#Preview {
    RootView()
}
