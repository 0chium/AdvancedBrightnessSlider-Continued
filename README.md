# AdvancedBrightnessSlider Continued

**Go beyond minimum brightness.**

Adjust brightness and extra dimming with the same Control Center slider. Above
your chosen threshold, it controls normal brightness. Below it, Apple's native
Reduce White Point dims the screen further while brightness stays at minimum.

Start with the default 30% split, or open **AdvancedBrightnessSlider Continued**
in Settings and adjust **Threshold**. Threshold changes apply automatically.
The Settings pane requires **PreferenceLoader** and **Cephei Tweak Support**.

An independently maintained compatibility fork of **Jonas Schiefner's
AdvancedBrightnessSlider**, maintained by **0chium**. Free and GPL-3.0 licensed.
Version **1.2.4-1**.

## Source, support and installation

- [Maintained fork source](https://github.com/0chium/AdvancedBrightnessSlider-Continued)
- [Fork support and issue reports](https://github.com/0chium/AdvancedBrightnessSlider-Continued/issues)
- [0chium's package repository](https://0chium.github.io/)
- [Package information](https://0chium.github.io/depictions/advancedbrightnessslider.html)
- [Original project and author](https://github.com/jschiefner/advanced-brightness-slider-tweak)
- [Support the original developer](https://paypal.me/JonasSchiefner)

Add `https://0chium.github.io/` to Sileo and install **AdvancedBrightnessSlider
Continued**. It replaces the original AdvancedBrightnessSlider package and
retains existing preferences. Let Sileo handle the replacement.

The PayPal destination above is Jonas Schiefner's original destination. It is
not a donation to 0chium, and no upstream endorsement is implied.

## Build-specific compatibility

Available to try on iOS/iPadOS 17 through 26 with a compatible rootless jailbreak. No Dopamine-only requirement. Tested configurations are listed separately; other combinations need testing.

| Device | Exact version/build | Evidence |
| --- | --- | --- |
| iPhone 14 Pro | 17.0 / 21A329 | Owner reports working mapping and threshold preferences. |
| iPhone 11 Pro Max | 18.3.2 / 22D82 | Owner reports functional success and successful Sileo replacement of the old package, with the threshold preserved. |
| iPhone SE 2 | 18.2 / 22C152 | Statically investigated and admitted by the guard; runtime untested for this update. |
| iPhone SE (2nd generation) | 26.0.1 / 23A355 | Owner reports working brightness mapping with 1.2.2-1+abs26exp.1. The 1.2.3-1 release reuses its complete installed payload unchanged. |

Version 1.2.4-1 removes the exact-build allowlist across iOS/iPadOS 17–26.
It retains the native interface and preview checks. The legacy iOS 16 path is
unchanged and untested in the rebuilt continued release. Modern Prysm/BigSurCenter
support is not claimed. The package is rootless; removing OS locks does not
convert it for rootful or RootHide environments.

A community tester reports an iPad (9th generation) working on iPadOS 17.0 with
Dopamine and an A10X iPad not working on 17.7.8 with palera1n. Exact installed
package versions and build numbers were not supplied. The old guard excluded
17.7.8; whether 1.2.4-1 works there remains unverified. The reports do not isolate
the jailbreak as the cause.

The iOS 17.0 and 18.3.2 reports used earlier candidates. The iOS 26.0.1 report
used 1.2.2-1+abs26exp.1; public 1.2.3-1 reuses that package's complete installed
payload without recompiling. Only its package Version and Description changed.
The 1.2.3-1 package container was not separately device-tested. Version 1.2.4-1
rebuilds the admission change; this new build has not received device testing.
Earlier functional reports are preserved as evidence of those configurations.

On iOS 26.0.1, the Threshold slider's numeric value is not visible in Settings.
Preview isolation has not received a separate focused device test on that OS;
the existing rendering check remains enabled. Native service application of
Auto-Brightness suppression remains unverified; a preference readback alone
does not establish service behavior. Accessibility White Point changes may
affect the screen without repositioning Control Center, as accepted in private
testing.

## Preferences and state

Package ID: `com.ochium.advancedbrightnessslider` (letter `o` in `ochium`).
Maintainer: `0chium` (digit `0`). Original author: Jonas Schiefner.

The preference domain remains `com.jschiefner.advancedbrightnesssliderpreferences`.
Existing keys, binary, bundle, class and notification names are preserved. The
package reuses the existing injection/filter and PreferenceLoader paths. No
preference-reset or migration script is added; no `Provides` alias is declared.
The owner reports that Sileo replacement preserved the threshold on the tested
18.3.2 target; this does not certify all install/update/removal scenarios.

Controlled disablement conditionally restores borrowed White Point and
Auto-Brightness settings while ownership remains uncontested. Startup brightness
is not restored. Crash, SpringBoard restart or removal cannot guarantee cleanup;
system settings may remain changed. No persistence daemon or polling is added.

## Broad version admission

Version 1.2.4-1 allows every minor and patch version within iOS/iPadOS 17–26.
It uses the existing iOS 17 path for the 17.x family and the existing rendering
mode check for 18 and later. Native selector prerequisites, preview isolation,
brightness mapping, transaction cleanup and settings ownership remain in place.
There is no jailbreak-brand check. Functional compatibility on untested releases
is not guaranteed; successful and unsuccessful reports are welcome.

## Earlier iOS 26.0.1 update

Version 1.2.3-1 adds exact iOS 26.0.1 admission and applies the existing rendering
selector prerequisite and preview check to that path. It retains Apple's native
interaction and brightness transactions, existing mapping, preference storage,
restoration behavior and iOS 16/17/18 paths. No polling or new dependency is added.

The release reuses the complete installed data archive from the owner-tested
1.2.2-1+abs26exp.1 package. Both signed binaries and every installed resource are
byte-identical to that package. A metadata repack gives it the public version
1.2.3-1, which upgrades both the previous public and experimental versions.

## Earlier metadata-only version update

Version 1.2.2-1 is a Debian version upgrade from 1.2.1+0chium.1. Only package
control/release metadata changed. The complete installed payload, including
executables, signatures, preferences and packaged notices, is byte-identical
to the accepted public release. Packaged attribution therefore retains its
original payload-version heading. No compilation or compatibility expansion
was performed; all evidence and limitations below remain unchanged.

## Implementation and credits

See [CHANGELOG.md](CHANGELOG.md) for the meaningful compatibility changes and
[BUILDING.md](BUILDING.md) for identified build inputs and signing commands.
Original GPL-3.0 licensing and copyright notices remain intact; see [LICENSE](LICENSE).
Upstream baseline: `6d77a742b859603c7b8763df126faad1dc4d485a` (1.2.1).

Original credits:

- [opa334 / WhitePointModule](https://github.com/opa334/WhitePointModule): Reduce White Point API reference.
- [rpetrich / Flipswitch](https://github.com/a3tweaks/Flipswitch): Auto-Brightness API reference.
- [PoomSmart](https://github.com/PoomSmart): upstream iOS 15 compatibility.
- [zaneh](https://github.com/zaneh): iOS tweak development tutorials.

[UPSTREAM-README.md](UPSTREAM-README.md) preserves the original README unchanged.
Its support matrix, badges, Havoc link and screenshots describe the original
public package, not this fork. Supplied Sileo screenshots likewise show original
public version 1.2.1, not the renamed release.
