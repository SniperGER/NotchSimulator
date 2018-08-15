#import <UIKit/UIKit.h>

@interface UIWindow (Secure)
- (void)_setSecure:(BOOL)arg1;
@end


@interface D22APWindow : UIWindow {
	BOOL notchIsVisible;
	BOOL roundedCornersAreVisible;
	UIView* notch;
	UIView* roundedCorners;
}

- (void)setNotchVisible:(BOOL)notchVisible roundedCornersVisible:(BOOL)roundedCornersVisible;

@end
