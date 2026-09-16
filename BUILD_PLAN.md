# Dua — Build Plan

**Product:** Private mobile assistant  
**Modes:** Offline (local files) · Online (agent) · Voice  
**Brand:** Dark neon UI · script “Dua” mark · tagline *ALWAYS WITH YOU* · Hindi + English  
**Defaults (pending confirmation):** Flutter · Android-first · Agent chat before Work mode  

---

## Product shape

### One app, two modes

- **Offline** — local-first: files, media, storage tools. Works with no network.
- **Online** — agent chat + quick actions (schedule, translate, summarize, write). Needs connectivity.
- **Voice** — session overlay that can drive either mode (e.g. “gallery kholo”).

### Brand locks from the mock

- Dark base, neon cyan / blue / purple accents
- Script “Dua” logo + tagline *ALWAYS WITH YOU*
- Hindi + English voice and text from day one

### Screens covered

1. **Home** — orb mark, mic, Offline / Online entry
2. **Voice Mode** — waveform, live transcript, call-style controls
3. **Offline** — 12-tile local file / storage grid
4. **Online** — Agent / Work toggle, node graphic, quick actions, Ask Agent input

---

## Phase 0 — Foundations (week 1)

1. **Stack pick** — Flutter (default) or React Native.
2. Theme tokens: colors, type (script logo + sans body), spacing, glow styles.
3. Navigation shell: Home → Offline / Online / Voice; back arrow replaces hamburger on child screens.
4. Permissions scaffold: mic, storage, notifications (request lazily, not on first launch).
5. Local storage layer (SQLite / Hive) for prefs, recent files, offline index.

**Done when:** dark shell runs, Home shows Offline / Online CTAs, theme matches the mock vibe.

---

## Phase 1 — Home + Offline MVP (weeks 2–3)

### Home

- Center orb / waveform mark (static first; animate later)
- Mic shortcut → Voice
- Red **Offline** / teal **Online** entry buttons

### Offline grid (12 tiles)

| Tile | MVP behavior |
|------|----------------|
| Main storage | Device root / media store browser |
| Downloads | Open Downloads folder |
| Storage analysis | Simple used/free pie + top folders |
| Images / Audio / Videos | Filtered media galleries |
| Documents | Docs by MIME |
| Apps | Installed apps list (Android) |
| New files | Recents by date |
| Cloud / Remote / Access from… | Stub screens — “coming next” |

**Done when:** user can browse local images/docs/downloads offline; storage summary works.

---

## Phase 2 — Online Agent MVP (weeks 3–5)

1. Agent / Work toggle (Agent first; Work can be a second chat context or later).
2. Chat UI: “Hello, I’m Dua. Ask me anything.” + Ask Agent input (+ / mic / send).
3. Wire one LLM backend (API key in secure storage; clear “needs network” state).
4. Quick actions as prompts, not separate apps:
   - **Schedule a meeting** → calendar intent / draft
   - **Translate text** → translate flow
   - **Summarize email** → paste or share-sheet in
   - **Write something** → blank compose with tone chips
5. Hindi + English in the same thread.

**Done when:** text chat works online; four quick actions produce useful drafts; graceful offline error if Online is tapped with no net.

---

## Phase 3 — Voice Mode (weeks 5–7)

1. Push-to-talk or open mic session UI (waveform in neon frame).
2. STT (on-device if possible for privacy; cloud fallback when Online).
3. Intent router: gallery / files → Offline; questions / write / schedule → Online agent.
4. Spoken replies (TTS) + live transcript (“Gallery khol rahi hoon…”).
5. Bottom bar: mic, screen share, video, pulse, end — **ship mic + end first**; stub the rest.

**Done when:** “Dua, gallery kholo” opens Images offline; general questions go to agent when Online.

---

## Phase 4 — Privacy & polish (weeks 7–9)

- Explicit Offline vs Online data paths (no accidental cloud upload in offline flows) ✅
- On-device STT preference toggle ✅
- Animated orb / node graph (match Home & Online screens) ✅
- Work mode vs Agent mode distinction ✅
- Cloud / Remote / Access-from tiles (optional sync later) — still stubs / coming next
- Screen share + video call controls only if still desired — still stubs
- Privacy screen + Settings blurb ✅
- Adaptive launcher icon XML ✅

---

## Suggested repo layout

```
dua/
  apps/mobile/          # Flutter or RN
  packages/ui/          # theme, orb, tiles
  packages/offline/     # file index, storage stats
  packages/agent/       # chat, tools, quick actions
  packages/voice/       # STT/TTS, intents
```

---

## Risks to decide early

1. **On-device vs cloud voice** — privacy promise vs accuracy
2. **Android-first vs iOS too** — Apps tile and storage APIs differ hard
3. **Which model/API** for Online agent
4. Whether **Work** is a second agent persona or a task list

---

## Assumptions

- Flutter + Android-first unless overridden
- Agent chat ships before Work mode
- Cloud / Remote / Access-from and advanced voice controls (screen share, video) are post-MVP

---

*Generated from the Dua UI mock (Home · Voice · Offline · Online).*  
*PRIVATE · OFFLINE · ONLINE · ALWAYS WITH YOU*
