#import "InputEventsController.h"
#import <AppKit/NSEvent.h>


NSString *const InputEventNotificationTag = @"InputEventNotification";

@implementation InputEventsController {
    NSTimer* _timer;
}

static InputEventsController *shared = nil; // static instance variable

+ (InputEventsController *)shared {
    if (shared == nil) {
        shared = [[super allocWithZone:NULL] init];
    }
    return shared;
}

const char* keyCodeToReadableString (CGKeyCode keyCode);

-(id) init {
    self = [super init];
    if(self)
    {
        _globalLogger = [[InputEventsLogger alloc] initWithIdentifier:@"global"];
        [_globalLogger load];
        _todayLogger = [[InputEventsLogger alloc] initWithIdentifier:[self todayDate]];
        [_todayLogger load];
    }
    
    return self;
}

- (void)startListening {
    [self stopListening]; // For safety, to avoid events being called twice.
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(incElapsedSecond:)
                                            userInfo:nil
                                             repeats:YES];
    
    id leftMouseDownHandler = ^(NSEvent *evt) {
        [_globalLogger incMouseDownWithButton:0 location:[NSEvent mouseLocation]];
        [_todayLogger incMouseDownWithButton:0 location:[NSEvent mouseLocation]];
        [self notify];
        
        return evt;
    };
    _localMonitorLeftMouseDown = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:leftMouseDownHandler];
    _globalMonitorLeftMouseDown = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:leftMouseDownHandler];
    
    id rightMouseDownHandler = ^(NSEvent *evt) {
        [_globalLogger incMouseDownWithButton:1 location:[NSEvent mouseLocation]];
        [_todayLogger incMouseDownWithButton:1 location:[NSEvent mouseLocation]];
        [self notify];
        return evt;
    };
    _localMonitorRightMouseDown = [NSEvent addLocalMonitorForEventsMatchingMask:NSRightMouseDownMask handler:rightMouseDownHandler];
    _globalMonitorRightMouseDown = [NSEvent addGlobalMonitorForEventsMatchingMask:NSRightMouseDownMask handler:rightMouseDownHandler];
    
    id mouseMovedHandler = ^(NSEvent *evt) {
        [_globalLogger newMouseLocation:[NSEvent mouseLocation]];
        [_todayLogger newMouseLocation:[NSEvent mouseLocation]];
        [self notify];
        
        return evt;
    };
    _localMonitorMouseMoved =[NSEvent addLocalMonitorForEventsMatchingMask:NSMouseMovedMask handler:mouseMovedHandler];
    _globalMonitorMouseMoved =[NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:mouseMovedHandler];
    
    id scrollWheelHandler = ^(NSEvent *evt) {
        [_globalLogger incScrollWheelWithDeltaX:[evt deltaX] deltaY:[evt deltaY] deltaZ:[evt deltaZ]];
        [_todayLogger incScrollWheelWithDeltaX:[evt deltaX] deltaY:[evt deltaY] deltaZ:[evt deltaZ]];
        [self notify];
        return evt;
    };
    _localMonitorScrollWheel = [NSEvent addLocalMonitorForEventsMatchingMask:NSScrollWheelMask handler:scrollWheelHandler];
    _globalMonitorScrollWheel = [NSEvent addGlobalMonitorForEventsMatchingMask:NSScrollWheelMask handler:scrollWheelHandler];
    
    id keyDownHandler = ^(NSEvent *evt) {
        if(![evt isARepeat]) {
            [_globalLogger incKeyDown:[evt keyCode]];
            [_todayLogger incKeyDown:[evt keyCode]];
            [self notify];
        }
        return evt;
    };
    _localMonitorKeyDown = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:keyDownHandler];
    _globalMonitorKeyDown = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:keyDownHandler];
}

- (void)stopListening {
    [_timer invalidate];
    _timer = nil;
    
    [NSEvent removeMonitor:_localMonitorLeftMouseDown];
    [NSEvent removeMonitor:_localMonitorRightMouseDown];
    [NSEvent removeMonitor:_localMonitorMouseMoved];
    [NSEvent removeMonitor:_localMonitorScrollWheel];
    [NSEvent removeMonitor:_localMonitorKeyDown];
    
    [NSEvent removeMonitor:_globalMonitorLeftMouseDown];
    [NSEvent removeMonitor:_globalMonitorRightMouseDown];
    [NSEvent removeMonitor:_globalMonitorMouseMoved];
    [NSEvent removeMonitor:_globalMonitorScrollWheel];
    [NSEvent removeMonitor:_globalMonitorKeyDown];
    
    [_globalLogger save];
    [_todayLogger save];
}

