#import <Foundation/Foundation.h>

#import "LaunchAtLoginController.h"

@interface Preferences : NSObject

+(Preferences *) shared;

@property int distanceUnit;
@property int menuBarStyle;
@property BOOL inverseIconColor;

-(BOOL) isFirstLaunch;

-(BOOL) launchAtStartup;
-(void) setLaunchAtStartup: (BOOL)launchAtStartup;

-(void) load;
-(void) save;

@end
