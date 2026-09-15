# Dua — Flutter app (Phase 1 Offline)

Private mobile assistant for Fareed. Modes: **Offline** · **Online** · **Voice**.

Brand: dark neon (cyan / blue / purple), script **Dua** mark, tagline **ALWAYS WITH YOU**.

Repo: `https://github.com/KRFbrothers/Dua`

## Requirements

- Flutter stable (built against **3.35.4**; newer stable should work)
- Android SDK (Android-first; no `ios/` folder in this tree)

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

### Packages added

- `permission_handler`
- `photo_manager`
- `path_provider` / `path`
- `open_filex`
- `installed_apps`
- `disk_space_2`

### Android permissions

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
  screens/
    home_screen.dart
    offline_screen.dart  # wires tiles → real screens
    media_gallery_screen.dart
    file_browser_screen.dart
    storage_analysis_screen.dart
    apps_list_screen.dart
    online_screen.dart
    voice_screen.dart
    stub_detail_screen.dart   # Cloud / Remote / Access stubs
  widgets/
BUILD_PLAN.md
```

## Navigation

| From | Action | To |
|------|--------|-----|
| Home | Mic / orb | Voice |
| Home | Offline (red) | Offline grid |
| Home | Online (teal) | Online agent |
| Offline tile | Tap | Real local browser / gallery / apps / analysis (or coming-next stub) |
| Voice | Mic | Toggle listening animation |
| Online | Quick actions / Ask Agent | Local stub chat bubbles |

## Still stubbed (later phases)

- STT / TTS / on-device voice
- LLM API keys and network agent
- Screen share / video call
- Work mode beyond a second chat context label
- Cloud / Remote / Access-from sync

## Product rules (short)

See also `BUILD_PLAN.md`.

- Private + offline-first
- Short Hinglish voice/text
- Agent chat before full Work mode

---

*PRIVATE · OFFLINE · ONLINE · ALWAYS WITH YOU*
