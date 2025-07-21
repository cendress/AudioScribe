//
//  DiskSpaceMonitorTests.swift
//  AudioScribeTests
//
//  Created by Christopher Endress on 7/20/25.
//

import Testing
@testable import AudioScribe

@Suite
struct DiskSpaceMonitorTests {
  
  @Test
  func detectsLowSpace() {
      // Impossible threshold (no device holds this amount of space)
    let monitor = DiskSpaceMonitor(minFreeBytes: .max)
    #expect(monitor.hasEnoughSpace == false)
  }
}
