#import <Foundation/Foundation.h>

@interface InputEventsLogger : NSObject {
    NSString* _identifier;
    
    NSDate* _initializedDate;
    int _elapsedSeconds;
    float _pointsPerMeter;
    
    int _mouseDown[2];
    float _scrollWheelDistance[3];
    int _keyCodeDown[128];
    int _lastKeyCodeDown;
    
    double _mouseMovedTimestamp;
    NSPoint _lastMouseLocation;
}

@property(readonly) float mouseDistance;
@property(readonly) int keyDown;

-(id) initWithIdentifier:(NSString *)identifier;

-(void)load;
-(void)save;
-(void)reset;
-(NSString*)identifier;
-(void)setIdentifier:(NSString *)identifier;

- (void)incElapsedSecond;
- (void)incMouseDownWithButton:(int)button location:(NSPoint)location;
- (void)newMouseLocation:(NSPoint) location;
- (void)incScrollWheelWithDeltaX:(float)deltaX deltaY:(float)deltaY deltaZ:(float)deltaZ;
- (void)incKeyDown:(UInt16) keyCode;

- (int)elapsedTime;
- (NSString*)formattedElapsedTime;
- (float)mouseDistanceInKilometers;
- (float)mouseDistanceInMiles;
- (NSString*)formattedMouseDistance:(int)distanceUnit;
- (int)mouseDown;
- (float)scrollWheelDistanceInKilometers;
- (float)scrollWheelDistanceInMiles;
- (NSString*)formattedScrollWheelDistance:(int)distanceUnit;

@end
