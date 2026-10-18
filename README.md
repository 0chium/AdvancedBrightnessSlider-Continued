# AdvancedBrightnessSlider Continued

An independently maintained compatibility fork of **Jonas Schiefner's
AdvancedBrightnessSlider**, maintained by **0chium**. Version **1.2.2-1**.

Uses Apple's existing Control Center brightness slider. Above the configured
threshold it adjusts ordinary brightness. Below the threshold, ordinary
brightness stays at minimum while Apple's native Reduce White Point supplies
extra dimming. Existing preferences and the Auto-Brightness implementation are
retained. Auto-Brightness suppression effectiveness is not independently verified.

## Metadata-only version update

Version 1.2.2-1 is a Debian version upgrade from 1.2.1+0chium.1. Only package
control/release metadata changed. The complete installed payload, including
executables, signatures, preferences and packaged notices, is byte-identical
to the accepted public release. Packaged attribution therefore retains its
original payload-version heading. No compilation or compatibility expansion
was performed; all evidence and limitations below remain unchanged.

## Source, support and installation

- [Maintained fork source](https://github.com/0chium/AdvancedBrightnessSlider-Continued)
- [Fork support and issue reports](https://github.com/0chium/AdvancedBrightnessSlider-Continued/issues)
- [0chium's package repository](https://0chium.github.io/)
- [Package information](https://0chium.github.io/depictions/advancedbrightnessslider.html)
- [Original project and author](https://github.com/jschiefner/advanced-brightness-slider-tweak)
- [Support the original developer](https://paypal.me/JonasSchiefner)

Add `https://0chium.github.io/` to Sileo and select AdvancedBrightnessSlider
Continued. Review the replacement transaction before confirming. This package
conflicts with and replaces `com.jschiefner.advancedbrightnessslider`, including
the earlier diagnostics under that identity. Do not force co-installation.

The PayPal destination above is Jonas Schiefner's original destination. It is
not a donation to 0chium, and no upstream endorsement is implied.

## Build-specific compatibility

| Device | Exact version/build | Evidence |
| --- | --- | --- |
| iPhone 14 Pro | 17.0 / 21A329 | Owner reports working mapping and threshold preferences. |
| iPhone 11 Pro Max | 18.3.2 / 22D82 | Owner reports functional success and successful Sileo replacement of the old package, with the threshold preserved. |
| iPhone SE 2 | 18.2 / 22C152 | Statically investigated and admitted by the guard; runtime untested for this update. |
| Planned iPhone SE | 26.0.1 | Planned, untested and unsupported by the current guards. |

These are specific owner reports, not comprehensive compatibility certification
or blanket support for iOS 17/18. Other modern builds are not enabled. The legacy
iOS 16 path is retained, but the owner's working original installation does not
validate this rebuilt package there. Modern Prysm/BigSurCenter support is not
claimed.

The release preparation changes public links and attribution after the tested
candidate; it does not change mapping, state management or exact-build guards.
The final presentation rebuild has not been installed. Native service application
of Auto-Brightness suppression remains unverified; a preference readback alone
does not establish service behavior. Accessibility White Point changes may
affect the screen without repositioning Control Center, as accepted in private
testing. Report observations without repeatedly provoking a failure.

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
