# Architecture

AudioScribe follows **Clean Architecture** and **MVVM** with strict dependency
direction *inward* and *downward*: UI → ViewModels and Domain Protocols → Infrastructure.

## 1. Design Goals
| Goal | Implementation |
|------|----------------|
| **SOLID** | All high-level features depend on *protocols* (`AudioRecordingService`, `AudioSessionManaging`). |
| **Testability** | Engine & session manager are injected and unit tests run without microphone. |
| **Scalability** | SwiftData schema already supports ≥ 1 k sessions / 10 k segments. |
| **Observability** | Combine publishers push audio state & progress to the UI in real time. |

---

## 2. Layer Responsibilities

| Layer | Responsibilities | Depends On |
|-------|------------------|------------|
| **UI** (`UI/…`) | SwiftUI layout, navigation, accessibility | ViewModels |
| **ViewModels** (`…ViewModel.swift`) | Bind UI ⇆ domain, expose Published state | *Protocols* only |
| **Core Protocols** (`Audio/Protocols`, `Transcription/Protocols`) | Definition of capabilities (`AudioRecordingService`, `TranscriptionService`, etc.) | none |
| **Services (Infrastructure)** (`Audio/Services`, `Transcription/Services`) | Concrete AVFoundation recorder, SwiftData fetches | Apple frameworks, Helpers |
| **Helpers & Extensions** | Pure functions, small structs (no side effects) | none |

> **Rule of thumb:** A higher layer never imports a file located higher up the table.

---

## 3. Key Architectural Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| **A‑01** | **AVAudioEngine** over `AVAudioRecorder` | Needed taps for live RMS + future DSP, easier to pause/resume on interruptions. |
| **A‑02** | **SwiftData** over Core Data | Auto Combine publishers → 1‑line list updates, schema still simple enough. |
| **A‑03** | **SegmentingRecorder** writes 30 s chunks | Keeps memory low, enables retryable uploads later. |
| **A‑04** | Dependency Injection via **`DIContainer` single‑ton** | Avoids heavyweight DI frameworks, unit tests can swap mocks with one line. |
| **A‑05** | **WaveformView** uses `Canvas` + Accelerate RMS | 60 fps rendering with ~2–3 % CPU on A15; easy to theme. |

---

## 4. Dependency Injection
A lightweight singleton `DIContainer` wires concrete classes.  
Because everything is protocol-first, swapping mocks for tests is one line.

---

## 5. Data Flow Example (Record → UI)

1. **RecorderView** button calls `RecorderViewModel.toggleRecord()`.
2. ViewModel invokes `AudioRecordingService.start()` (protocol).
3. `AVAudioEngineRecorder` configures `AudioSessionManager`, installs taps, publishes `.recording`.
4. Combine pipeline in ViewModel receives state → sets `uiState = .recording`.
5. **WaveformView** receives RMS values via `levelSampler.$rms` and redraws.

Reverse flow (pause, stop) is symmetrical.

---

## 6. Future Extensions
* Network layer (Whisper STT) plugs via new protocol.
* CloudKit sync layer adds another Infrastructure ring without touching UI.

*Last updated 22 Jul 2025*
