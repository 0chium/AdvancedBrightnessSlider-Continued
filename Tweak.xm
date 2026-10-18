#import "shared.h"
#import "ABSManager.h"
#import <Cephei/HBPreferences.h>
#import "ABSModernNative.h"

HBPreferences* preferences;
BKSLocalDefaults* backboardDefaults = [%c(BKSLocalDefaults) new];

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.jschiefner.advancedbrightnesssliderpreferences"];
	[preferences registerDefaults:@{@"enabled":@YES, @"threshold":@30.0f}];
	// Never initialize legacy slider/manager groups on the new native architecture.
	if (NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17) {
		initModernNative(preferences);
		return;
	}
	if (![preferences boolForKey:@"enabled"]) return;

	int iosVersion = [[[%c(UIDevice) currentDevice] systemVersion] intValue];
	float threshold = [preferences floatForKey:@"threshold"] / 100.0f;

	BOOL modifyAutoBrightness;
	if ([preferences objectForKey:@"modifyAutoBrightness"] == nil) {
		modifyAutoBrightness = [backboardDefaults isALSEnabled];
		[preferences setBool:modifyAutoBrightness forKey:@"modifyAutoBrightness"];
	} else {
		modifyAutoBrightness = [preferences boolForKey:@"modifyAutoBrightness"];
	}

	[[ABSManager shared] initWithAutoBrightnessEnabled:modifyAutoBrightness andIosVersion:iosVersion andThreshold:threshold];
	[preferences registerPreferenceChangeBlockForKey:@"threshold" block:^(NSString *key, id<NSCopying> _Nullable value){
		[[ABSManager shared] setThreshold:[[value copyWithZone:nil] floatValue] / 100.0f];
	}];

	initNative();
	if (%c(PrysmSliderViewController)) initPrysm();
	if (%c(SCDisplaySliderModuleViewController)) initBigSurCenter();
}

static void autoBrightnessChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17) return;
	BOOL enabled = [backboardDefaults isALSEnabled];
	[ABSManager shared].modifyAutoBrightness = enabled;
	[preferences setBool:enabled forKey:@"modifyAutoBrightness"];
}

%ctor {
	// call initializer when Springboard is loaded
  CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		NULL,
		&didFinishLaunching,
		(CFStringRef) UIApplicationDidFinishLaunchingNotification,
		NULL,
		CFNotificationSuspensionBehaviorDrop
	);


	// call AutoBrightness handler method when User modifies auto-brightness switch
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		autoBrightnessChanged,
		CFSTR("AXSAutoBrightnessChangedNotification"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
}
