//
//  WaveformView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct WaveformView: View {
    @Binding var level: Float
    let barCount: Int = 7
    
    var body: some View {
        GeometryReader { geo in
            let width  = geo.size.width
            let height = geo.size.height
            let midY = height / 2
            let step = width / CGFloat(barCount)
            
            // Draw everything in a canvas then clip to circle
            Canvas { context, size in
                for i in 0..<barCount {
                    let t = CGFloat(i) / CGFloat(barCount - 1)
                    let xNorm = (t - 0.5) * 2
                    let envelope = sqrt(max(0, 1 - xNorm*xNorm))
                    let wobble = CGFloat.random(in: 0.9...1.1)
                    let halfBar = envelope * CGFloat(level) * midY * wobble
                    
                    // Vertical centered rectangle
                    let rect = CGRect(
                        x: CGFloat(i) * step,
                        y: midY - halfBar,
                        width: step * 0.8,
                        height: halfBar * 2
                    )
                    
                    let radius = rect.width / 1
                    var path = Path()
                    path.addRoundedRect(
                        in: rect,
                        cornerSize: CGSize(width: radius, height: step * 0.3)
                    )
                    
                    context.fill(path, with: .color(.accentColor))
                }
            }
            .animation(.linear(duration: 0.05), value: level)
            .clipShape(.circle)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview {
    WaveformView(level: .constant(0.7))
        .frame(width: 300, height: 300)
}
