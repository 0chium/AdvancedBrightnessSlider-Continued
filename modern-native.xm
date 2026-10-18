// Private iOS 17.0 / 18.2 / 18.3.2 adapter for AdvancedBrightnessSlider by Jonas Schiefner.
// GPL-3.0; preserve the original attribution and API credits in README.md/ABSManager.xm.
#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import "ABSModernNative.h"
#import "ABSMapping.h"
#import "ReduceWhitePointLevel.h"

@interface AXSettings : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic) BOOL reduceWhitePointEnabled;
@end

@interface CCUIContinuousSliderView : UIControl
- (void)setValue:(float)value animated:(BOOL)animated;
@end

@interface CCUIDisplayModuleViewController : UIViewController
@property (nonatomic, retain) CCUIContinuousSliderView *sliderView;
@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly) float currentBrightness;
@property (nonatomic, readonly) NSUInteger contentRenderingMode; // Inspected iOS 18 targets.
@property (nonatomic) BOOL abs_editing;
@property (nonatomic) BOOL abs_syncing;
@property (nonatomic) BOOL abs_suspended;
- (void)_setBacklightLevel:(float)value;
- (void)_updateWithCurrentBrightnessAnimated:(BOOL)animated;
- (void)_sliderEditingDidBegin:(id)sender;
- (void)_sliderEditingDidEnd:(id)sender;
@end

@protocol ABSDisplayDelegate
- (void)displayModuleViewController:(CCUIDisplayModuleViewController *)controller
               brightnessDidChange:(float)brightness;
@end

static BOOL modernIs18;

// Scope deliberately matches the inspected builds. No runtime offsets.
static BOOL supportedBuild(void) {
    NSOperatingSystemVersion os = NSProcessInfo.processInfo.operatingSystemVersion;
    char build[32] = {0};
    size_t length = sizeof(build);
    if (sysctlbyname("kern.osversion", build, &length, NULL, 0) != 0
        || length == 0 || length > sizeof(build) || build[length - 1] != '\0') return NO;
    NSString *version = [NSString stringWithUTF8String:build];
    modernIs18 = os.majorVersion == 18
        && ((os.minorVersion == 2 && os.patchVersion == 0 && [version isEqualToString:@"22C152"])
            || (os.minorVersion == 3 && os.patchVersion == 2 && [version isEqualToString:@"22D82"]));
    return modernIs18 || (os.majorVersion == 17 && os.minorVersion == 0 && os.patchVersion == 0
        && [version isEqualToString:@"21A329"]);
}

static BOOL realController(CCUIDisplayModuleViewController *controller) {
    return !modernIs18 || controller.contentRenderingMode == 0;
}

typedef struct {
    BOOL enabled;
    double intensity;
} ABSWhitePointState;

static BOOL sameWhitePoint(ABSWhitePointState a, ABSWhitePointState b) {
    return a.enabled == b.enabled && fabs(a.intensity - b.intensity) <= 0.000001;
}

@interface ABSModernAdapter : NSObject
@property (nonatomic) BOOL enabled;
@property (nonatomic) float threshold;
@property (nonatomic, strong) AXSettings *settings;
@property (nonatomic, strong) NSHashTable *controllers;
@property (nonatomic, weak) CCUIDisplayModuleViewController *editor;
@property (nonatomic) BOOL refreshPending;
@property (nonatomic) BOOL ownsWhitePoint;
@property (nonatomic) ABSWhitePointState beforeWhitePoint;
@property (nonatomic) ABSWhitePointState lastWhitePoint;
@property (nonatomic, strong) HBPreferences *preferences;
@property (nonatomic) BOOL modifyAutoBrightness;
@property (nonatomic) BOOL extraDimming;
@property (nonatomic) BOOL ownsAutoBrightness;
@property (nonatomic) BOOL beforeAutoBrightness;
@property (nonatomic) BOOL autoBrightnessStateKnown;
@property (nonatomic) BOOL lastAutoBrightness;
- (BOOL)readWhitePoint:(ABSWhitePointState *)state;
- (BOOL)applyWhitePoint:(BOOL)enabled intensity:(double)intensity;
- (void)checkOwnership;
- (void)restoreWhitePoint;
- (BOOL)readAutoBrightness:(BOOL *)enabled;
- (BOOL)writeAutoBrightness:(BOOL)enabled;
- (void)checkAutoBrightnessOwnership;
- (void)restoreAutoBrightness;
- (void)updateAutoBrightnessForExtraDimming:(BOOL)extraDimming;
- (void)autoBrightnessChanged;
- (void)scheduleRefresh;
- (void)configure:(HBPreferences *)preferences;
@end

