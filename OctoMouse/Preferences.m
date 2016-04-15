#import "Preferences.h"

@implementation Preferences

static Preferences *shared = nil; // static instance variable

+(Preferences *) shared {
    if (shared == nil) {
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}

-(id) init {
    _distanceUnit = 0;
    _menuBarStyle = 0;
    
    return [super init];
}

-(void) load {
    // Load preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [defaults dictionaryForKey:@"preferences"];
    if(dic == nil)
        return;
    
    NSNumber *distanceUnit = [dic objectForKey:@"distanceUnit"];
    _distanceUnit = [distanceUnit intValue];
    NSNumber *menuBarStyle = [dic objectForKey:@"menuBarStyle"];
    _menuBarStyle = [menuBarStyle intValue];
    NSNumber *inverseIconColor = [dic objectForKey:@"inverseIconColor"];
    _inverseIconColor = [inverseIconColor boolValue];
}

-(void) save {
    NSDictionary *dic =[NSDictionary
                        dictionaryWithObjects:@[[NSNumber numberWithInt:_distanceUnit], [NSNumber numberWithBool:_inverseIconColor], [NSNumber numberWithInt:_menuBarStyle]]
                        forKeys:@[@"distanceUnit", @"inverseIconColor", @"menuBarStyle"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dic forKey:@"preferences"];
    [defaults synchronize];
}

-(BOOL) isFirstLaunch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [defaults dictionaryForKey:@"preferences"];
    return dic == nil;
}

-(BOOL) launchAtStartup {
    LaunchAtLoginController *launchAtLoginController = [[LaunchAtLoginController alloc] init];
    return [launchAtLoginController willLaunchAtLogin: [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

-(void) setLaunchAtStartup:(BOOL)launchAtStartup {
    LaunchAtLoginController *launchAtLoginController = [[LaunchAtLoginController alloc] init];
    [launchAtLoginController setLaunchAtLogin: launchAtStartup forURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}



@end
