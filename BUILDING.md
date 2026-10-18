# Identified release build inputs

## 1.2.2-1 metadata packaging

The published 1.2.2-1 package was not compiled. Its control archive changes only
the Version field from 1.2.1+0chium.1 to 1.2.2-1; the complete accepted data
archive and other Debian archive members are reused verbatim. All installed
file bytes, signatures and metadata therefore remain unchanged. The packaged
attribution heading retains the payload's original version intentionally.
Debian dpkg 1.22.6 confirmed that the new version is strictly newer.

The commands and toolchain below describe the original accepted payload build,
not a new 1.2.2-1 compilation. Recompiling is not the metadata-only release recipe.

## Original 1.2.1+0chium.1 payload build

The release was prepared from Windows using a GitHub-hosted **macos-15** job.
Commands below run on that macOS builder, not on Windows. No local Mac or
device-derived build helper is required. This source snapshot includes the
buildable source and assets; it excludes private repository history, research,
device connection material and private CI logs.

Inputs used:

- Xcode 16.4 / 16F6 at /Applications/Xcode_16.4.app/Contents/Developer;
  Apple clang 17.0.0 / clang-1700.0.13.5 and its linker.
- Theos commit `304e0799973e8145f32e4ca2de6c747a84b758ce`, including its pinned
  recursive submodules and rootless Cephei development framework/headers.
  Source: https://github.com/theos/theos
- Theos SDKs commit `0222fd5413cf4b9af096f37b4621afa2688572f7`, directory
  iPhoneOS15.6.sdk (SDKSettings identifies SDK 15.5), with Preferences,
  ControlCenterUIKit and AccessibilityUtilities stubs.
  Source: https://github.com/theos/sdks
- ldid 2.1.5_1 and xz from the macOS job's Homebrew environment. The final
  build receipt records actual executable hashes; these are build tools,
  not added runtime dependencies.

With THEOS pointing to those prepared inputs, run in this source directory:

```bash
export DEVELOPER_DIR=/Applications/Xcode_16.4.app/Contents/Developer
test "$(xcodebuild -version)" = $'Xcode 16.4\nBuild version 16F6'
printf '\372\336\014\001\000\000\000\014\000\000\000\000' > "$TMPDIR/abs-adhoc-requirements"
make clean package messages=yes DEBUG=1 FINALPACKAGE=0 \
  "TARGET_CODESIGN_FLAGS=-S -Cadhoc -Q$TMPDIR/abs-adhoc-requirements" \
  THEOS_PACKAGE_SCHEME=rootless 'ARCHS=arm64 arm64e' \
  TARGET=iphone:clang:15.6:15.0 'PACKAGE_VERSION=1.2.1+0chium.1'
```

These override the retained upstream Makefile defaults for both the tweak and
preferences subproject. Rootless Debian architecture is iphoneos-arm64; the
Mach-O CPU slices are arm64 and arm64e (subtype 0x80000002), minimum iOS15.0.
That deployment target does not widen the runtime exact-build guards.

Runtime dependencies remain mobilesubstrate >=0.9.5000 and Cephei
(ws.hbang.common) >=1.17. No signing identity/profile or new runtime dependency
is introduced. Normal ldid signing is enabled with ad-hoc flags and empty
requirements; do not remove the signature verification step to bypass a failure.

Recover the actual binaries from the final .deb. Verify both architecture
slices and code directories. The established macOS check uses
`codesign --verify --all-architectures --verbose=2` on byte-identical standalone
copies, because Theos signs the preferences executable without a sealed bundle
resource envelope. Compare plist/image assets separately. Code-page hash
integrity does not prove jailbreak loading, native service behavior or physical
hardware writes. No install, respring or device test belongs to this build step.
