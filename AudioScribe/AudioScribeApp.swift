//
//  AudioScribeApp.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/19/25.
//

import SwiftData
import SwiftUI

@main
struct AudioScribeApp: App {
    let dataController = DataController.shared
    
    init() {
#if DEBUG
        let defaults = UserDefaults.standard
        // Only run the save block on the very first launch
        if !defaults.bool(forKey: "didSaveOpenAIToken") {
            do {
                try KeychainStore.shared.save(
                    value: Config.openAIToken,
                    key: "OPENAI_TOKEN"
                )
                
                defaults.set(true, forKey: "didSaveOpenAIToken")
            } catch {
                print("Keychain save failed:", error)
            }
        }
#endif
    }
    
    //MARK: - Swift data
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.modelContext, DataController.shared.container.mainContext)
                .preferredColorScheme(.dark)
        }
    }
}
