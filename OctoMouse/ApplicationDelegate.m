#import "ApplicationDelegate.h"

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Load preferences
    Preferences *preferences = [Preferences shared];
    [preferences load];
    
    // Set launch at startup by default
    if([preferences isFirstLaunch]) {
        [preferences setLaunchAtStartup:YES];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: SUPPORT_URL]];
    }
    
    // Start listening user inputs
    [[InputEventsController shared] startListening];
    [[InputEventsController shared] startListening];
    [[InputEventsController shared] startListening];
    
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
}

- (void)applicationWillBecomeActive:(NSNotification *)aNotification
{
    // Start listening user inputs
    [[InputEventsController shared] startListening];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    
    // Stop listening user inputs
    [[InputEventsController shared] stopListening];
    
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

@end
