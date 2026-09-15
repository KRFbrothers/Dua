# Dua — Flutter app (Phase 2 Online Agent)

Private mobile assistant for Fareed. Modes: **Offline** · **Online** · **Voice**.

Brand: dark neon (cyan / blue / purple), script **Dua** mark, tagline **ALWAYS WITH YOU**.

Repo: `https://github.com/KRFbrothers/Dua`

## Requirements

- Flutter stable (built against **3.35.4**; newer stable should work)
- Android SDK (Android-first; no `ios/` folder in this tree)
- An OpenAI-compatible API key (OpenAI, Groq, OpenRouter, …) for Online chat

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
```

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

### Android permissions

- `INTERNET` / `ACCESS_NETWORK_STATE` (Online agent)
- `READ_MEDIA_IMAGES` / `VIDEO` / `AUDIO`
- `READ_EXTERNAL_STORAGE` (maxSdk 32)
- `QUERY_ALL_PACKAGES` (Apps tile)
- Package-visibility `<queries>` for launcher + `VIEW`
- **Not** using `MANAGE_EXTERNAL_STORAGE` (scoped storage preferred)

## Project structure

```
lib/
  main.dart
  theme/                 # DuaColors, ThemeData
  offline/               # permissions, media, file browser, apps, storage stats
  agent/                 # LLM client, secure settings, prompts
  screens/
    home_screen.dart
    offline_screen.dart
    media_gallery_screen.dart
    file_browser_screen.dart
    storage_analysis_screen.dart
    apps_list_screen.dart
    online_screen.dart
    agent_settings_screen.dart
    voice_screen.dart
    stub_detail_screen.dart
  widgets/
BUILD_PLAN.md
```

## Navigation

| From | Action | To |
|------|--------|-----|
| Home | Mic / orb | Voice |
| Home | Offline (red) | Offline grid |
| Home | Online (teal) | Online agent (snackbar if offline) |
| Online | Gear | Agent settings (API key / URL / model) |
| Online | Quick actions / Ask Agent | Live LLM chat |
| Offline tile | Tap | Local browser / gallery / apps / analysis (or stub) |
| Voice | Mic | Toggle listening animation |

## Still stubbed (later phases)

- STT / TTS / on-device voice
- Screen share / video call
- Work mode beyond a second chat persona
- Cloud / Remote / Access-from sync
- Attach in Online chat

## Product rules (short)

See also `BUILD_PLAN.md`.

- Private + offline-first
- Short Hinglish voice/text
- Agent chat before full Work mode
- No hardcoded API keys

---

*PRIVATE · OFFLINE · ONLINE · ALWAYS WITH YOU*
