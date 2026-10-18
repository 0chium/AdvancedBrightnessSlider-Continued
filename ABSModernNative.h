// Private compatibility adapter; original tweak by Jonas Schiefner. GPL-3.0.
#import <Foundation/Foundation.h>
@class HBPreferences;

#ifdef __cplusplus
extern "C" {
#endif
void initModernNative(HBPreferences *preferences);
#ifdef __cplusplus
}
#endif
