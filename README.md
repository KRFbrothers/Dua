# Dua — Flutter scaffold (Phase 0 + UI shell)

Private mobile assistant for Fareed. Modes: **Offline** · **Online** · **Voice**.

Brand: dark neon (cyan / blue / purple), script **Dua** mark, tagline **ALWAYS WITH YOU**.

This repo is a local Flutter scaffold ready to push to
`https://github.com/KRFbrothers/todo-master` (or a dedicated Dua repo).

## Requirements

- Flutter stable (built against **3.35.4**; newer stable should work)
- Android SDK (Android-first target)
- Optional: iOS toolchain for Mac builds

## Run

```bash
cd app   # or: cd /workspace/dua/app
flutter pub get
flutter run
```

Android emulator / device:

```bash
flutter devices
flutter run -d <deviceId>
```

Analyze:

```bash
flutter analyze
```

## Project structure

```
lib/
  main.dart                 # App entry, Material 3 dark theme
  theme/
    dua_colors.dart         # Neon color tokens
    dua_theme.dart          # ThemeData
  screens/
    home_screen.dart        # Orb, mic → Voice, Offline / Online CTAs, hamburger
    offline_screen.dart     # 12-tile local grid
    online_screen.dart      # Agent|Work toggle, chat stub, quick actions
    voice_screen.dart       # Waveform, Hindi sample transcript, call controls
    stub_detail_screen.dart # Empty / demo detail (incl. Storage Analysis pie)
  widgets/
    dua_logo.dart
    neon_orb.dart
    waveform.dart
    mode_cta_button.dart
    offline_tile.dart
    storage_pie.dart
    agent_node_graphic.dart
BUILD_PLAN.md               # Product build plan (copied into app root)
```

## Navigation

| From | Action | To |
|------|--------|-----|
| Home | Mic / orb | Voice |
| Home | Offline (red) | Offline grid |
| Home | Online (teal) | Online agent |
| Home | Hamburger | Snackbar stub |
| Offline / Online / Voice | Back | Previous |
| Offline tile | Tap | Stub detail (Storage Analysis → demo pie) |
| Voice | Mic | Toggle listening animation |
| Voice | End | Pop back |
| Voice | Share / Video / Pulse | Stub snackbars |
| Online | Quick actions / Ask Agent | Local stub chat bubbles |

## What's stubbed (out of scope for this scaffold)

- Real device file / media / storage APIs
- STT / TTS / on-device voice
- LLM API keys and network agent
- Screen share / video call
- Work mode beyond a second chat context label
- Cloud / Remote / Access-from sync

## Product rules (short)

See also `BUILD_PLAN.md` and parent docs under `/workspace/dua/DUA_*.md`.

- Private + offline-first
- Short Hinglish voice/text
- Agent chat before full Work mode

## Zip

Parent folder ships a zip at `/workspace/dua/dua-flutter-scaffold.zip`
(excludes `build/` and `.dart_tool/` when present).

---

*PRIVATE · OFFLINE · ONLINE · ALWAYS WITH YOU*
