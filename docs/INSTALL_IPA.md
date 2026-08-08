# Install the developer-preview IPA

The [BrawlerPad 0.1.0 Preview 1 release](https://github.com/chrissotraidis/brawlerpad/releases/tag/v0.1.0-preview.1)
contains an unsigned, ROM-free arm64 IPA for iOS and iPadOS 17 or later.

1. Download `BrawlerPad-0.1.0-preview.1-unsigned.ipa` from the release page.
2. Check its SHA-256 against the value on that page:

   ```text
   3d8a12803c86ae066e3d33f26e80d4400d9ed9e9cd00191a104e95351f3f936f
   ```

3. Re-sign the IPA with your own Apple identity using a sideloading workflow
   you trust. This project does not provide a signing certificate, provisioning
   profile, or install service.
4. Install the re-signed app, then launch it and choose your legally obtained
   supported US Super Smash Bros. 64 ROM through Files.

The download contains no ROM, extracted game data, save, or signing material.
It is not an App Store, TestFlight, or computer-free installation release.
