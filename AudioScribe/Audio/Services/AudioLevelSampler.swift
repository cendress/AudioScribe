//
//  AudioLevelSampler.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import Accelerate
import AVFoundation
import Combine

final class AudioLevelSampler: ObservableObject {
    @Published private(set) var rms: Float = 0
    private var cancellables = Set<AnyCancellable>()
    
    init(engine: AVAudioEngine, interval: TimeInterval = 0.05) {
        let node = engine.inputNode
        let fmt = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak self] buf, _ in
            guard let ch = buf.floatChannelData?[0] else { return }
            let frameCount = Int(buf.frameLength)
            
            // Sum of squares
            var sumsq: Float = 0
            vDSP_svesq(ch, 1, &sumsq, vDSP_Length(frameCount))
            
            // Root mean square
            let rawRMS = sqrtf(sumsq / Float(frameCount))
            
            DispatchQueue.main.async {
                // Scale for UI visibility. Cap at 1
                self?.rms = min(rawRMS * 20, 1)
            }
        }
    }
}
