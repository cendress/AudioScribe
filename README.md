# AudioScribe 📓🎙️  
iOS voice‑notes recorder built with SwiftUI and SwiftData.  
Runs happily in the background, survives interruptions, and shows a live audio waveform.

---

## Feature Highlights 

| Capability |  |
|----|------------|
| One‑tap **Record / Pause / Stop** |  ✔︎
| Auto‑resume after phone calls or Siri |  ✔︎
| Live audio **waveform meter** (RMS) |  ✔︎
| **Session list** with search and infinite scroll |  ✔︎
| **Session detail** screen (per‑segment placeholder) |  ✔︎
| Scalable **SwiftData** store – > 1 k sessions / 10 k segments |  ✔︎
| VoiceOver‑friendly labels |  ✔︎

> Whisper STT, widgets, and iCloud sync are on the roadmap – see *docs/KNOWN_ISSUES.md*.

---

## Screenshots

| Recorder | Session List | Session Detail |
|----------|--------------|----------------|
|  |  |  |

---

## Quick Start

1. Clone the repository  
   `git clone https://github.com/your‑handle/AudioScribe.git`  
   `cd AudioScribe`
2. Open **AudioScribe.xcodeproj** in Xcode 16 or newer.
3. Build & run on a *physical* device (simulator lacks a mic).
4. Grant microphone permission, press **Record**, lock the phone, recording continues in the background.

---

## Architecture  
AudioScribe uses a Clean‑Architecture, **Model‑View‑ViewModel (MVVM)** approach well‑suited to SwiftUI’s data‑binding and Combine‑driven state management.

### Key Components:
- **Model (`RecordingSession`, `Segment`, `Transcription`)**  
  Plain Swift types that represent a recording session, its 30‑second audio chunks, and transcript text. 

- **ViewModel (`RecorderViewModel`, `SessionListViewModel`, `SessionDetailViewModel`)**  
  Act as the intermediaries between views and business logic. Each view‑model publishes UI state (e.g., recording status, waveform level, sessions), processes user intents (record, pause, search), and communicates with services solely through protocols, making them fully mockable for unit testing.

- **View (`RecorderView`, `SessionListView`, `SessionDetailView`)**  
  SwiftUI screens responsible for layout, navigation, and accessibility. They observe their corresponding view‑models (`@StateObject` / `@ObservedObject`) and contain no business logic, keeping the UI layer thin and declarative.

- **Services**  
  Concrete implementations that fulfill the domain protocols while encapsulating heavy tasks.  
  * **Audio Services** – `AVAudioEngineRecorder`, `AudioSessionManager`, `RecordingCoordinator` manage microphone capture, audio‑session interruptions, and on‑the‑fly persistence of new segments.  
  * **Transcription Services** – `TranscriptionManager`, `WhisperTranscriptionService`, `LocalTranscriptionService` will upload 30‑second chunks, retry failed jobs, and fall back to on‑device speech recognition.  
  * **Persistence** – `DataController` sets up and maintains the SwiftData container.

- **Helpers (`DiskSpaceMonitor`, `CryptoHelper`, `KeychainStore`)**  
  Stateless utility types that handle cross‑cutting concerns—free‑space checks, AES encryption, secure token storage—allowing core components to stay focused on a single responsibility.

This structure keeps dependencies flowing in one direction (UI → ViewModel → Protocols → Services), ensuring each layer can evolve or be tested independently without leaking implementation details across boundaries.

---

## Design Notes

* **Clean Architecture** keeps UI, domain protocols, and AVFoundation code separate.
* **Protocols everywhere** – makes audio and data layers mockable for tests.
* **SwiftData and Combine** supply live updates so list UIs stay tiny.
* **Accelerate** powers the waveform with minimal CPU (< 3 % on A15).

---

## Roadmap

* Noise‑reduction DSP and home‑screen widget  
* iCloud / CloudKit sync
* Further tests for full integration

See full list in *docs/KNOWN_ISSUES.md*.

---

## License

MIT © 2025 Christopher Endress
