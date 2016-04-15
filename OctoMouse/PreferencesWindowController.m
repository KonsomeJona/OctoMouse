#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    Preferences *preferences = [Preferences shared];
    
    [_distanceUnitComboBox selectItemAtIndex:[preferences distanceUnit]];
    
    [_menuBarComboBox selectItemAtIndex:[preferences menuBarStyle]];
    
    int state = [preferences inverseIconColor]?NSOnState:NSOffState;
    [_inverseColorCheckBox setState:state];
    
    // Check if application is launching at startup
    state = [preferences launchAtStartup]?NSOnState:NSOffState;
    [_launchAtStartupCheckbox setState:state];
}

- (IBAction)onOKButtonClick:(id)sender {
    [self savePreferences];
    [NSApp endSheet:[self window]];
}

- (IBAction)onCancelButtonClick:(id)sender {
    [NSApp endSheet:[self window]];
}

- (void)savePreferences {
    Preferences *preferences = [Preferences shared];
    preferences.distanceUnit = (int) [_distanceUnitComboBox indexOfSelectedItem];
    preferences.menuBarStyle = (int) [_menuBarComboBox indexOfSelectedItem];
    
    BOOL inverseColor = [_inverseColorCheckBox state] == NSOnState;
    preferences.inverseIconColor = inverseColor;
    
    // Set launch at startup
    BOOL launchAtStartup = [_launchAtStartupCheckbox state] == NSOnState;
    preferences.launchAtStartup = launchAtStartup;
    
    [preferences save];
}

@end