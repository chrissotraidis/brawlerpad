# Architecture

```text
UIKit / SDL application shell (iOS/iPadOS)   AppKit bundle / SDL (macOS)
                 |                                      |
                 +----------- platform services --------+
                              | lifecycle, paths,
                              | ROM import, touch UI
                       brawlerpad_core
                 game loop, resources, audio, saves,
                 normalized SDL controller pipeline
                              |
                       brawlerpad_game
                 AOT-compiled SSB64 decomp code
                              |
             libultraship Fast3D + Metal / Torch data
```

The app is a native source-port integration. It does not emulate an arbitrary
N64 CPU, boot arbitrary ROMs, or bundle original assets. The decompiled game is
compiled ahead of time for arm64. Torch interprets one validated user-supplied
SSB64 ROM as data and emits the resource archive consumed by native code.

## Proven seams

- BattleShip already defines `ssb64_game` separately from the C++ port target.
- BattleShip's Metal backend works on Apple Silicon and its Android target
  already changes the executable into an SDL-loadable shared app library.
- Android Torch runs in-process and writes `BattleShip.o2r` after a user ROM
  selection.
- Android touch creates an SDL virtual controller, leaving LUS mappings intact.
- HarkinianPad demonstrates that SDL's UIKit window can present LUS Metal and
  that mobile lifecycle/audio/frame gating can coexist with the game loop.

## Platform interface

The core must depend on narrow interfaces rather than UIKit/AppKit:

- storage roots and atomic file operations;
- resource/bootstrap state and progress reporting;
- application active/background/termination state;
- render-frame readiness and drawable invalidation;
- audio pause/resume/interruption state;
- normalized controller registration and touch-controller state;
- diagnostics and package metadata.

UIKit/Objective-C++ remains in the Apple shell. Torch, resource factories,
game logic, and normalized input remain C/C++.

## Threading

The native game scheduler uses cooperative AArch64 fibers already proven on
macOS and Android. Calls that may enter UIKit, Objective-C runtime services,
Metal presentation, or SDL platform JNI/UIKit bridges execute on SDL's owning
application thread. Background state closes the frame gate instead of spinning
or submitting to an invalid drawable.

## Storage model

- App bundle: executable and ROM-free, redistributable port resources only.
- Application Support: extracted `BrawlerPad.o2r`, config, saves, controller
  mappings, and touch layouts.
- Documents/import area: user-visible ROM handoff where required.
- Caches: recreatable shader/texture caches.
- Temporary: security-scoped import copies and extraction staging.

No absolute developer path is persisted into configuration or packages.

## Release normalization

The branded macOS package strips object/source symbols, uses deterministic
Objective-C stubs, then derives `LC_UUID` from the final rewritten Mach-O
payload before code signing. The UUID is retained because macOS dyld requires
it. Local ad-hoc signing can vary opaque bytes outside Apple's CodeDirectory,
so reproducibility is established by the normalized unsigned payload, UUID,
CDHash, and per-file bundle manifest rather than raw signature-container bytes.

The unsigned iPhoneOS proof instead omits `LC_UUID`; iOS Simulator retains its
required UUID. Both Apple package paths use the same deterministic renderer
shader archive and strict ROM/save/credential/path audits.
