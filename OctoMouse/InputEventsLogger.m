/*
 In OSX 10.9 (Mavericks) the setting has moved to System Preferences > Security & Privacy > Privacy > Accessibility - make sure your app is checked.
 */

#import "InputEventsLogger.h"

@implementation InputEventsLogger

-(id) initWithIdentifier:(NSString *)identifier {
    _identifier = identifier;
    
    _lastMouseLocation = [NSEvent mouseLocation];
    
    _initializedDate = [NSDate date];
    
    NSScreen *screen = [NSScreen mainScreen];
    NSDictionary *description = [screen deviceDescription];
    CGSize displayPhysicalSize = CGDisplayScreenSize(                                                    [[description objectForKey:@"NSScreenNumber"] unsignedIntValue]);
    NSSize displayPointsSize = [screen frame].size;
    _pointsPerMeter = (displayPhysicalSize.width * 0.001) / displayPointsSize.width;
    
    return self;
}

-(void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [defaults dictionaryForKey:_identifier];
    if(dic == nil)
        return;
    
    _initializedDate = [dic objectForKey:@"initializedDate"];
    NSNumber* elapsedSecondsNumber = [dic objectForKey:@"elapsedSeconds"];
    NSArray* mouseDownArray = [dic objectForKey:@"mouseDown"];
    NSArray* scrollWheelDistanceArray = [dic objectForKey:@"scrollWheelDistance"];
    NSArray* keyCodeDownArray = [dic objectForKey:@"keyCodeDown"];
    NSNumber* mouseDistanceNumber = [dic objectForKey:@"mouseDistance"];
    NSNumber* keyDownNumber = [dic objectForKey:@"keyDown"];
    
    _elapsedSeconds = (int)[elapsedSecondsNumber integerValue];
    _mouseDistance = [mouseDistanceNumber floatValue];
    _keyDown = (int)[keyDownNumber integerValue];
    
    int i = 0;
    for (NSNumber* n in mouseDownArray)
        _mouseDown[i++] = (int)[n integerValue];
    
    i = 0;
    for (NSNumber* n in scrollWheelDistanceArray)
        _scrollWheelDistance[i++] = [n floatValue];
    
    i = 0;
    for (NSNumber* n in keyCodeDownArray)
        _keyCodeDown[i++] = (int)[n integerValue];
}


-(void)save {
    NSMutableArray* mouseDownArray = [NSMutableArray arrayWithCapacity:2];
    for ( int i = 0; i < 2; ++i )
        [mouseDownArray addObject:[NSNumber numberWithInt:_mouseDown[i]]];
    
    NSMutableArray* scrollWheelDistanceArray = [NSMutableArray arrayWithCapacity:3];
    for ( int i = 0; i < 3; ++i )
        [scrollWheelDistanceArray addObject:[NSNumber numberWithFloat:_scrollWheelDistance[i]]];
    
    NSMutableArray* keyCodeDownArray = [NSMutableArray arrayWithCapacity:128];
    for ( int i = 0; i < 128; ++i )
        [keyCodeDownArray addObject:[NSNumber numberWithInt:_keyCodeDown[i]]];
    
    NSDictionary *dic =[NSDictionary
                        dictionaryWithObjects:@[_initializedDate,[NSNumber numberWithInt:_elapsedSeconds],mouseDownArray,scrollWheelDistanceArray,keyCodeDownArray,[NSNumber numberWithFloat:_mouseDistance],[NSNumber numberWithInt:_keyDown]]
                        forKeys:@[@"initializedDate",@"elapsedSeconds",@"mouseDown",@"scrollWheelDistance",@"keyCodeDown",@"mouseDistance",@"keyDown"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dic forKey:_identifier];
    [defaults synchronize];
}

-(void)reset {
    _lastMouseLocation = [NSEvent mouseLocation];
    _initializedDate = [NSDate date];
    _elapsedSeconds = 0;
    for ( int i = 0; i < 2; ++i )
        _mouseDown[i] = 0;
    for ( int i = 0; i < 3; ++i )
        _scrollWheelDistance[i] = 0;
    for ( int i = 0; i < 128; ++i )
        _keyCodeDown[i] = 0;
    _keyDown = 0;
    _mouseDistance = 0;
}

-(NSString*)identifier {
    return _identifier;
}

-(void)setIdentifier:(NSString *)identifier {
    _identifier = identifier;
}

- (void)incElapsedSecond {
    ++_elapsedSeconds;
}

- (void)incMouseDownWithButton:(int)button location:(NSPoint)location {
    ++_mouseDown[button];
}

- (int)mouseDown {
    return _mouseDown[0] + _mouseDown[1];
}

- (void)newMouseLocation:(NSPoint) location {
    float ptxd = location.x - _lastMouseLocation.x;
    float ptyd = location.y - _lastMouseLocation.y;
    
    double now = CFAbsoluteTimeGetCurrent();
    float d = sqrtf( ptxd*ptxd + ptyd*ptyd );
    _mouseDistance += d;

    _mouseMovedTimestamp = now;
    _lastMouseLocation = location;
    
}

- (void)incScrollWheelWithDeltaX:(float)deltaX deltaY:(float)deltaY deltaZ:(float)deltaZ {
    _scrollWheelDistance[0] += fabs(deltaX);
    _scrollWheelDistance[1] += fabs(deltaY);
    _scrollWheelDistance[2] += fabs(deltaZ);
}

- (float)scrollWheelDistanceInKilometers {
    return (_scrollWheelDistance[0] + _scrollWheelDistance[1] + _scrollWheelDistance[2]) * _pointsPerMeter * 0.001;
}

- (float)scrollWheelDistanceInMiles {
    return [self scrollWheelDistanceInKilometers] * 1.609344;
}

- (NSString*)formattedScrollWheelDistance:(int)distanceUnit {
    switch(distanceUnit) {
        case 1:
            return [NSString stringWithFormat:@"%.03fmi", [self scrollWheelDistanceInMiles]];
        default:
            return [NSString stringWithFormat:@"%.03fkm", [self scrollWheelDistanceInKilometers]];
    }
}

- (void)incKeyDown:(UInt16) keyCode {
    ++_keyDown;
    ++_keyCodeDown[keyCode];
    _lastKeyCodeDown = keyCode;
}

- (float)mouseDistanceInKilometers {
    return _mouseDistance * _pointsPerMeter * 0.001;
}

- (float)mouseDistanceInMiles {
    return [self mouseDistanceInKilometers] * 1.609344;
}

- (NSString*)formattedMouseDistance:(int)distanceUnit {
    float value;
    switch(distanceUnit) {
        case 1:
            value = [self mouseDistanceInMiles];
            break;
        default:
            value = [self mouseDistanceInKilometers];
            break;
    }
    
    NSString* format = (value < 10.0)?@"%.03f":@"%.02f";
    
    switch(distanceUnit) {
        case 1:
            format = [format stringByAppendingString:@"mi"];
            break;
        default:
            format = [format stringByAppendingString:@"km"];
            break;
    }
    
    return [NSString stringWithFormat:format, value];
}

- (int)elapsedTime {
    return _elapsedSeconds;
}

- (NSString*)formattedElapsedTime {
    int time = _elapsedSeconds;
    
    int seconds = time % 60;
    time = (time - seconds) / 60;
    
    int minutes = time % 60;
    time = (time - minutes) / 60;
    
    int hours = time % 24;
    time = (time - hours) / 24;
    
    int days = time;
    
    return [NSString stringWithFormat:@"%dd %02d:%02d:%02d", days, hours, minutes, seconds];
}

@end
