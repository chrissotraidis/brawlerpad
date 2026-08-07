# Rights and licensing boundary

BrawlerPad is an independent, unofficial source-port project. It is not
affiliated with or endorsed by Nintendo, HAL Laboratory, JRickey, Harbour
Masters, libultraship, or the upstream decompilation project.

## Game data and screenshots

This repository does not distribute a Nintendo ROM, extracted original game
asset, audio, model, texture, save, or playable ROM-derived archive. Users
must supply their own legally obtained supported game data locally. Do not
commit, bundle, upload, attach to CI, or request those files.

The README screenshots are captures made with locally supplied game data. They
document the app's operation but are not a source of playable game data; game
names, characters, copyrights, and trademarks remain the property of their
respective owners. BrawlerPad branding itself must remain original and must not
imply official status.

## Source and dependency rights

BattleShip's MIT grant is scoped to its port-owned code and expressly excludes
Nintendo/HAL material and the decompilation tree. The pinned decomp tree has no
explicit license file. Do not describe the entire combined tree as MIT or as
fully open source, and obtain appropriate rights clarification before
commercial distribution or an official-store submission.

BattleShip, libultraship, Torch, SDL, fonts, controller databases, and every
other dependency retain their own licenses and notices. Every distributed
binary must include the actual license texts and notices discovered from its
pinned and fetched dependencies. [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md)
is an engineering inventory, not legal advice and not a substitute for those
texts.

The BrawlerPad integration, scripts, documentation, and original artwork are
publicly readable for this project but do not grant rights to third-party code
or game material. HarkinianPad is referenced as Apple-platform prior work;
that acknowledgement does not relicense HarkinianPad, Shipwright, or any other
third-party project.

## Release packages

The iOS packaging workflow copies this document, the dependency inventory, and
the discovered license/notice files into the package. Its audit rejects every
playable generated archive, including `BrawlerPad.o2r`; the only allowed O2R
is the bounded, entry-validated Fast3D shader archive `f3d.o2r`.

Use the [release checklist](docs/RELEASE_CHECKLIST.md) before publishing source
or a binary.
