#import "AboutWindowController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void) mouseDown: (NSEvent*) theEvent {
    [NSApp endSheet:[self window]];
}

@end
