//
//  DiskSpaceMonitor.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation

struct DiskSpaceMonitor {
    private let minFreeBytes: UInt64
    init(minFreeBytes: UInt64) { self.minFreeBytes = minFreeBytes }
    
    var hasEnoughSpace: Bool {
        let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        if let free = attrs?[.systemFreeSize] as? UInt64 { return free > minFreeBytes }
        return false
    }
}
