# Changes from AdvancedBrightnessSlider 1.2.1

## 1.2.4-1

- Removes the modern exact-build allowlist. All minor and patch versions within
  iOS/iPadOS 17–26 may initialize when the existing native interfaces are present.
- Retains selector prerequisites and rendering/preview checks. iOS 17 uses its
  existing path; iOS 18 and later use the existing rendering-mode check.
- Keeps mapping, native transactions, preference storage, restoration behavior,
  original author/GPL credits and rootless packaging unchanged.
- No Dopamine-only restriction. Rootful or RootHide conversion is not implied.
- This new build is not device-tested. Earlier owner reports and the external
  iPad 9 / 17.0 report are distinct from compatibility on untested versions.

## 1.2.3-1

- Enables exactly iOS 26.0.1 with the existing controller adapter, rendering
  selector prerequisite and preview guard. Other iOS 26 versions are not enabled.
- Owner reports working mapping on iPhone SE (2nd generation), iOS 26.0.1
  (23A355), using 1.2.2-1+abs26exp.1. Settings does not show the Threshold
  slider's numeric value. Preview isolation has not been separately tested.
- Reuses that tested package's data archive verbatim. No recompilation;
  binaries, signatures and installed resources are unchanged. Only the package
  Version and Description fields change. The new container is not separately
  device-tested.
- Preserves Jonas Schiefner's authorship, GPL-3.0, upstream credits, preference
  storage, dependencies, replacement metadata and earlier OS paths.

## 1.2.2-1

- Metadata-only Debian version update from 1.2.1+0chium.1; dpkg confirms the
  new version sorts strictly higher, allowing a normal same-package upgrade.
- Reused the accepted data archive verbatim. Executables, signatures and every
  installed resource remain byte-identical. Only the control Version field
  changed inside the package; no compilation or functional source change.
- Preserved original authorship/GPL-3.0, preference storage, dependencies,
  Conflicts/Replaces, exact-build guards, compatibility evidence and limitations.
- Retained the older ABS package and all existing Lantern releases/entries.

## 1.2.1+0chium.1

- Independently maintained by 0chium; original authorship remains Jonas Schiefner.
- Added a targeted modern CCUIDisplayModuleViewController adapter. It maps the
  outgoing float brightness request, calls Apple's original setter once, and
  represents the inverse logical position during native refresh. Apple retains
  fluid interaction, native glyphs, brightness getters and editing transactions.
- Restricted modern hooks to inspected exact builds: 17.0/21A329, 18.2/22C152
  and 18.3.2/22D82, with existing class/selector guards. Preview rendering cannot
  write system settings through the adapter. No runtime offsets are used.
- Preserved the upstream threshold and brightness/Reduce White Point mapping;
  validate finite inputs and a threshold strictly between zero and one.
- Added event-driven synchronization and scoped feedback guards. Existing
  external settings are represented deterministically without rewriting them
  merely to fit the mapping. Active editing and completion remain native.
- Capture borrowed White Point and Auto-Brightness settings immediately before
  changes; restore conditionally during controlled transitions only while
  ownership remains uncontested. Avoid repeated Auto-Brightness writes during
  one extra-dimming episode. Preserve the existing hidden policy preference and
  upstream preference mechanism; service-level suppression is not verified.
- Retained the iOS 16 execution path, original preference storage and meaningful
  options. Enabled preference notification reaches modern controlled disablement.
- Renamed package presentation to AdvancedBrightnessSlider Continued; package
  com.ochium.advancedbrightnessslider conflicts with and replaces the original
  package while retaining shared injection and preference paths.
- Added explicit fork source/support, original-project attribution, unchanged
  original-developer donation destination, and packaged GPL-3.0 notices.

Evidence: owner-reported mapping/threshold success on iPhone 14 Pro / 17.0 /
21A329; owner-reported functional and Sileo migration success on iPhone 11 Pro
Max / 18.3.2 / 22D82 with the threshold preserved. Static inspection supports
the scoped adapter contracts; a successful build/signature check is not a
runtime result. SE 2 / 18.2 remains runtime untested. The iOS 26.0.1 result is recorded under
1.2.3-1 above. No blanket iOS support or independently verified Auto-Brightness
suppression is claimed. Earlier presentation-only rebuilds were not separately
installed during the original iOS 17/18 tests.
