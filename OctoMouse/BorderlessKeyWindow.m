#import "BorderlessKeyWindow.h"

@implementation BorderlessKeyWindow

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

@end
