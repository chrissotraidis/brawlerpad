# Release checklist

Use this checklist for a public source update and again before publishing any
macOS or iPhone/iPad binary. A successful compile alone is not a release pass.

## Source release

1. Confirm the intended branch and reviewed paths with `git status -sb` and
   `git diff --check`.
2. Run `scripts/check-repo-safety.sh`. It checks tracked and publishable
   history for game data, generated packages, signing material, oversized
   files, credentials, shell syntax, and Git integrity.
3. Confirm the README, [rights boundary](../RIGHTS_AND_LICENSES.md),
   dependency inventory, build instructions, status evidence, and screenshots
   do not promise an unpublished binary or include sensitive user data.
4. Stage only reviewed paths, commit, push, and verify `HEAD` equals
   `origin/main` after merge.

## macOS binary

1. Build with `scripts/build-macos-app.sh`.
2. Run `scripts/audit-macos-package.sh` on the app and DMG.
3. Verify the target architecture, signature state, package notices, and
   absence of ROMs, archives, saves, credentials, profiles, certificates, and
   personal paths.
4. Launch the final packaged app and exercise the first-run ROM flow with
   local test data that is never added to Git or the release asset.
5. Record the artifact version, SHA-256, signing/notarization state, and any
   remaining platform acceptance boundary in the release notes.

## iPhone and iPad binary

1. Build the generic proof app with `scripts/build-ios-device.sh` and run the
   package audit. The resulting default IPA is intentionally non-runnable.
2. For a real device app, retain `LC_UUID` with:

   ```sh
   BRAWLERPAD_REPRODUCIBLE_DEVICE_LINK=OFF scripts/build-ios-device.sh
   ```

3. Audit the runtime app before adding a local distribution signature outside
   the repository. Never commit a certificate, profile, private key, signed
   IPA, ROM, archive, save, or device log.
4. Install the signed app in place on each intended physical device, launch it,
   and confirm the live process while preserving the existing app container.
5. Perform the intended gameplay acceptance, including touch feel and audio,
   then record the artifact version, SHA-256, signing method, device/OS
   coverage, and known limits accurately.
6. Publish only the reviewed asset and matching release notes. Do not describe
   a developer-preview, local-signed, App Store, TestFlight, or computer-free
   install path as another path.
