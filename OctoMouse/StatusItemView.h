#import "Preferences.h"

@interface StatusItemView : NSView {
@private
    NSImage *_mouseImage;
    NSImage *_alternateMouseImage;
    NSImage *_keyboardImage;
    NSImage *_alternateKeyboardImage;
    NSImage *_speedometerImage;
    NSImage *_alternateSpeedometerImage;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
    SEL _action;
    __unsafe_unretained id _target;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

- (void)setImagesWithMouse:(NSImage *)mouseImage keyboardImage:(NSImage *)keyboardImage speedometerImage:(NSImage *)speedometerImage;
- (void)setAlternateImagesWithMouse:(NSImage *)mouseImage keyboardImage:(NSImage *)keyboardImage speedometerImage:(NSImage *)speedometerImage;

@end
