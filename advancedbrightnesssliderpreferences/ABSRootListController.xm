#import <Foundation/Foundation.h>
#import "ABSRootListController.h"
#import <Cephei/HBRespringController.h>
#import <Preferences/PSSpecifier.h>

@implementation ABSRootListController

- (NSArray*)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		// Modern controlled disablement must reach SpringBoard before a respring
		// can discard its in-memory restoration state. Keep the legacy UI/path.
		if (NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17) {
			for (PSSpecifier *specifier in _specifiers) {
				if ([[specifier propertyForKey:@"key"] isEqualToString:@"enabled"])
					[specifier setProperty:@"com.jschiefner.advancedbrightnesssliderpreferences/ReloadPrefs"
					                 forKey:@"PostNotification"];
			}
		}
	}

	return _specifiers;
}

-(void)respring {
	[HBRespringController respring];
}

-(void)openGithub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/0chium/AdvancedBrightnessSlider-Continued"] options:@{} completionHandler:nil];
}

-(void)openSupport {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/0chium/AdvancedBrightnessSlider-Continued/issues"] options:@{} completionHandler:nil];
}

-(void)openUpstream {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/jschiefner/advanced-brightness-slider-tweak/"] options:@{} completionHandler:nil];
}

-(void)openPaypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/JonasSchiefner"] options:@{} completionHandler:nil];
}

@end
