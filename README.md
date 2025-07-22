# AudioScribe 📓🎙️  
iOS voice‑notes recorder built with SwiftUI and SwiftData.  
Runs happily in the background, survives interruptions, and shows a live audio waveform.

<div align="center">
  <img src="docs/assets/hero.gif" width="600" alt="App demo GIF">
</div>

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

## Project Layout (top level)

AudioScribeApp.swift – entry 
RootView.swift – tab container

Audio/ – AVFoundation recorder, session manager

Persistence/ – SwiftData models & container
UI/ – SwiftUI screens and view models

Helpers/ – small utilities (disk monitor, crypto, keychain)

Tests/ – unit & UI tests

docs/ – architecture, audio system, data model, issues

Detailed diagrams live in *docs/ARCHITECTURE.md*.

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

See full list in *docs/KNOWN_ISSUES.md*.

---

## License

MIT © 2025 Christopher Endress
