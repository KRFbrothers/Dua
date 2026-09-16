# Dua — Test Guide (Android)

Repo: https://github.com/KRFbrothers/Dua  
Target: Android emulator or physical phone (Voice better on real device).

## 0. Fresh install

1. Download ZIP from GitHub → extract (e.g. `Downloads\\Dua-main`).
2. Start Android emulator **or** plug phone (USB debugging ON).
3. Command Prompt:

```bat
cd C:\Users\Hp\Downloads\Dua-main
flutter pub get
flutter devices
flutter run
```

If asked which device, pick the emulator / phone (not Chrome, unless you only want a quick UI peek).

---

## 1. Home

- [ ] App opens dark neon Home
- [ ] Tagline **ALWAYS WITH YOU** visible
- [ ] Orb animates lightly
- [ ] Mic opens **Voice**
- [ ] Red **Offline** opens Offline grid
- [ ] Teal **Online** opens Online (if no network, snackbar “Needs network” is OK)

---

## 2. Offline (Phase 1)

Open **Offline**. Badge should say local / offline.

| Tile | What to check |
|------|----------------|
| Images | Allow photos permission → thumbnails list |
| Videos | Allow → video list |
| Audio | Audio files or empty state |
| Downloads | Downloads folder browse |
| Documents | pdf/txt/doc-style files |
| New files | Recent files |
| Main storage | Folder browser |
| Storage Analysis | Used/free pie (or fallback) |
| Apps | Installed apps list; can launch one |
| Cloud / Remote / Access | “Coming next” stub |

- [ ] Deny permission once → snackbar + no crash
- [ ] Back arrow returns to Home

---

## 3. Online Agent (Phase 2)

1. Open **Online** → tap **gear ⚙️**
2. Paste API key (OpenAI / Groq / OpenRouter)
3. Optional: Base URL + model  
   - OpenAI: `https://api.openai.com/v1` + `gpt-4o-mini`  
   - Groq: `https://api.groq.com/openai/v1` + a Groq model id
4. Save

Checklist:

- [ ] Without key: send message → clear “set API key” style error
- [ ] With key: chat reply comes back (loading indicator first)
- [ ] **Agent** vs **Work** toggle changes tone / empty state
- [ ] Quick actions: Schedule / Translate / Summarize / Write each produce a useful draft
- [ ] Hindi + English both work in one thread
- [ ] Airplane mode → error, no crash

---

## 4. Voice (Phase 3)

Prefer a **real phone** (emulator mic is flaky).

- [ ] Mic permission Allow
- [ ] Tap mic → listening; transcript updates
- [ ] Say: **“Dua, gallery kholo”** → opens Offline Images + spoken confirm
- [ ] Ask a normal question → routes to Online (needs API key) or prompts for key
- [ ] **End** leaves Voice
- [ ] Share / Video / Pulse → “coming soon”
- [ ] Privacy / settings: **on-device STT** toggle works (prefer local recognition)

---

## 5. Privacy & polish (Phase 4)

- [ ] Privacy screen / blurb: Offline stays local; Online uses API key
- [ ] Offline screens never call the LLM
- [ ] Online shows needs-network behavior offline
- [ ] Work vs Agent labels/chips look different
- [ ] Home orb / Online nodes animate

---

## Common fixes

| Problem | Fix |
|---------|-----|
| `flutter` not found | Re-open CMD after PATH; `C:\flutter\bin` |
| No `pubspec.yaml` | `cd` into folder that contains `lib` + `pubspec.yaml` |
| No Android device | Start emulator Play ▶ or USB phone |
| Build fails after ZIP | `flutter pub get` then `flutter create . --platforms=android` |
| Voice silent | Use physical device; check mic permission |
| Agent errors | Check API key, base URL, internet |

---

## Pass criteria (MVP)

App installs and runs on Android; Offline lists real local content with permissions; Online chats with a saved key; Voice routes gallery vs questions; Privacy/STT polish present; no crash on deny/offline.

PRIVATE · OFFLINE · ONLINE · ALWAYS WITH YOU