static ABSModernAdapter *adapter;

@implementation ABSModernAdapter
- (BOOL)readAutoBrightness:(BOOL *)enabled {
    CFStringRef domain = CFSTR("com.apple.backboardd");
    if (!CFPreferencesAppSynchronize(domain)) return NO;
    Boolean exists = false;
    Boolean value = CFPreferencesGetAppBooleanValue(CFSTR("BKEnableALS"), domain, &exists);
    // Inspected native _AXSAutoBrightnessEnabled defaults to YES when absent.
    *enabled = exists ? value : YES;
    return YES;
}

- (BOOL)writeAutoBrightness:(BOOL)enabled {
    // Same persistence mechanism/credits as upstream ABSManager.xm (Flipswitch).
    CFPreferencesSetAppValue(CFSTR("BKEnableALS"), enabled ? kCFBooleanTrue : kCFBooleanFalse,
                             CFSTR("com.apple.backboardd"));
    BOOL synchronized = CFPreferencesAppSynchronize(CFSTR("com.apple.backboardd"));
    BOOL actual;
    self.autoBrightnessStateKnown = [self readAutoBrightness:&actual];
    if (self.autoBrightnessStateKnown) self.lastAutoBrightness = actual;
    // Preference readback does not establish application by the brightness service.
    return synchronized && self.autoBrightnessStateKnown && actual == enabled;
}

- (void)checkAutoBrightnessOwnership {
    if (!self.ownsAutoBrightness) return;
    BOOL actual;
    if (![self readAutoBrightness:&actual] || actual != NO) self.ownsAutoBrightness = NO;
}

- (void)restoreAutoBrightness {
    self.extraDimming = NO;
    [self checkAutoBrightnessOwnership];
    if (!self.ownsAutoBrightness) return;
    self.ownsAutoBrightness = NO;
    [self writeAutoBrightness:self.beforeAutoBrightness];
}

- (void)updateAutoBrightnessForExtraDimming:(BOOL)extraDimming {
    if (self.extraDimming == extraDimming) return;
    if (!extraDimming) { [self restoreAutoBrightness]; return; }
    self.extraDimming = YES; // At most one suppression attempt per mode entry.
    if (!self.modifyAutoBrightness) return;
    BOOL actual;
    if (![self readAutoBrightness:&actual]) return;
    self.autoBrightnessStateKnown = YES;
    self.lastAutoBrightness = actual;
    if (!actual) return; // Already off: neither change nor claim restoration.
    self.beforeAutoBrightness = actual; // Capture immediately before our change.
    self.ownsAutoBrightness = [self writeAutoBrightness:NO];
}

- (void)autoBrightnessChanged {
    BOOL actual;
    if (![self readAutoBrightness:&actual]) { self.ownsAutoBrightness = NO; return; }
    if (self.autoBrightnessStateKnown && actual == self.lastAutoBrightness) return;
    self.autoBrightnessStateKnown = YES;
    self.lastAutoBrightness = actual;
    if (actual != NO) self.ownsAutoBrightness = NO;
    // As upstream, remember observed user changes in the existing policy key.
    // Our own read-back writes are already recorded above and do not change it.
    // A conflict never retries suppression within the same extra-dimming mode.
    if (self.modifyAutoBrightness != actual)
        [self.preferences setBool:actual forKey:@"modifyAutoBrightness"];
}

- (BOOL)readWhitePoint:(ABSWhitePointState *)state {
    state->enabled = self.settings.reduceWhitePointEnabled;
    state->intensity = MADisplayFilterPrefGetReduceWhitePointIntensity();
    return isfinite(state->intensity) && state->intensity >= 0.25 && state->intensity <= 1.0;
}

- (void)checkOwnership {
    if (!self.ownsWhitePoint) return;
    ABSWhitePointState actual;
    if (![self readWhitePoint:&actual] || !sameWhitePoint(actual, self.lastWhitePoint)) {
        self.ownsWhitePoint = NO;
        // Yield this gesture to an observed conflicting accessibility change.
        self.editor.abs_suspended = YES;
    }
}

