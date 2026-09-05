<p align="center">
  <img src="assets/readme/200px-Bing_Bong.png" alt="Bing Bong" width="180"/>
</p>

<h1 align="center">Bing Bong</h1>

<p align="center">
  <em>Squeeze the plushie. Get the wisdom. Carry it to the top.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41.6-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.11.4-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Android"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License"/>
</p>

---

A **Magic 8-Ball** style app inspired by the beloved green plushie from [**PEAK**](https://store.steampowered.com/app/3527290/PEAK/), the co-op climbing game by [Aggro Crab](https://aggrocrab.com/) & [Landfall](https://landfall.se/peak).

Tap Bing Bong, hear a random voice line, and let the oracle of BingBong Airways guide your life decisions. Just like in the game, except you don't have to carry him up an entire mountain.

<p align="center">
  <img src="assets/readme/Steam_Wallpaper_09_-_Bing_Bong.jpg" alt="Bing Bong in PEAK" width="600"/>
  <br/>
  <sub>Bing Bong on the island, from the <a href="https://peak.wiki.gg/wiki/Bing_Bong">PEAK Wiki</a></sub>
</p>

## Who is Bing Bong?

In **PEAK**, Bing Bong is the stuffed plushie mascot of **BingBong Airlines**, the airline that crashes you onto a mysterious island. You can find him at the crash site on the Shore and squeeze him to hear a random voice line: a positive, negative, uncertain, or hilariously irrelevant response to whatever question you had in mind.

He weighs 5 points in your inventory. He gives you nothing useful. Players carry him to the summit anyway.

> *"Do not cast Bing Bong aside, it will remember."*

For a brief time after PEAK's launch, the developers at Aggro Crab could actually **possess Bing Bong** and talk to players through him in real-time, jump-scaring climbers across the island. That feature was removed, but the legend remains.

<p align="center">
  <img src="assets/readme/Bing_Bong_Airlines.png" alt="BingBong Airlines" width="280"/>
  <br/>
  <sub>BingBong Airlines, the worst airline, the best mascot</sub>
</p>

## Features

- **26 authentic voice lines**, from *"yeah definitely"* to *"im not comfortable answering that"*
- **Real-time 3D character**: the actual GLB model rendered with the Filament engine via `thermion_flutter`, not a flat sprite
- **Drag to inspect**: orbit him freely to see his back, his feet, any angle; release and he eases back to facing you
- **English / Português**: picked once on first launch. Only the on-screen text is translated, the audio stays in his original English
- **Shuffle-bag randomization**: every line plays before any repeats, and never the same line twice in a row
- **Cartoon physics**: squash and stretch on tap (non-uniform scale), rotational wobble, and buttons that sink into their own shadow instead of shrinking
- **Speech bubble with a tail** that points at the character, so the line is visibly *his*
- **Comic impact star** emitted on every trigger, and flat sun rays that rotate behind him while he talks
- **Hand-drawn ambience**: parallax foliage ridges, flat drifting clouds and fixed-seed paper grain, all painted rather than photographed
- **Loading state with personality**: while the GLB loads you get his silhouette, dashed and breathing, then he pops in with an elastic bounce
- **Immersive fullscreen**, portrait locked, opening from black

## Design

The app follows a **scout field manual** direction, drawn from PEAK's own world: canvas, ink outline, sticker, embroidered patch.

| Decision | Rule |
|----------|------|
| Surfaces | `PatchPanel`: flat fill + 3px ink outline + **hard** offset shadow (`blurRadius: 0`). No `BackdropFilter` anywhere |
| Depth | Three levels only: sticker (4), button (6), floating (8) |
| Colour | Saturated colours are **fills**; text and outline are always ink. That makes contrast structural instead of case-by-case |
| Motion | Nothing fades on its own: it pops, sinks, stretches or stamps. Exits are always faster than entrances |
| Typography | Three faces with rigid roles (below) |

**Contrast is verified, not assumed.** Ink on canvas renders 16.4:1 and ink on lime 13.0:1, both AAA. Lime as *text* on canvas would be 1.2:1, which is why saturated colours are never used for text.

| Role | Face | Where |
|------|------|-------|
| The character's voice | Daruma Drop One | Quotes, the `BING BONG` wordmark, the idle prompt |
| Interface and body | Nunito | Copy, sheet titles, captions |
| Labels and insignia | Archivo | Uppercase button labels, language badges |

All three ship as local TTF assets. The release manifest carries no INTERNET permission, so a network font loader would silently fall back to the system sans; `google_fonts` is deliberately absent. Nunito and Archivo are published upstream as variable fonts only, so the static instances here were produced with `fontTools` (`varLib.instancer` pinning the weight axis, then subset to Latin + Latin-Ext), which keeps them at 64-83 KB each instead of 277 KB and 659 KB.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41.6 / Dart 3.11.4 |
| State management | flutter_riverpod (`StateNotifierProvider`) |
| 3D rendering | thermion_flutter (Filament engine) |
| Audio | audioplayers 6.x (local asset playback) |
| Links | url_launcher (external GitHub link) |
| Architecture | Feature-based clean architecture lite |
| Static analysis | flutter_lints + strict casts/inference/raw-types |

## Architecture

Generic UI primitives live under `core/`; feature-specific composition lives under `features/<name>/presentation/widgets/`.

```
lib/
├── main.dart                                  # Portrait lock + immersive mode
├── app/
│   ├── app.dart                               # ProviderScope + MaterialApp
│   └── app_theme.dart                         # Light theme, TextTheme, font tokens
├── core/
│   ├── constants/audio_constants.dart         # Voice line paths + catchphrase
│   ├── i18n/                                  # AppLocale + PT overrides
│   ├── painting/dashes.dart                   # dashPath(): dashes any Path
│   ├── theme/                                 # Palette, semantic roles, spacing scale
│   └── widgets/
│       ├── badge_button.dart                  # Round insignia button
│       ├── patch_panel.dart                   # THE surface primitive
│       ├── pill_button.dart                   # Labelled action
│       ├── sink_gesture.dart                  # Press physics
│       └── sticker_text.dart                  # Text as a cut-out sticker
├── features/
│   ├── character/
│   │   ├── logic/                             # State, notifier, quote localizer
│   │   └── presentation/
│   │       ├── character_page.dart            # Main composition
│   │       └── widgets/
│   │           ├── about_sheet.dart           # Stitched notebook page
│   │           ├── background.dart            # Gradient + parallax + grain
│   │           ├── bing_bong_model.dart       # Thermion viewport + orbit controller
│   │           ├── bing_bong_widget.dart      # Physics and gesture shell
│   │           ├── model_skeleton.dart        # Dashed silhouette while loading
│   │           ├── pulsing_tap_me.dart        # Idle prompt
│   │           ├── shockwave.dart             # Comic impact star
│   │           ├── speech_bubble.dart         # Body and tail as one Path
│   │           └── sun_rays.dart              # Flat rotating wedges
│   ├── language/presentation/language_overlay.dart
│   └── splash/presentation/splash_page.dart
└── services/
    ├── audio_service.dart                     # Interface the logic layer depends on
    ├── audio_player_service.dart              # audioplayers implementation
    └── audio_randomizer.dart                  # Shuffle-bag algorithm
```

**Data flow.** Tap → `BingBongWidget` fires `ShockwaveController.pulse()` (visual) and `CharacterNotifier.onTap()` (state) → `AudioService.playNext()` → `AudioRandomizer.next()` → the mp3 plays and its asset path comes back as the quote **key** → state becomes talking → `_QuoteArea` resolves that key to text for the chosen locale via `localizeQuote()` and pops the speech bubble in, `SunRays` ramps up, `Background` lifts its warm sun wash → `onPlayerComplete` → state returns to idle. The catchphrase button follows the same path through `playSpecific()`, skipping the randomizer.

**Two decisions worth knowing before you edit.**

`CharacterState` carries only `String? quoteKey`, and `isTalking` is derived from it. There is no way to represent talking without a line, or holding a line while idle.

`AudioService` is an interface. The logic layer never imports `audioplayers`, and `audioServiceProvider` owns the concrete `AudioPlayerService` plus its disposal. That is what lets the notifier be tested with a fake and no plugin binding.

A longer engineering log, including the non-obvious framework constraints this codebase depends on, lives in [CLAUDE.md](CLAUDE.md).

## Getting Started

```bash
git clone https://github.com/azevedo1z/bingbong.git
cd bingbong

flutter pub get
flutter run                  # Run on a connected device
flutter build apk            # Release APK
```

Voice line `.mp3` files are **not** included in this repository (see [Voice Lines](#voice-lines)), so a fresh clone runs with the character and the UI but silent.

## Development

```bash
flutter analyze              # Expected: zero issues
dart format lib test         # Expected: zero changed files
flutter test                 # See the Windows note below
```

Static analysis is stricter than the Flutter default: `strict-casts`, `strict-inference` and `strict-raw-types` are on, plus rules like `directives_ordering`, `unawaited_futures` and `require_trailing_commas`. Both commands above are expected to come back clean before a commit.

The code carries **no comments by design**. Anything that cannot be derived by reading it, mostly framework constraints that bite silently, is recorded in [CLAUDE.md](CLAUDE.md) instead.

### Tests

Tests mirror `lib/` under `test/`, the Dart convention, and every file carries the `_test.dart` suffix the runner discovers:

```
test/
├── features/character/logic/
│   ├── character_notifier_test.dart           # Fake AudioService, no plugin needed
│   └── quote_localizer_test.dart              # Filename → quote, PT overrides
└── services/
    └── audio_randomizer_test.dart             # Shuffle-bag invariants
```

> **Running tests on Windows requires a host C toolchain.** `thermion_dart` ships a
> `hook/build.dart` that compiles C for the *host* on every `flutter test`, so without the
> Visual Studio **"Desktop development with C++"** workload the run fails with
> `No compiler configured on host 'windows_x64'` before a single test executes. Install
> that workload, or run the suite on Linux/macOS where a C compiler is already present.
> This is an environment prerequisite, not a defect in the test code.

## Voice Lines

Voice line `.mp3` files are not included in this repository. To run the app with audio, place the 26 `.mp3` files in `assets/audio/`. Filenames become the displayed **English** quote text: underscores render as apostrophes and a trailing underscore becomes a question mark (`please don_t.mp3` → `please don't`, `if i say yes will you take me with you_.mp3` → `if i say yes will you take me with you?`).

Portuguese is a thin override layer in `core/i18n/quote_translations.dart` (asset path → PT text). Lines with no entry, such as the interjections `nahhh` and `uhhhhhh`, fall back to the English base. The audio is never translated, only the on-screen text.

## About PEAK

**PEAK** is a co-op climbing game where the slightest mistake can spell your doom. Solo or as a group of up to four lost nature scouts, your only hope of rescue from a mysterious island is to scale the mountain at its center. The terrain changes every 24 hours. Over **11 million copies sold** on Steam with **Overwhelmingly Positive** reviews (95%).

Developed by **Team PEAK**, a collaboration between [Aggro Crab](https://aggrocrab.com/) (*Another Crab's Treasure*) and [Landfall](https://landfall.se/) (*Content Warning*).

## Credits

- **3D model** of Bing Bong by [**OFFDucky3D**](https://skfb.ly/pATH7) on Sketchfab.
- **Daruma Drop One**, **Nunito** and **Archivo** are open source fonts from Google Fonts.

---

<p align="center">
  <sub>This is a fan project. Bing Bong, PEAK, and all related assets belong to Aggro Crab and Landfall Games.</sub>
  <br/>
  <sub>Made with Flutter and an unreasonable attachment to a green plushie.</sub>
</p>
