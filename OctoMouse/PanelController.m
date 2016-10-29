#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define POPUP_HEIGHT 190
#define PANEL_WIDTH 280
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController {
    BOOL _displayAboutWhenOpen;
}

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    _lockPanel = false;
    
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    Preferences *preferences = [Preferences shared];
    _displayAboutWhenOpen = [preferences isFirstLaunch];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveInputEventNotification:)
                                                 name:InputEventNotificationTag
                                               object:nil];
    
    [self receiveInputEventNotification:nil];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if(_lockPanel) {
        return;
    }
    
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.size.height = POPUP_HEIGHT;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:panel];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    // Get focus
    NSApplication *myApp = [NSApplication sharedApplication];
    [myApp activateIgnoringOtherApps:YES];
    [self.window orderFrontRegardless];
    
    /*
     Show directly About when it is the first time it is launched in order
     to let the user knows he has to enable the key pressed counter feature.
     */
    if(_displayAboutWhenOpen) {
        _displayAboutWhenOpen = NO;
        [self showAbout:nil];
    }
    
    // Hide menu item if application is added to privacy and accessibility list
    bool enable = AXIsProcessTrustedWithOptions(nil);
    [_enableAccessibilityMenuItem setHidden:enable];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        [self.window orderOut:nil];
    });
}

- (IBAction)showAbout:(id)sender {
    if(_aboutWindowController == nil) {
        _aboutWindowController = [[AboutWindowController alloc]
                                  initWithWindowNibName:@"AboutWindow"];
    }
    
    _lockPanel = true;
    [NSApp beginSheet:[_aboutWindowController window]
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(aboutDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
}

- (BOOL) hasLeadingNumberInString:(NSString*)s {
    if (s)
        return [s length] && isnumber([s characterAtIndex:0]);
    else
        return NO;
}


- (IBAction)exportStatistics:(id)sender {
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    [savePanel setNameFieldStringValue:@"*.csv"];
    long result	= [savePanel runModal];
    
    if(result == NSOKButton){
        NSURL *fileURL = [savePanel URL];
        NSString *filePath = [fileURL path];
        
        [self writeStatistics:filePath];
    }
}

- (void)writeStatistics:(NSString *)filePath {
    // No worries about the capacity, it will expand as necessary.
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
    [writeString appendString:@"date,elapsed seconds,mouse clicks,mouse distance,scroll distance,keystrokes\n"];
    
    int distanceUnit = [[Preferences shared] distanceUnit];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *keys = [[defaults dictionaryRepresentation] allKeys];
    
    // Sort keys alphabetically to have the statistics ordered by date.
    keys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for(NSString* key in keys) {
        /*
         * If first character in key is not a digit,
         * then the data is not a statistics.
         * This is to avoid the application preferences or
         * other Apple data to be included in the file.
         */
        if([self hasLeadingNumberInString:key] == NO)
            continue;
        
        InputEventsLogger *data = [[InputEventsLogger alloc] initWithIdentifier:key];
        [data load];
        
        float mouseDistance = (distanceUnit == 1)?[data mouseDistanceInMiles]:[data mouseDistanceInKilometers];
        float scrollWheelDistance = (distanceUnit == 1)?[data scrollWheelDistanceInMiles]:[data scrollWheelDistanceInKilometers];
        
        [writeString appendFormat:@"%@,%d,%d,%.2f,%.2f,%d\n", key, [data elapsedTime], [data mouseDown], mouseDistance, scrollWheelDistance, [data keyDown]];
    }
    
    NSData *fileContents = [writeString dataUsingEncoding:NSUTF8StringEncoding];
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:filePath
                                                           contents:fileContents
                                                         attributes:nil];
    
    if (success == NO) {
        NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
    }

}

- (IBAction)showPreferences:(id)sender {
    if(_preferencesWindowController == nil) {
        _preferencesWindowController = [[PreferencesWindowController alloc]
                                        initWithWindowNibName:@"PreferencesWindow"];
    }
    
    _lockPanel = true;
    [NSApp beginSheet:[_preferencesWindowController window]
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(aboutDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
}

- (IBAction)enableAccessibility:(id)sender {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    bool enable = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    [_enableAccessibilityMenuItem setHidden:enable];
}

- (IBAction)supportUs:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: SUPPORT_URL]];
}

- (void)aboutDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    _lockPanel = false;
}

- (IBAction)quitApplication:(id)sender {
    [NSApp terminate:self];
}

- (void)receiveInputEventNotification:(NSNotification *) notification
{
    int distanceUnit = [[Preferences shared] distanceUnit];
    
    InputEventsLogger* global = [[InputEventsController shared] globalLogger];
    
    [_elapsedTimeLabel setStringValue: [global formattedElapsedTime]];
    [_mouseDistanceLabel setStringValue: [global formattedMouseDistance:distanceUnit]];
    [_mouseDownLabel setStringValue: [NSString stringWithFormat:@"%d", [global mouseDown]]];
    [_scrollWheelLabel setStringValue: [global formattedScrollWheelDistance:distanceUnit]];
    [_keyDownLabel setStringValue: [NSString stringWithFormat:@"%d", [global keyDown]]];
    
    InputEventsLogger* today = [[InputEventsController shared] todayLogger];
    
    [_todayElapsedTimeLabel setStringValue: [today formattedElapsedTime]];
    [_todayMouseDistanceLabel setStringValue: [today formattedMouseDistance:distanceUnit]];
    [_todayMouseDownLabel setStringValue: [NSString stringWithFormat:@"%d", [today mouseDown]]];
    [_todayScrollWheelLabel setStringValue: [today formattedScrollWheelDistance:distanceUnit]];
    [_todayKeyDownLabel setStringValue: [NSString stringWithFormat:@"%d", [today keyDown]]];
    
    InputEventsLogger* yesterday = [[InputEventsController shared] yesterdayLogger];
    
    [_yesterdayElapsedTimeLabel setStringValue: [yesterday formattedElapsedTime]];
    [_yesterdayMouseDistanceLabel setStringValue: [yesterday formattedMouseDistance:distanceUnit]];
    [_yesterdayMouseDownLabel setStringValue: [NSString stringWithFormat:@"%d", [yesterday mouseDown]]];
    [_yesterdayScrollWheelLabel setStringValue: [yesterday formattedScrollWheelDistance:distanceUnit]];
    [_yesterdayKeyDownLabel setStringValue: [NSString stringWithFormat:@"%d", [yesterday keyDown]]];
}


@end
