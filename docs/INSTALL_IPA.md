# Install the developer-preview IPA

> [!IMPORTANT]
> **Downloads retired.** Prebuilt builds are no longer published, and release
> links on this page no longer work. A build-it-yourself version is in progress.

The BrawlerPad 0.1.0 Preview 2 release (retired)
contains an unsigned, ROM-free arm64 IPA for iOS and iPadOS 17 or later.

1. Download `BrawlerPad-0.1.0-preview.2-unsigned.ipa` from the release page.
2. Check its SHA-256 against the value on that page:

   ```text
   67795d4f8a07641dde7d89102617c328bb3ea3aaa82f365efe544084fd2ea880
   ```

3. Re-sign the IPA with your own Apple identity using a sideloading workflow
   you trust. This project does not provide a signing certificate, provisioning
   profile, or install service.
4. Install the re-signed app, then launch it and choose your legally obtained
   supported US Super Smash Bros. 64 ROM through Files.

The download contains no ROM, extracted game data, save, or signing material.
It retains the runtime UUID needed by iOS and can be installed after local
re-signing, but is not an App Store, TestFlight, or computer-free release.
