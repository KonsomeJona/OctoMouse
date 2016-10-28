#import "Preferences.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "InputEventsController.h"
#import "PreferencesWindowController.h"
#import "AboutWindowController.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    
    // General
    __unsafe_unretained IBOutlet NSTextField *_elapsedTimeLabel;
    __unsafe_unretained IBOutlet NSTextField *_mouseDownLabel;
    __unsafe_unretained IBOutlet NSTextField *_mouseDistanceLabel;
    __unsafe_unretained IBOutlet NSTextField *_scrollWheelLabel;
    __unsafe_unretained IBOutlet NSTextField *_keyDownLabel;
    
    // Today
    __unsafe_unretained IBOutlet NSTextField *_todayElapsedTimeLabel;
    __unsafe_unretained IBOutlet NSTextField *_todayMouseDownLabel;
    __unsafe_unretained IBOutlet NSTextField *_todayMouseDistanceLabel;
    __unsafe_unretained IBOutlet NSTextField *_todayScrollWheelLabel;
    __unsafe_unretained IBOutlet NSTextField *_todayKeyDownLabel;
    
    // Yesterday
    __unsafe_unretained IBOutlet NSTextField *_yesterdayElapsedTimeLabel;
    __unsafe_unretained IBOutlet NSTextField *_yesterdayMouseDownLabel;
    __unsafe_unretained IBOutlet NSTextField *_yesterdayMouseDistanceLabel;
    __unsafe_unretained IBOutlet NSTextField *_yesterdayScrollWheelLabel;
    __unsafe_unretained IBOutlet NSTextField *_yesterdayKeyDownLabel;
    
    __weak IBOutlet NSMenuItem *_enableAccessibilityMenuItem;
    
    BOOL _lockPanel;
    PreferencesWindowController *_preferencesWindowController;
    AboutWindowController *_aboutWindowController;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;

@end
