//
//  BlinkingDotView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/22/25.
//

import SwiftUI

struct BouncyDotView: View {
    @SwiftUI.State private var isExpanded = false
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .scaleEffect(isExpanded ? 1.0 : 0.8)
            .onAppear {
                // Bounce animation
                withAnimation(
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                ) {
                    isExpanded = true
                }
            }
    }
}

#Preview {
    BouncyDotView()
        .frame(width: 100, height: 100)
}
