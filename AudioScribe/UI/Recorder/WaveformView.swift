//
//  WaveformView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct WaveformView: View {
    @Binding var level: Float
    
    var body: some View {
        GeometryReader { geo in
            let midY = geo.size.height / 2
            Canvas { context, size in
                let path = Path { path in
                    let width = size.width
                    // Draw 10 bars
                    let step = width / 10
                    for x in stride(from: 0, to: width, by: step) {
                        // Bar height
                        let barHeight = CGFloat(level) * midY * randomize()
                        
                        let rect = CGRect(
                            x: x,
                            y: midY - barHeight/2,
                            width: step * 0.8,
                            height: barHeight
                        )
                        
                        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 2, height: 2))
                    }
                }
                
                context.fill(path, with: .color(.accentColor))
            }
            .animation(.linear(duration: 0.05), value: level)
        }
        .frame(height: 200)
        .accessibilityHidden(true)
    }
    
    private func randomize() -> CGFloat { .random(in: 0.9...1.1) }
}


#Preview {
    WaveformView(level: .constant(0.5))
}
