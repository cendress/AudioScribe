//
//  BlinkingDotView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/22/25.
//

import SwiftUI

struct BlinkingDotView: View {
    @SwiftUI.State private var visible = false
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(
                    .linear(duration: 0.6)
                    .repeatForever(autoreverses: true)
                ) {
                    visible = true
                }
            }
    }
}

#Preview {
    BlinkingDotView()
}
