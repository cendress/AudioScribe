//
//  SessionDetailView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import AVKit
import SwiftUI

struct SessionDetailView: View {
    @StateObject private var viewModel: SessionDetailViewModel
    private let session: RecordingSession
    
    @SwiftUI.State private var playingItem: PlayItem?
    
    init(session: RecordingSession) {
        self._viewModel = StateObject(wrappedValue: SessionDetailViewModel(session: session))
        self.session = session
    }
    
    var body: some View {
        sessionList
            .navigationTitle(session.title ?? "Session")
            .toolbar {
                Button(action: UIImpactFeedbackGenerator(style: .light).impactOccurred) {
                    EditButton()
                }
            }
            .sheet(item: $playingItem) { item in
                VideoPlayer(player: AVPlayer(url: item.url))
                    .ignoresSafeArea()
            }
    }
    
    private var sessionList: some View {
        List {
            ForEach(viewModel.segments) { segment in
                SegmentRowView(
                    segment: segment,
                    onPlay:   { playingItem = PlayItem(url: segment.fileURL) },
                    onShare:  {
                        let items = [segment.fileURL]
                        let ctrl  = UIActivityViewController(
                            activityItems: items,
                            applicationActivities: nil
                        )
                        
                        UIApplication.shared.topMostController?
                            .present(ctrl, animated: true)
                    }
                )
            }
        }
    }
}

#Preview {
    let dummy = Segment(
        startedAt: Date().addingTimeInterval(-60),
        duration: 10,
        fileURL: URL(string: "https://www.example.com/audio.mp3")!,
        transcription: Transcription(text: "Hello world", status: .done)
    )
    
    let session = RecordingSession(title: "Demo Session", segments: [dummy])
    
    NavigationStack {
        SessionDetailView(session: session)
    }
}

import UIKit

extension UIApplication {
    /// Walks the window hierarchy to find the foremost view controller.
    var topMostController: UIViewController? {
        guard let root = windows.first(where: \.isKeyWindow)?.rootViewController else {
            return nil
        }
        return findTop(from: root)
    }

    private func findTop(from vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController {
            return findTop(from: nav.visibleViewController ?? nav)
        }
        if let tab = vc as? UITabBarController {
            return findTop(from: tab.selectedViewController ?? tab)
        }
        if let presented = vc.presentedViewController {
            return findTop(from: presented)
        }
        return vc
    }
}
