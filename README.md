# Dua — Flutter app (Phase 4 Privacy & polish)

Private mobile assistant for Fareed. Modes: **Offline** · **Online** · **Voice**.

Brand: dark neon (cyan / blue / purple), script **Dua** mark, tagline **ALWAYS WITH YOU**.

Repo: `https://github.com/KRFbrothers/Dua`

## Requirements

- Flutter stable (built against **3.35.4**; newer stable should work)
- Android SDK (Android-first; no `ios/` folder in this tree)
- An OpenAI-compatible API key (OpenAI, Groq, OpenRouter, …) for Online chat / voice agent replies
- **Physical Android device recommended for Voice** (emulator mic often needs host audio passthrough)

## Run

```bash
git clone https://github.com/KRFbrothers/Dua.git
cd Dua
flutter pub get
flutter run
```

Or re-download the ZIP from GitHub → extract → `flutter pub get` → `flutter run`.

Android device / emulator:

```bash
flutter devices
flutter run -d <deviceId>
flutter analyze
flutter test
```


## Phase 4 Privacy & polish

Explicit Offline vs Online data paths, on-device STT preference, Work vs Agent UI, lighter neon animations, adaptive launcher icon XML, privacy blurb.

### Offline vs Online paths

| Path | Network / LLM | UI cue |
|------|----------------|--------|
| **Offline** | Never — local files/media/apps only | `LOCAL ONLY` badge + snackbar |
| **Online** | Required — API key → OpenAI-compatible chat | `NEEDS NETWORK` badge |
| **Voice → Offline intents** | Local navigation only | Gallery / files screens |
| **Voice → Agent** | Online LLM + TTS | Needs API key |

Guards and docs live in `lib/privacy/data_paths.dart`. Offline services are annotated “must never call LLM/network”.

### On-device STT toggle

**Home → menu → Settings** (or Online gear) → **Prefer on-device speech recognition**. Wired into Voice via `SpeechListenOptions.onDevice`. Default **on** (privacy-first); falls back to system recognizer if on-device fails.

### Work vs Agent

Online AppBar toggle:

- **Agent** — general chips (schedule / translate / summarize / write)
- **Work** — productivity chips (agenda / action items / reply / prioritize) + distinct greeting, subtitle, purple accent

System prompts already differed; Phase 4 makes the UI feel distinct.

### Animations

Home `NeonOrb` breathes + spins lightly; Online `AgentNodeGraphic` pulses nodes. Kept to simple `AnimationController`s for performance.

### Launcher / adaptive icon

- Existing `mipmap-*/ic_launcher.png` kept as pre-API-26 fallback
- Added `mipmap-anydpi-v26/ic_launcher.xml` + vector `drawable/ic_launcher_foreground.xml`
- To regenerate full PNG mipmaps locally: `flutter create . --platforms=android` (careful not to overwrite custom manifest) or Android Studio Image Asset Studio

### Privacy screen

Home menu → **Privacy**, or Settings → **Privacy details**. Short blurb: Offline local; API key only for Online; Voice on-device prefer. Cloud/Remote sync and screen share/video remain **coming next** stubs.

### Still stubbed

- Cloud / Remote / Access-from sync
- Screen share / Video / Pulse on Voice
- Attach in Online chat


## Phase 3 Voice Mode

Home mic / orb opens a real voice session (neon waveform + live transcript).

### Features

| Control | Behavior |
|---------|----------|
| **Mic** | Starts / stops on-device-preferring STT (`speech_to_text`) |
| **End** / back | Stops STT + TTS and closes the session |
| Share / Video / Pulse | Snackbar **coming soon** |

Flow:

1. Mic permission requested on first Voice open.
2. Speak (Hinglish OK) → partial + final transcript on screen.
3. **Intent router** (keyword / regex, hi + en):
   - Gallery / photos / images / “gallery kholo” → Offline **Images** gallery
   - Videos → Offline **Videos**
   - Downloads / documents / storage / audio / apps / offline → matching Offline screen
   - Schedule / translate / summarize / write / general questions → **Online agent** path
4. Short TTS confirmation via `flutter_tts` (e.g. “Gallery khol rahi hoon…”).
5. Agent path reuses Phase 2 `LlmClient` + secure settings. No API key → spoken hint + snackbar to open **Online** / **Settings**.

STT prefers **on-device** recognition (`SpeechListenOptions.onDevice`); if the device cannot, it falls back to the system recognizer.

### Emulator caveat

Android emulators often have **no usable microphone** unless you enable host audio / virtual mic in AVD settings. Prefer a **physical device** for Voice Mode testing. If STT fails on emulator, that is expected — Offline / Online still work.

### Packages added (Phase 3)

- `speech_to_text`
- `flutter_tts`
- `permission_handler` (already present; used for mic)

### Android permissions (Voice)

- `RECORD_AUDIO`
- `BLUETOOTH` (maxSdk 30) / `BLUETOOTH_CONNECT` (headset support for speech_to_text)
- `<queries>` for `RecognitionService` and `TTS_SERVICE`

### How to test Voice

1. `flutter run` on a physical Android phone.
2. Allow microphone when prompted.
3. Say **“gallery kholo”** → should TTS confirm and open Images.
4. Say **“open downloads”** → Downloads browser.
5. Say **“translate hello to Hindi”** (with API key in Online Settings) → spoken LLM reply.
6. Without API key → hears key-needed message; snackbar offers Online / Settings.
7. Share / Video / Pulse → “coming soon” snackbar.

## Phase 2 Online Agent

Online is a real LLM chat (not stubs). Keys are **never** hardcoded.