- (BOOL)applyWhitePoint:(BOOL)enabled intensity:(double)intensity {
    [self checkOwnership];
    if (self.editor.abs_suspended) return NO;
    ABSWhitePointState actual;
    if (![self readWhitePoint:&actual]) return NO;
    ABSWhitePointState desired = {enabled, enabled ? intensity : actual.intensity};
    if (sameWhitePoint(actual, desired)) return YES;
    if (!self.ownsWhitePoint) {
        // Borrow only at the first actual change, never at process startup.
        self.beforeWhitePoint = actual;
        self.ownsWhitePoint = YES;
    }
    self.lastWhitePoint = desired;
    // Set intensity before enabling, avoiding activation at a stale intensity.
    if (enabled && fabs(actual.intensity - intensity) > 0.000001)
        MADisplayFilterPrefSetReduceWhitePointIntensity((CGFloat)intensity);
    if (actual.enabled != enabled) self.settings.reduceWhitePointEnabled = enabled;
    ABSWhitePointState readback;
    if (![self readWhitePoint:&readback] || !sameWhitePoint(readback, desired)) {
        self.ownsWhitePoint = NO;
        self.editor.abs_suspended = YES;
        return NO;
    }
    return YES;
}

- (void)restoreWhitePoint {
    [self checkOwnership];
    if (!self.ownsWhitePoint) return;
    self.ownsWhitePoint = NO;
    ABSWhitePointState saved = self.beforeWhitePoint;
    // Recheck above, then restore only this adapter's still-owned settings.
    if (!saved.enabled) self.settings.reduceWhitePointEnabled = NO;
    MADisplayFilterPrefSetReduceWhitePointIntensity((CGFloat)saved.intensity);
    if (saved.enabled) self.settings.reduceWhitePointEnabled = YES;
}

- (void)scheduleRefresh {
    if (self.refreshPending) return;
    self.refreshPending = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.refreshPending = NO;
        [self checkOwnership];
        for (CCUIDisplayModuleViewController *controller in self.controllers.allObjects) {
            if (controller.isViewLoaded && controller.view.window && realController(controller))
                [controller _updateWithCurrentBrightnessAnimated:NO];
        }
    });
}

- (void)configure:(HBPreferences *)preferences {
    self.preferences = preferences;
    if ([preferences objectForKey:@"modifyAutoBrightness"] == nil) {
        BOOL actual;
        if ([self readAutoBrightness:&actual]) {
            self.autoBrightnessStateKnown = YES;
            self.lastAutoBrightness = actual;
            // Preserve upstream's initial policy; this is not a restoration snapshot.
            [preferences setBool:actual forKey:@"modifyAutoBrightness"];
        }
    }
    BOOL modifyAutoBrightness = [preferences boolForKey:@"modifyAutoBrightness"];
    BOOL enabled = [preferences boolForKey:@"enabled"];
    float threshold = [preferences floatForKey:@"threshold"] / 100.f;
    if (!ABSValidThreshold(threshold)) threshold = 0.3f;
    if (self.threshold != threshold || self.enabled != enabled
        || self.modifyAutoBrightness != modifyAutoBrightness)
        self.editor.abs_suspended = YES;
    if (!enabled || self.modifyAutoBrightness != modifyAutoBrightness)
        [self restoreAutoBrightness];
    self.modifyAutoBrightness = modifyAutoBrightness;
    self.threshold = threshold;
    self.enabled = enabled;
    if (!enabled) [self restoreWhitePoint];
    [self scheduleRefresh];
}
@end

static void whitePointChanged(CFNotificationCenterRef center, void *observer,
                              CFStringRef name, const void *object, CFDictionaryRef info) {
    // Darwin callbacks have no writer identity. Read/compare on the main queue;
    // coalescing also avoids refreshing between our intensity/enablement writes.
    dispatch_async(dispatch_get_main_queue(), ^{ [adapter scheduleRefresh]; });
}

static void modernAutoBrightnessChanged(CFNotificationCenterRef center, void *observer,
                                       CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_async(dispatch_get_main_queue(), ^{ [adapter autoBrightnessChanged]; });
}

%group ModernNative
%hook CCUIDisplayModuleViewController
%property (nonatomic) BOOL abs_editing;
%property (nonatomic) BOOL abs_syncing;
%property (nonatomic) BOOL abs_suspended;

- (void)_setBacklightLevel:(float)value {
    if (!realController(self)) return; // Preview must never write system settings.
    if (self.abs_syncing || self.abs_suspended) return;
    if (!adapter.enabled) {
        %orig;
        return;
    }
    if (!self.abs_editing || adapter.editor != self) return;
    float brightness;
    double intensity;
    bool whitePoint;
    if (!ABSMapPosition(value, adapter.threshold, &brightness, &intensity, &whitePoint)) return;
    if (![adapter applyWhitePoint:whitePoint intensity:intensity]) return;
    [adapter updateAutoBrightnessForExtraDimming:whitePoint];
    %orig(brightness); // One native setter invocation, not proof of a hardware write.
}

