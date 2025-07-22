//
//  SessionListView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftData
import SwiftUI

struct SessionListView: View {
    // Live SwiftData query
    @Query(sort: \RecordingSession.createdAt, order: .reverse)
    private var sessions: [RecordingSession]
    
    @SwiftUI.State private var searchText = ""
    @SwiftUI.State private var filterStatus: Transcription.Status? = nil
    @SwiftUI.State private var navPath = [RecordingSession]()
    @SwiftUI.State private var wasSearching = false
    
    @Namespace private var topID
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollViewReader { proxy in
                Group {
                    if displayed.isEmpty {
                        placeholder
                    } else {
                        List {
                            ForEach(displayed) { session in
                                SessionRowView(session: session)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        navPath.append(session)
                                    }
                                    .id(session.id)
                            }
                        }
                    }
                }
                .navigationTitle("Sessions")
                .navigationDestination(for: RecordingSession.self) { session in
                    SessionDetailView(session: session)
                }
                .searchable(text: $searchText,
                            placement: .navigationBarDrawer)
                .onChange(of: searchText) { _, newValue in
                    // Haptic feedback on search bar
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    if !wasSearching && !newValue.isEmpty { generator.impactOccurred() }
                    if  wasSearching &&  newValue.isEmpty { generator.impactOccurred() }
                    wasSearching = !newValue.isEmpty
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // Filter Picker
                        Menu {
                            Picker("Status", selection: $filterStatus) {
                                Text("Any").tag(Transcription.Status?.none)
                                ForEach([Transcription.Status.done, .failed], id: \.self) { status in
                                    Text(status.name).tag(Transcription.Status?.some(status))
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .accessibilityLabel("Filter transcription status")
                        
                        // Scroll to top button
                        Button {
                            if let firstID = displayed.first?.id {
                                withAnimation {
                                    proxy.scrollTo(firstID, anchor: .top)
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        } label: {
                            Image(systemName: "arrow.up.to.line")
                        }
                        .accessibilityLabel("Scroll to top")
                    }
                }
            }
        }
    }
    
    // MARK: - Filtered results
    
    private var displayed: [RecordingSession] {
        sessions.filter { session in
            let matchesText =
                searchText.isEmpty ||
                (session.title?.localizedStandardContains(searchText) ?? false) ||
                session.segments.contains {
                    $0.transcription?.text
                        .localizedStandardContains(searchText) ?? false
                }
            
            let matchesStatus =
                filterStatus == nil ||
                session.segments.contains { $0.transcription?.status == filterStatus }
            
            return matchesText && matchesStatus
        }
    }
    
    // MARK: - Placeholder view
    
    private var placeholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("Nothing to see here…")
                .font(.title3).bold()
            
            Text("Record an audio session and it’ll show up here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SessionListView()
}

