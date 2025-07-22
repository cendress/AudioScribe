# Data‑Model Design (SwiftData)

## 1  Design Rationale

| Choice | Reason |
|--------|--------|
| **RecordingSession → Segment (1‑to‑many)** | Keeps each audio file small (~30 s) making retries and uploads fast. |
| **Cascade delete** | Removing a session automatically removes its segments—no orphan data. |
| **File‑backed audio** | Audio lives on disk via `fileURL`, not inside the database, so the DB remains tiny even with thousands of segments. |
| **Optional transcription child** | Lets the UI display *BouncyDotView* while work is in progress. |

---

## 2  Performance Notes

* Unique IDs are indexed by SwiftData, giving `O(log n)` lookups.
* List screens page data via `fetchLimit` + `fetchOffset`
  (25 rows per fetch) so memory stays flat.

---

## 3  Migration Strategy

Schema is still **version 0**; future changes will follow this plan:

1. Add‑only fields → handled automatically with default values.  
2. Breaking changes → bump `ModelConfiguration` version and run a
   lightweight migration that keeps audio files untouched
   and rewrites metadata.
