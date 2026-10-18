# Changes from AdvancedBrightnessSlider 1.2.1

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
runtime result. SE 2 / 18.2 remains runtime untested; SE / 26.0.1 remains planned
and unsupported. No blanket iOS 17/18 support or verified Auto-Brightness
suppression is claimed. Final presentation changes have not been installed.
