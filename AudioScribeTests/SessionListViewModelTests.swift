//
//  SessionListViewModelTests.swift
//  AudioScribeTests
//
//  Created by Christopher Endress on 7/21/25.
//

import Testing
@testable import AudioScribe

@Suite
final class SessionListViewModelTests {
    
    // Helper to make a RecordingSession with a title
    private func makeSession(title: String, segmentsData: [(text: String, status: Transcription.Status)]) -> RecordingSession {
        let segs = segmentsData.map { data -> Segment in
            let seg = Segment()
            let tr = Transcription()
            tr.text = data.text
            tr.status = data.status
            seg.transcription = tr
            return seg
        }
        
        return RecordingSession(title: title, segments: segs)
    }
    
    // Apply the same filter logic but return just titles for easy assertion
    private func filteredTitles(from all: [RecordingSession], searchText: String, filterStatus: Transcription.Status?) -> [String] {
        let out = all.filter { session in
            let matchesText = searchText.isEmpty
            || (session.title?.localizedStandardContains(searchText) ?? false)
            || session.segments.contains {
                $0.transcription?.text.localizedStandardContains(searchText) ?? false
            }
            
            let matchesStatus = filterStatus == nil
            || session.segments.contains {
                $0.transcription?.status == filterStatus
            }
            
            return matchesText && matchesStatus
        }
        
        return out.compactMap { $0.title }
    }
    
    @Test
    func test_noSearch_noStatus_returnsAll() {
        let a = makeSession(title: "First",  segmentsData: [("foo", .done)])
        let b = makeSession(title: "Second", segmentsData: [("bar", .failed)])
        let titles = filteredTitles(from: [a, b], searchText: "", filterStatus: nil)
        #expect(titles == ["First", "Second"])
    }
    
    @Test
    func test_searchText_matchesTitleOnly() {
        let a = makeSession(title: "HelloWorld", segmentsData: [("xxx", .done)])
        let b = makeSession(title: "Goodbye",    segmentsData: [("yyy", .done)])
        let titles = filteredTitles(from: [a, b], searchText: "hello", filterStatus: nil)
        #expect(titles == ["HelloWorld"])
    }
    
    @Test
    func test_searchText_matchesTranscriptionText() {
        let a = makeSession(title: "A", segmentsData: [("find me", .done)])
        let b = makeSession(title: "B", segmentsData: [("nothing", .done)])
        let titles = filteredTitles(from: [a, b], searchText: "find", filterStatus: nil)
        #expect(titles == ["A"])
    }
    
    @Test
    func test_filterStatus_onlyShowsThatStatus() {
        let a = makeSession(title: "ok",   segmentsData: [("x", .done)])
        let b = makeSession(title: "fail", segmentsData: [("x", .failed)])
        let titles = filteredTitles(from: [a, b], searchText: "", filterStatus: .failed)
        #expect(titles == ["fail"])
    }
}
