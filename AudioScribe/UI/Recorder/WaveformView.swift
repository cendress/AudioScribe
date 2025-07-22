//
//  WaveformView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct WaveformShape: Shape {
    var level: CGFloat
    let barCount: Int

    var animatableData: CGFloat {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / CGFloat(barCount)
        let midY = rect.midY

        for i in 0..<barCount {
            let t = CGFloat(i) / CGFloat(barCount - 1)
            let envelope = sqrt(max(0, 1 - pow(t*2 - 1, 2)))
            let halfBar = envelope * level * midY

            let barRect = CGRect(
                x: CGFloat(i) * step,
                y: midY - halfBar,
                width: step * 0.8,
                height: halfBar * 2
            )

            path.addPath(Capsule().path(in: barRect))
        }
        
        return path
    }
}

struct WaveformView: View {
    // Driven by the recorder
    @Binding var level: Float
    let barCount = 7

    var body: some View {
        WaveformShape(level: CGFloat(level), barCount: barCount)
            .foregroundStyle(Color("LightBlueColor"))
            .animation(.interpolatingSpring(mass: 0.3, stiffness: 120, damping: 15, initialVelocity: 0), value: level)
            .aspectRatio(1, contentMode: .fit)
            .accessibilityHidden(true)
    }
}

#Preview {
    WaveformView(level: .constant(0.7))
        .frame(width: 300, height: 300)
}
