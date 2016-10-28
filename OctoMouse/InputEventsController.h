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
    
    InputEventsLogger *_globalLogger, *_todayLogger, *_yesterdayLogger;
}

+ (InputEventsController*)shared;

- (void)startListening;
- (void)stopListening;
- (InputEventsLogger*)globalLogger;
- (InputEventsLogger*)todayLogger;
- (InputEventsLogger*)yesterdayLogger;


@end
