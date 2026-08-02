# Implementation plan

## Foundation and pinning

Use BattleShip `4e7f1dc9` as the primary game-core foundation, with the exact
decomp, libultraship, and Torch gitlinks listed in `DEPENDENCIES.md`. Keep
upstream trees out of Git and reproduce them through `scripts/clone-sources.sh`.
BrawlerPad-owned changes will live as reviewable patches until the platform
branch is stable enough to choose between a maintained fork and vendored patch
series. HarkinianPad remains a read-only reference.

## Milestone 1: reproduce BattleShip

1. Validate the local ROM against the supported US SHA-1 and MD5.
2. Configure a Release Ninja build on Apple Silicon using upstream defaults.
3. Build Torch, extract `BattleShip.o2r`, and build the native executable.
4. Launch from its build directory and confirm Metal renderer selection.
5. Exercise title/menu, character and stage selection, a complete match,
   results, audio, a physical or mapped controller, save creation, shutdown,
   and persistence after relaunch.
6. Record commands, logs, artifacts, and any upstream baseline defect before
   changing the mobile architecture.

## Milestone 2: mobile-safe core

Refactor the upstream target into three explicit layers:

- `brawlerpad_game`: BattleShip's `ssb64_game` decomp object library and
  N64-compatible game logic.
- `brawlerpad_core`: platform-neutral port bridges, resource factories,
  scheduler/coroutine code, audio mixer, normalized controller input, saves,
  and game loop.
- `BrawlerPad`: a thin platform executable/bundle that supplies lifecycle,
  storage roots, ROM setup, Metal/SDL presentation, and touch UI.

The iOS configuration will hard-disable TinyCC, runtime scripting, funchook,
Discord RPC, self-update, native desktop dialogs, shader-pack downloading,
RenderDoc integration, desktop drag/drop, unsupported dynamic loading, and
desktop-only path assumptions. Compile-time guards must make accidental
re-enablement of scripting or unsigned dynamic code a configuration error.

The existing Android coroutine design is retained initially: game tasks use
the proven AArch64 fiber assembly, while renderer/UI work stays on SDL's real
application thread. HarkinianPad's iOS frame-readiness and lifecycle gates are
the reference for pausing work safely. If a simulator build proves the assembly
unnecessary or incompatible, the fallback is a portable stackful coroutine
library compiled AOT, not JIT or runtime code generation.

## Milestone 3: macOS BrawlerPad app

Create an Apple Silicon `MACOSX_BUNDLE` around `brawlerpad_core`. Use
libultraship's proven SDL + Metal backend and package only ROM-free port assets,
configuration, controller mappings, executable code, and license notices.
Move saves/settings/resources under the application-support root instead of
the launch directory. The app accepts or locates a user ROM on first run,
validates it, invokes Torch, and stores derived data outside the app bundle.

## Milestone 4: iOS and iPadOS app

Generate a native Xcode project with CMake (`-GXcode`,
`CMAKE_SYSTEM_NAME=iOS`) and build one universal iOS target for device families
1 and 2. SDL supplies the `UIApplicationMain` shell and calls an explicit
`SDL_main`; UIKit additions are Objective-C++ source files inside the app
target. The `Info.plist` declares arm64/Metal, landscape orientations, Files
sharing/open-in-place, and extended game-controller support.

Metal presentation uses the existing SDL-created `CAMetalLayer` and
libultraship Metal renderer. The app will avoid desktop fullscreen modes,
multi-window UI, and AppKit-only APIs. iPhone and iPad simulator configurations
use arm64 and separate build directories, and each must install, launch,
initialize Metal, reach the game UI, accept input, log diagnostics, and exit
cleanly.

## ROM import and extraction

Final user flow:

```text
Files document picker / Files-visible inbox
  -> copy security-scoped input to a temporary app-owned file
  -> validate size, internal code, byte order, SHA-1 and MD5
  -> invoke the pinned SSB64 Torch library in-process
  -> atomically publish BattleShip.o2r under Application Support
  -> remove temporary input when safe
  -> mount ROM-free port archives plus the generated archive
  -> launch the game
```

BattleShip Android's `torch_runner` and `RomImporter` are the semantic
reference. HarkinianPad's Files and retry UI are the Apple interaction
reference. Extraction runs off the main thread, reports progress, handles
cancel/failure, and never writes into the read-only app bundle. Development may
use a local generated archive for initial simulator bring-up, but no release or
support claim may depend on it.

## Saves and settings

Introduce a platform storage interface with distinct bundle, caches,
temporary, documents/import, and application-support roots. Generated game
resources, config, touch layouts, and saves use versioned subdirectories under
Application Support. Save writes use a temporary file plus atomic rename where
supported. Background/termination events flush configuration and wait for save
work without blocking UIKit indefinitely. Package/update tests must prove that
Documents/Application Support data survives reinstall-in-place.

## Input and touch controls

Physical controllers continue through SDL/libultraship. Touch controls create
one virtual SDL game controller, matching BattleShip Android's successful
approach, so touch and hardware share normalized N64 mappings and no touch code
enters the simulation.

Adapt the HarkinianPad overlay/editor for the SSB64 control set: analog stick,
A, B, Z, L, R, Start, four C directions or C-stick, and optional D-pad. Support
simultaneous touches, move/resize/hide/reset, safe areas, opacity, separate
phone/tablet profiles, and manual/automatic controller-based visibility.
Cancel all active touches on interruption, backgrounding, controller-mode
changes, and editor transitions.

## Lifecycle and audio

Handle every SDL mobile lifecycle event. On resign/background: pause SDL audio,
clear queued samples, cancel touch state, save config, and stop submitting Metal
frames. On foreground: revalidate the drawable, resume frame submission, and
unpause audio. Route/interruption notifications supplement SDL where needed.
Low-memory handling releases replaceable texture/shader/resource caches.

## Testing and release packaging

Testing follows `TESTING.md`; evidence is recorded in `WORKLOG.md` and summarized
in `STATUS.md`. Simulator coverage always includes one current iPhone and one
current iPad profile. Device-only claims require physical hardware.

Release scripts produce a macOS `.app`, iPhoneOS `.app`, and unsigned IPA,
collect third-party notices, verify Mach-O platform/architecture, and fail if
any package contains a ROM, generated Nintendo asset archive, save, credential,
profile, certificate, private key, personal path, simulator binary, or stale
signature. A clean-checkout build is the final reproducibility gate.