- (void)_updateWithCurrentBrightnessAnimated:(BOOL)animated {
    if (!realController(self)) {
        %orig;
        return;
    }
    // Never feed programmatic synchronization back into an active transaction.
    if (self.abs_syncing || self.abs_editing) return;
    self.abs_syncing = YES;
    @try {
        if (!adapter.enabled) {
            %orig;
            return;
        }
        ABSWhitePointState actual;
        float brightness = self.currentBrightness;
        float position;
        if (![adapter readWhitePoint:&actual]
            || !ABSInversePosition(brightness, actual.enabled, actual.intensity,
                                   adapter.threshold, &position)) return;
        // This is the inspected native refresh body with only the slider value
        // remapped. Keep the getter and both glyphs in physical-brightness units.
        [self.sliderView setValue:position animated:NO];
        [(id<ABSDisplayDelegate>)self.delegate displayModuleViewController:self
                                                       brightnessDidChange:brightness];
    } @finally {
        self.abs_syncing = NO;
    }
}

- (void)_sliderEditingDidBegin:(id)sender {
    BOOL track = realController(self) && !self.abs_syncing && adapter.enabled;
    if (track) {
        // Mark editing before Apple's transaction creation can reenter refresh.
        if (adapter.editor && adapter.editor != self) adapter.editor.abs_suspended = YES;
        self.abs_editing = YES;
        self.abs_suspended = NO;
        adapter.editor = self;
    }
    %orig; // Apple alone creates/owns the editing transaction.
    if (track) {
        [adapter checkOwnership];
        [adapter checkAutoBrightnessOwnership];
    }
}

- (void)_sliderEditingDidEnd:(id)sender {
    %orig; // Includes Apple's release/nulling of its transaction.
    self.abs_editing = NO;
    self.abs_suspended = NO;
    if (adapter.editor == self) adapter.editor = nil;
    [adapter scheduleRefresh]; // After the fluid callback returns; no value rollback.
}

- (void)viewWillAppear:(BOOL)animated {
    if (realController(self)) [adapter.controllers addObject:self];
    %orig; // Calls our mapped refresh before display, including recreated controls.
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig; // Preserve Apple's fallback transaction cleanup on dismissal.
    self.abs_editing = NO;
    self.abs_suspended = NO;
    if (adapter.editor == self) adapter.editor = nil;
    [adapter.controllers removeObject:self];
    [adapter scheduleRefresh];
}
%end
%end

extern "C" void initModernNative(HBPreferences *preferences) {
    if (!supportedBuild()) return;
    Class controller = NSClassFromString(@"CCUIDisplayModuleViewController");
    for (NSString *name in @[@"_setBacklightLevel:", @"_updateWithCurrentBrightnessAnimated:",
                            @"_sliderEditingDidBegin:", @"_sliderEditingDidEnd:",
                            @"currentBrightness", @"sliderView", @"delegate"])
        if (!class_getInstanceMethod(controller, NSSelectorFromString(name))) return;
    if (modernIs18 && !class_getInstanceMethod(controller, @selector(contentRenderingMode))) return;
    Class settingsClass = NSClassFromString(@"AXSettings");
    if (![settingsClass respondsToSelector:@selector(sharedInstance)]) return;
    AXSettings *settings = [settingsClass sharedInstance];
    if (![settings respondsToSelector:@selector(reduceWhitePointEnabled)]
        || ![settings respondsToSelector:@selector(setReduceWhitePointEnabled:)]) return;
    adapter = [ABSModernAdapter new];
    adapter.settings = settings;
    adapter.controllers = [NSHashTable weakObjectsHashTable];
    %init(ModernNative);
    [adapter configure:preferences];
    for (NSString *key in @[@"enabled", @"threshold", @"modifyAutoBrightness"])
        [preferences registerPreferenceChangeBlockForKey:key block:^(NSString *changedKey, id value) {
            dispatch_async(dispatch_get_main_queue(), ^{ [adapter configure:preferences]; });
        }];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        whitePointChanged, CFSTR("com.apple.mediaaccessibility.displayFilterSettingsChanged"),
        NULL, CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        modernAutoBrightnessChanged, CFSTR("AXSAutoBrightnessChangedNotification"),
        NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
