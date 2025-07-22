//
//  SessionListView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/21/25.
//

import SwiftUI

struct SessionListView: View {
    @StateObject private var viewModel = SessionListViewModel()
    @SwiftUI.State private var path = [RecordingSession]()
    @Namespace private var topID
    @SwiftUI.State private var wasSearching = false
    @SwiftUI.State private var searchTextBackup = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            sessionList
                .refreshable {
                    await viewModel.reload(reset: true)
                }
                .navigationDestination(for: RecordingSession.self) { session in
                    SessionDetailView(session: session)
                }
        }
    }
    
    // Separated view body for the compiler
    private var sessionList: some View {
        ScrollViewReader { proxy in
            Group {
                if viewModel.displayed.isEmpty {
                    // Placeholder when there are no sessions
                    VStack(spacing: 8) {
                        Image(systemName: "waveform.circle")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("Nothing to see here…")
                            .font(.title3)
                            .bold()
                        
                        Text("Record an audio session and it’ll show up here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.displayed) { session in
                            SessionRowView(session: session)
                                .accessibilityElement(children: .combine)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    path.append(session)
                                }
                                .id(session.id)
                            // Technique allows for infinite scrolling
                                .onAppear {
                                    if session == viewModel.displayed.last {
                                        Task { await viewModel.reload(reset: false) }
                                    }
                                }
                        }
                        
                        // Spinner at bottom
                        if viewModel.isRefreshing {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Sessions")
            // Search bar
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer)
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                // User just tapped into the search bar
                if !wasSearching && !newValue.isEmpty {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                // User just cancelled
                if wasSearching && newValue.isEmpty {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
                wasSearching = !newValue.isEmpty
            }
            .refreshable {
                await viewModel.reload(reset: true)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Filter menu for transcription type
                    Menu {
                        Picker("Status", selection: $viewModel.filterStatus) {
                            Text("Any")
                                .tag(Transcription.Status?.none)
                            
                            ForEach([Transcription.Status.done, .failed], id: \.self) { status in
                                Text(status.name)
                                    .tag(Transcription.Status?.some(status))
                            }
                        }
                        .onChange(of: viewModel.filterStatus) {
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filter transcription status")
                    
                    // Scroll to the top
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if let firstID = viewModel.displayed.first?.id {
                            withAnimation {
                                proxy.scrollTo(firstID, anchor: .top)
                            }
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

#Preview {
    SessionListView()
}
