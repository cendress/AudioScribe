# Known Issues & Planned Improvements

| Area | Current Limitation | Planned Fix |
|------|-------------------|-------------|
| **Permissions UX** | The microphone permission alert uses Apple’s default text. | Provide a localised, user‑friendly rationale explaining why audio access is needed. |
| **Storage management** | Recordings remain forever, no automatic clean‑up. | Add a settings toggle to auto‑purge recordings older than N days or when disk space < 500 MB. |
| **Waveform performance** | Continuous 60 fps waveform on sessions longer than 1 hour can reach ~10 % CPU on older devices. | After 5 minutes of continuous recording, throttle RMS sampling to 10 Hz. |
| **Transcription pipeline** | Backend STT, retry logic, and offline fallback are not yet implemented (road‑mapped for Step 5). | Integrate Whisper API with exponential back‑off; fall back to Apple Speech after 5 failures. |
| **Error visibility** | Some errors (e.g. storage I/O) surface only in debug logs. | Add a non‑intrusive in‑app banner that describes the failure in plain language. |
| **Unit coverage** | UI interruption scenarios (e.g. incoming call) are not exercised in UITests. | Use XCUITest’s interruption monitors to simulate a call and verify auto‑resume. |
| **Accessibility** | Custom buttons in RecorderView lack VoiceOver rotor actions. | Add `.accessibilityAction` for “pause”, “resume”, and “stop”. |

---

*Last updated 22 Jul 2025*
