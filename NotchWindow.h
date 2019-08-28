//
//  NotchWindow.h
//  NotchSimulator
//
//  Created by Janik Schmidt on 07.09.18.
//

#import <UIKit/UIKit.h>

@interface UIWindow (Secure)
- (void)_setSecure:(BOOL)arg1;
- (void)_setHidden:(BOOL)arg1 forced:(BOOL)arg2;
@end

@interface NotchWindow : UIWindow {
	UIBezierPath* notchPath;
	UIBezierPath* roundedCornersPath;
	
	BOOL notchIsVisible;
	BOOL roundedCornersAreVisible;
	BOOL notchDetailIsVisible;
	UIView* notch;
	UIView* roundedCorners;
	UIImageView* notchDetail;
}

- (void)setNotchVisible:(BOOL)notchVisible roundedCornersVisible:(BOOL)roundedCornersVisible;
- (void)setNotchDetailVisible:(BOOL)notchDetailVisible;

@end
