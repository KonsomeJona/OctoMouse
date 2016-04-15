#import <Cocoa/Cocoa.h>

#import "Preferences.h"

@interface PreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSComboBox *distanceUnitComboBox;
@property (weak) IBOutlet NSComboBox *menuBarComboBox;
@property (weak) IBOutlet NSButton *launchAtStartupCheckbox;
@property (weak) IBOutlet NSButton *inverseColorCheckBox;


- (IBAction)onOKButtonClick:(id)sender;
- (IBAction)onCancelButtonClick:(id)sender;

@end
