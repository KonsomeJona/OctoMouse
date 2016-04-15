#import "StatusItemView.h"

#import "InputEventsController.h"

@implementation StatusItemView {
    float _lastMouseLength;
    float _lastKeyboardLength;
}

@synthesize statusItem = _statusItem;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    _lastMouseLength = 0;
    _lastKeyboardLength = 0;
    
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveInputEventNotification:)
                                                 name:InputEventNotificationTag
                                               object:nil];
    
    return self;
}


#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
    Preferences* preferences = [Preferences shared];
    BOOL inverseColor = [preferences inverseIconColor];
    float thickness = [[NSStatusBar systemStatusBar] thickness];
    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSColor* color;
    if (self.isHighlighted != inverseColor)
        color = [NSColor whiteColor];
    else
        color = [NSColor blackColor];
    
    int menuBarStyle = preferences.menuBarStyle;
    
    if (menuBarStyle < 2) {
        int distanceUnit = [[Preferences shared] distanceUnit];
        
        NSImage *mouseIcon = (self.isHighlighted != inverseColor)  ? _alternateMouseImage : _mouseImage;
        NSImage *keyboardIcon = (self.isHighlighted != inverseColor) ? _alternateKeyboardImage : _keyboardImage;
        NSSize iconSize = [mouseIcon size];
        if(iconSize.width == 0)
            return;
        
        InputEventsLogger* global = [[InputEventsController shared] globalLogger];
        int mouseDown = [global mouseDown];
        NSString* mouseDownText = [NSString stringWithFormat:@"%d", mouseDown];
        
        NSString* mouseDistanceText = [global formattedMouseDistance:distanceUnit];
        
        int keyDown = [global keyDown];
        NSString* keyDownText = [NSString stringWithFormat:@"%d", keyDown];
        NSString* elapsedTimeText = [global formattedElapsedTime];
        
        NSString* longestMouseText;
        if([mouseDownText length] > [mouseDistanceText length])
            longestMouseText = mouseDownText;
        else
            longestMouseText = mouseDistanceText;
        
        NSString* longestKeyboardText;
        if([keyDownText length] > [elapsedTimeText length])
            longestKeyboardText = keyDownText;
        else
            longestKeyboardText = elapsedTimeText;
        
        // Default style
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSRightTextAlignment];
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
        NSFont *font = [NSFont fontWithName:@"Palatino-Roman" size:9.5];
        [attr setObject:font forKey:NSFontAttributeName];
        [attr setObject:color forKey:NSForegroundColorAttributeName];
        
        NSSize mouseTextSize = [longestMouseText boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, 0) options:0 attributes:attr].size;
        _lastMouseLength = MAX(mouseTextSize.width, _lastMouseLength);
        
        NSSize keyboardTextSize = [longestKeyboardText boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, 0) options:0 attributes:attr].size;
        _lastKeyboardLength = MAX(keyboardTextSize.width, _lastKeyboardLength);
        
        float margin = 5;
        float length = (margin + iconSize.width + margin + _lastKeyboardLength) * (1 - menuBarStyle) + (margin + iconSize.width + margin + _lastMouseLength + margin);
        [_statusItem setLength:length];
        
        float x = margin;
        NSPoint iconPoint = NSMakePoint(0, (thickness - iconSize.height) / 2);
        
        if (menuBarStyle < 1) {
            iconPoint.x = x;
            [keyboardIcon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            x += iconSize.width + margin;
            
            NSPoint keyDownPoint = NSMakePoint(x, 0);
            NSRect keyDownRect = NSMakeRect(keyDownPoint.x, keyDownPoint.y, _lastKeyboardLength, keyboardTextSize.height);
            [keyDownText drawInRect:keyDownRect withAttributes:attr];
            
            NSPoint elapsedTimePoint = NSMakePoint(x, thickness - mouseTextSize.height);
            NSRect elapsedTimeRect = NSMakeRect(elapsedTimePoint.x, elapsedTimePoint.y, _lastKeyboardLength, keyboardTextSize.height);
            [elapsedTimeText drawInRect:elapsedTimeRect withAttributes:attr];
            x += _lastKeyboardLength + margin;
        }
        
        iconPoint.x = x;
        [mouseIcon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        x += iconSize.width + margin;
        
        NSPoint mouseDistancePoint = NSMakePoint(x, 0);
        NSRect mouseDistanceRect = NSMakeRect(mouseDistancePoint.x, mouseDistancePoint.y, _lastMouseLength, mouseTextSize.height);
        [mouseDistanceText drawInRect:mouseDistanceRect withAttributes:attr];
        
        NSPoint mouseDownPoint = NSMakePoint(x, thickness - mouseTextSize.height);
        NSRect mouseDownRect = NSMakeRect(mouseDownPoint.x, mouseDownPoint.y, _lastMouseLength, mouseTextSize.height);
        [mouseDownText drawInRect:mouseDownRect withAttributes:attr];
    } else {
        float margin = 5;
        NSImage *mouseIcon = self.isHighlighted ? _alternateMouseImage : _mouseImage;
        NSSize iconSize = [mouseIcon size];
        if(iconSize.width == 0)
            return;
        
        float length = 2 * margin + iconSize.width;
        [_statusItem setLength:length];
        
        NSPoint iconPoint = NSMakePoint(margin, (thickness - iconSize.height) / 2);
        [mouseIcon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImagesWithMouse:(NSImage *)mouseImage keyboardImage:(NSImage *)keyboardImage speedometerImage:(NSImage *)speedometerImage
{
    _mouseImage = mouseImage;
    _keyboardImage = keyboardImage;
    _speedometerImage = speedometerImage;
    [self setNeedsDisplay:YES];
}

- (void)setAlternateImagesWithMouse:(NSImage *)mouseImage keyboardImage:(NSImage *)keyboardImage speedometerImage:(NSImage *)speedometerImage
{
    _alternateMouseImage = mouseImage;
    _alternateKeyboardImage = keyboardImage;
    _alternateSpeedometerImage = speedometerImage;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    return [self.window convertRectToScreen:frame];
}

- (void)receiveInputEventNotification:(NSNotification *) notification
{
    [self setNeedsDisplay:YES];
}
@end
