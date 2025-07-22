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
            List {
                // Invisible top‐of‐list anchor
                Color.clear
                    .frame(height: 0)
                    .id(topID)
                
                ForEach(viewModel.displayed) { session in
                    SessionRowView(session: session)
                        .accessibilityElement(children: .combine)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            path.append(session)
                        }
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
            .navigationTitle("Sessions")
            // Search bar
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer)
            .onChange(of: topID) {}
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Filter menu for transcription type
                    Menu {
                        Picker("Status", selection: $viewModel.filterStatus) {
                            Text("Any")
                                .tag(Transcription.Status?.none)
                            
                            ForEach([Transcription.Status.pending,
                                     .done,
                                     .failed], id: \.self) { status in
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
                    
                    // Scroll to the top
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        
                        withAnimation {
                            proxy.scrollTo(topID, anchor: .top)
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