- (void)incElapsedSecond:(NSTimer*)timer {
    [_globalLogger incElapsedSecond];
    [_todayLogger incElapsedSecond];
    [self notify];
    
    if([_globalLogger elapsedTime] % 60 == 0) {
        // Back up
        [_globalLogger save];
        [_todayLogger save];
        
        // If it's a new day, the logger will be reset
        NSString* today = [self todayDate];
        if(![today isEqualToString:[_todayLogger identifier]]) {
            [_todayLogger save];
            [_todayLogger setIdentifier:today];
            [_todayLogger reset];
            [_todayLogger load];
        }
    }
}

- (InputEventsLogger*)globalLogger {
    return _globalLogger;
}

- (InputEventsLogger*)todayLogger {
    return _todayLogger;
}

- (void)notify {
    [[NSNotificationCenter defaultCenter] postNotificationName:InputEventNotificationTag object:self];
}

- (NSString*)todayDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *now = [[NSDate alloc] init];
    return [dateFormat stringFromDate:now];
}

const char* keyCodeToReadableString (CGKeyCode keyCode) {
    switch ((int) keyCode) {
        case   0: return "a";
        case   1: return "s";
        case   2: return "d";
        case   3: return "f";
        case   4: return "h";
        case   5: return "g";
        case   6: return "z";
        case   7: return "x";
        case   8: return "c";
        case   9: return "v";
        case  11: return "b";
        case  12: return "q";
        case  13: return "w";
        case  14: return "e";
        case  15: return "r";
        case  16: return "y";
        case  17: return "t";
        case  18: return "1";
        case  19: return "2";
        case  20: return "3";
        case  21: return "4";
        case  22: return "6";
        case  23: return "5";
        case  24: return "=";
        case  25: return "9";
        case  26: return "7";
        case  27: return "-";
        case  28: return "8";
        case  29: return "0";
        case  30: return "]";
        case  31: return "o";
        case  32: return "u";
        case  33: return "[";
        case  34: return "i";
        case  35: return "p";
        case  37: return "l";
        case  38: return "j";
        case  39: return "\"";
        case  40: return "k";
        case  41: return ";";
        case  42: return "\\";
        case  43: return ",";
        case  44: return "/";
        case  45: return "n";
        case  46: return "m";
        case  47: return ".";
        case  50: return "`";
        case  65: return "<keypad-decimal>";
        case  67: return "<keypad-multiply>";
        case  69: return "<keypad-plus>";
        case  71: return "<keypad-clear>";
        case  75: return "<keypad-divide>";
        case  76: return "<keypad-enter>";
        case  78: return "<keypad-minus>";
        case  81: return "<keypad-equals>";
        case  82: return "<keypad-0>";
        case  83: return "<keypad-1>";
        case  84: return "<keypad-2>";
        case  85: return "<keypad-3>";
        case  86: return "<keypad-4>";
        case  87: return "<keypad-5>";
        case  88: return "<keypad-6>";
        case  89: return "<keypad-7>";
        case  91: return "<keypad-8>";
        case  92: return "<keypad-9>";
        case  36: return "<return>";
        case  48: return "<tab>";
        case  49: return "<space>";
        case  51: return "<delete>";
        case  53: return "<escape>";
        case  55: return "<command>";
        case  56: return "<shift>";
        case  57: return "<capslock>";
        case  58: return "<option>";
        case  59: return "<control>";
        case  60: return "<right-shift>";
        case  61: return "<right-option>";
        case  62: return "<right-control>";
        case  63: return "<function>";
        case  64: return "<f17>";
        case  72: return "<volume-up>";
        case  73: return "<volume-down>";
        case  74: return "<mute>";
        case  79: return "<f18>";
        case  80: return "<f19>";
        case  90: return "<f20>";
        case  96: return "<f5>";
        case  97: return "<f6>";
        case  98: return "<f7>";
        case  99: return "<f3>";
        case 100: return "<f8>";
        case 101: return "<f9>";
        case 103: return "<f11>";
        case 105: return "<f13>";
        case 106: return "<f16>";
        case 107: return "<f14>";
        case 109: return "<f10>";
        case 111: return "<f12>";
        case 113: return "<f15>";
        case 114: return "<help>";
        case 115: return "<home>";
        case 116: return "<pageup>";
        case 117: return "<forward-delete>";
        case 118: return "<f4>";
        case 119: return "<end>";
        case 120: return "<f2>";
        case 121: return "<page-down>";
        case 122: return "<f1>";
        case 123: return "<left>";
        case 124: return "<right>";
        case 125: return "<down>";
        case 126: return "<up>";
    }
    return "<unknown>";
}

@end
