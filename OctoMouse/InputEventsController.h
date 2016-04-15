#import <Foundation/Foundation.h>

#import "Preferences.h"
#import "InputEventsLogger.h"

#include <CoreFoundation/CoreFoundation.h>
#include <Carbon/Carbon.h>

extern NSString *const InputEventNotificationTag;

@interface InputEventsController : NSObject
{
    // Monitors
@private id _localMonitorLeftMouseDown, _globalMonitorLeftMouseDown;
@private id _localMonitorRightMouseDown, _globalMonitorRightMouseDown;
@private id _localMonitorMouseMoved, _globalMonitorMouseMoved;
@private id _localMonitorScrollWheel, _globalMonitorScrollWheel;
@private id _localMonitorKeyDown, _globalMonitorKeyDown;
    
    InputEventsLogger *_globalLogger;
    InputEventsLogger *_todayLogger;
}

+ (InputEventsController *)shared;

- (void)startListening;
- (void)stopListening;
- (InputEventsLogger*)globalLogger;
- (InputEventsLogger*)todayLogger;


@end
