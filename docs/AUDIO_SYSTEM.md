# Audio System Design

AudioScribe’s recording engine is built around **AVAudioEngine**.  
Using the engine (instead of `AVAudioRecorder`) lets us:

* attach multiple taps (for writing audio *and* measuring levels),
* insert DSP nodes later (noise reduction, EQ),
* keep recording while the app is in the background.

---

## 1  Audio‑Session Setup

* **Category:** `.playAndRecord` — supports simultaneous playback/monitoring.  
* **Options:** Bluetooth, AirPlay, and “default‑to‑speaker” for flexibility.  
* **Activation:** handled centrally by **`AudioSessionManager`** so
  view‑models never touch AVFoundation.

---

## 2  Handling Interruptions & Route Changes

| Scenario | What happens internally |
|----------|-------------------------|
| Siri, phone call or alarm starts | `AudioSessionManager` detects an **interruption‑began** notification → publishes an event → **`AVAudioEngineRecorder` pauses**. |
| Interruption ends | A follow‑up **interruption‑ended** event triggers **resume** the UI shows “REC” again automatically. |
| Audio route changes (e.g. AirPods removed) | A **route‑change** notification with reason `oldDeviceUnavailable` causes a pause, user sees a warning banner. |

If recovery fails (for example, the user revokes microphone permission while
recording), the recorder emits `.failed(Error)`; the UI surfaces a readable
error message.

---

## 3  Background Recording

* The project enables **Background Audio** in *Signing & Capabilities*.
* Once the screen locks, **AVAudioEngine** keeps running; iOS displays the red
  “recording” system pill.
* Returning to foreground restores the existing session. No data loss, no
  audible click.

---

## 4  Live Level Meter

A lightweight helper (**`AudioLevelSampler`**) attaches a **second tap** to the
input node. Every ~50 ms it calculates Root‑Mean‑Square (RMS) amplitude with
Apple’s Accelerate framework, normalises it to 0‑1, and publishes the value via
Combine.  
`WaveformView` listens and renders an animated bar graph at 60 fps while using
< 3 % CPU on recent devices.

---

## 5  Edge‑Case Protection

* **Disk space:** before starting, `DiskSpaceMonitor` ensures ≥ 25 MB free.
* **Permission denied / revoked:** failure propagates back as `.error`, halting
  recording gracefully.
* **Storage I/O error:** each write attempt is wrapped in `do–catch`; the UI
  pauses and notifies the user.

---

## 6  Planned Audio Enhancements

| Feature | Status |
|---------|--------|
| Configurable quality presets (sample rate / format) | Back‑logged |
| Noise‑reduction DSP chain | Planned for a later milestone |
| Multi‑input mixing (USB interface + built‑in mic) | In research |