### Setup (API key)

1. Get an API key from a supported provider (below).
2. Open **Online** → tap the **gear** on the AppBar.
3. Paste **API key**, optionally set **Base URL** and **Model**, then **Save**.
4. Chat or use quick actions. Agent | Work toggle switches the system prompt (general vs productivity).

Defaults:

| Setting  | Default |
|----------|---------|
| Base URL | `https://api.openai.com/v1` |
| Model    | `gpt-4o-mini` |

Settings are stored with `flutter_secure_storage` on-device.

### Supported providers (OpenAI-compatible)

| Provider   | Base URL | Example model |
|------------|----------|---------------|
| OpenAI     | `https://api.openai.com/v1` | `gpt-4o-mini` |
| Groq       | `https://api.groq.com/openai/v1` | `llama-3.3-70b-versatile` |
| OpenRouter | `https://openrouter.ai/api/v1` | `openai/gpt-4o-mini` |

Any host that implements `/v1/chat/completions` with a Bearer token should work by changing Base URL + model.

### Behavior

- **Agent** — general assistant (Hinglish OK)
- **Work** — slightly more task/productivity system prompt
- Quick actions inject prompt templates (schedule / translate / summarize / write) then call the LLM
- Missing key → message + snackbar with **Settings**
- No network from Home → snackbar **Needs network** (still opens Online)
- Loading indicator while waiting for a reply

### Packages added (Phase 2)

- `http`
- `flutter_secure_storage`
- `connectivity_plus`

## Phase 1 Offline (local browsing)

Permissions are requested **when you tap a tile**, not when Offline opens. Deny → snackbar with **Settings** hint.

| Tile | Behavior |
|------|----------|
| Images | Device photo library (thumbnails + open) via `photo_manager` |
| Videos | Device videos gallery |
| Audio | Scan common folders for audio extensions |
| Downloads | Browse `Download` / `Downloads` folder |
| Documents | Docs by extension (pdf, txt, doc/docx, …) |
| New files | Recent media/docs (last ~30 days) |
| Main storage | Folder browser from primary external storage |
| Storage Analysis | Used/free via `disk_space_2` (demo fallback) |
| Apps | Launchable installed packages (`installed_apps`) |
| Cloud / Remote / Access from… | Still “coming next” stubs |

### Packages (Phase 1)

- `permission_handler`
- `photo_manager`
- `path_provider` / `path`
- `open_filex`
- `installed_apps`
- `disk_space_2`
- `share_plus` / `image_picker` (Phase 5 Voice)

### Android permissions

- `INTERNET` / `ACCESS_NETWORK_STATE` (Online agent)
- `RECORD_AUDIO` + Bluetooth (Voice)
- `READ_MEDIA_IMAGES` / `VIDEO` / `AUDIO`
- `READ_EXTERNAL_STORAGE` (maxSdk 32)
- `QUERY_ALL_PACKAGES` (Apps tile)
- `CAMERA` (Voice Video capture)
- Package-visibility `<queries>` for launcher + `VIEW` + speech / TTS
- **Not** using `MANAGE_EXTERNAL_STORAGE` (scoped storage preferred)

## Project structure

```
lib/
  main.dart
  theme/                 # DuaColors, ThemeData
  offline/               # permissions, media, file browser, apps, storage stats, remote_prefs
  agent/                 # LLM client, secure settings, prompts, work_board_store
  voice/                 # intent router (Phase 3)
  privacy/               # Offline vs Online data path asserts
  screens/
    home_screen.dart
    offline_screen.dart
    cloud_sources_screen.dart
    remote_access_screen.dart
    access_from_screen.dart
    media_gallery_screen.dart
    file_browser_screen.dart
    storage_analysis_screen.dart
    apps_list_screen.dart
    online_screen.dart
    work_board_screen.dart
    agent_settings_screen.dart
    voice_screen.dart
    privacy_screen.dart
    stub_detail_screen.dart
  widgets/
BUILD_PLAN.md
```

## Navigation

| From | Action | To |
|------|--------|-----|
| Home | Mic / orb | Voice session (STT + router) |
| Home | Offline (red) | Offline grid |
| Home | Online (teal) | Online agent (snackbar if offline) |
| Online | Gear | Agent settings (API key / URL / model) |
| Online | Quick actions / Ask Agent | Live LLM chat |
| Offline tile | Tap | Local browser / gallery / apps / analysis / Cloud·Remote·Access |
| Online Work | List icon | Work board (LOCAL drafts) |
| Voice | Share / Video / Pulse | Transcript share / camera capture / waveform boost |
| Voice | Spoken gallery/files | Offline target screen |
| Voice | Spoken question / write / schedule | Online agent (LLM + TTS) |
| Voice | Mic / End | Listen toggle / leave session |

## Phase 5 (shipped hubs)

- Offline **Cloud / Remote / Access from…** real screens (providers not connected; privacy first)
- Voice **Share** (transcript), **Video** (camera capture), **Pulse** (waveform boost)
- Online Work **Work board** (local JSON CRUD + save-from-chat)

## Still stubbed (later phases)

- Full Drive / Dropbox / OneDrive sync
- Real video call / screen share stream
- Attach in Online chat
- Stronger NLU beyond keyword router

## Product rules (short)

See also `BUILD_PLAN.md`.

- Private + Offline-first
- Short Hinglish voice/text
- Agent chat before full Work mode
- No hardcoded API keys
- Prefer on-device STT when available (Settings toggle)
- Explicit Offline vs Online data paths (no LLM in Offline)

---

*PRIVATE · OFFLINE · ONLINE · ALWAYS WITH YOU*
