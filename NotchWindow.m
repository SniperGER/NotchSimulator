//
//  NotchWindow.m
//  NotchSimulator
//
//  Created by Janik Schmidt on 07.09.18.
//

#import "NotchWindow.h"

@implementation NotchWindow

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setUserInteractionEnabled:NO];
		[self setWindowLevel:UIWindowLevelAlert-100];
		[self _setSecure:YES];
		
		CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
		CGFloat notchWidth = MIN(screenWidth-166, 209);
		CGFloat notchOffset = MAX((screenWidth - notchWidth) / 2, 46);
		
#pragma mark - Notch
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
			notchIsVisible = YES;
			notch = [[UIView alloc] initWithFrame:frame];
			[notch setBackgroundColor:[UIColor blackColor]];
			[self addSubview:notch];
			
			UIBezierPath* notchPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, screenWidth, 30)];
			UIBezierPath* notchCutoutPath = [UIBezierPath bezierPath];
			[notchCutoutPath moveToPoint:CGPointMake(0, 0)];
			[notchCutoutPath addLineToPoint:CGPointMake(notchOffset - 6, 0)];
			[notchCutoutPath addCurveToPoint:CGPointMake(notchOffset, 6)
						 controlPoint1:CGPointMake((notchOffset - 6) + 3.31, 0)
						 controlPoint2:CGPointMake(notchOffset, 6 - 3.31)];
			[notchCutoutPath addLineToPoint:CGPointMake(notchOffset, 10)];
			[notchCutoutPath addCurveToPoint:CGPointMake(notchOffset + 20, 10 + 20)
						 controlPoint1:CGPointMake(notchOffset, 10 + 11.05)
						 controlPoint2:CGPointMake((notchOffset + 20) - 11.05, 10 + 20)];
			[notchCutoutPath addLineToPoint:CGPointMake((notchOffset + notchWidth) - 20, 30)];
			[notchCutoutPath addCurveToPoint:CGPointMake(notchOffset + notchWidth, 10)
						 controlPoint1:CGPointMake(((notchOffset + notchWidth) - 20) + 11.05, 10 + 20)
						 controlPoint2:CGPointMake(notchOffset + notchWidth, 10 + 11.05)];
			[notchCutoutPath addLineToPoint:CGPointMake(notchOffset + notchWidth, 6)];
			[notchCutoutPath addCurveToPoint:CGPointMake(notchOffset + notchWidth + 6, 0)
						 controlPoint1:CGPointMake(notchOffset + notchWidth, 6 - 3.31)
						 controlPoint2:CGPointMake((notchOffset + notchWidth + 6) - 3.31, 0)];
			[notchCutoutPath addLineToPoint:CGPointMake(screenWidth, 0)];
			[notchCutoutPath addLineToPoint:CGPointMake(screenWidth, 30)];
			[notchCutoutPath addLineToPoint:CGPointMake(0, 30)];
			[notchCutoutPath closePath];
			
			[notchPath appendPath:notchCutoutPath];
			[notchPath setUsesEvenOddFillRule:YES];
//			[notchPath moveToPoint:CGPointMake(notchOffset - 6, 0)];
//			[notchPath addCurveToPoint:CGPointMake(notchOffset, 6)
//						 controlPoint1:CGPointMake((notchOffset - 6) + 3.31, 0)
//						 controlPoint2:CGPointMake(notchOffset, 6 - 3.31)];
//			[notchPath addLineToPoint:CGPointMake(notchOffset, 10)];
//			[notchPath addCurveToPoint:CGPointMake(notchOffset + 20, 10 + 20)
//						 controlPoint1:CGPointMake(notchOffset, 10 + 11.05)
//						 controlPoint2:CGPointMake((notchOffset + 20) - 11.05, 10 + 20)];
//			[notchPath addLineToPoint:CGPointMake((notchOffset + notchWidth) - 20, 30)];
//			[notchPath addCurveToPoint:CGPointMake(notchOffset + notchWidth, 10)
//						 controlPoint1:CGPointMake(((notchOffset + notchWidth) - 20) + 11.05, 10 + 20)
//						 controlPoint2:CGPointMake(notchOffset + notchWidth, 10 + 11.05)];
//			[notchPath addLineToPoint:CGPointMake(notchOffset + notchWidth, 6)];
//			[notchPath addCurveToPoint:CGPointMake(notchOffset + notchWidth + 6, 0)
//						 controlPoint1:CGPointMake(notchOffset + notchWidth, 6 - 3.31)
//						 controlPoint2:CGPointMake((notchOffset + notchWidth + 6) - 3.31, 0)];
//			
//			[notchPath closePath];
			
			CAShapeLayer* notchLayer = [CAShapeLayer new];
			[notchLayer setPath:notchPath.CGPath];
			[notchLayer setFillColor:UIColor.blackColor.CGColor];
			[notchLayer setFillRule:kCAFillRuleEvenOdd];
			[notch.layer setMask:notchLayer];
			
			// Let's try some more detail, shall we?
#define CGRectSetX(rect, x) CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height)
			notchDetailIsVisible = YES;
			
			notchDetail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notch_detail" inBundle:[NSBundle bundleWithPath:@"/Library/Application Support/NotchSimulator"] compatibleWithTraitCollection:nil]];
			[notchDetail setFrame:CGRectSetX(notchDetail.frame, notchOffset + 20)];
//			[notch addSubview:notchDetail];
		}
		
		
#pragma mark - Rounded Corners
		roundedCornersAreVisible = YES;
		roundedCorners = [[UIView alloc] initWithFrame:frame];
		[roundedCorners setBackgroundColor:[UIColor blackColor]];
		[self addSubview:roundedCorners];
		
		CGFloat cornerRadius = 0;
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
			cornerRadius = 40;
		} else {
			cornerRadius = 18;
		}
		
		UIBezierPath* cutoutPath = [UIBezierPath bezierPathWithRect:frame];
		[cutoutPath appendPath:[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius]];
		[cutoutPath setUsesEvenOddFillRule:YES];
		
		CAShapeLayer* maskLayer = [CAShapeLayer layer];
		[maskLayer setPath:cutoutPath.CGPath];
		[maskLayer setFillColor:[UIColor blackColor].CGColor];
		[maskLayer setFillRule:kCAFillRuleEvenOdd];
		[roundedCorners.layer setMask:maskLayer];
	}
	
	return self;
}

- (void)setNotchVisible:(BOOL)notchVisible roundedCornersVisible:(BOOL)roundedCornersVisible {
	if (notchVisible != notchIsVisible) {
		notchIsVisible = notchVisible;
		
		[notch setHidden:!notchVisible];
	}
	
	if (roundedCornersVisible != roundedCornersAreVisible) {
		roundedCornersAreVisible = roundedCornersVisible;
		
		[roundedCorners setHidden:!roundedCornersVisible];
	}
}

- (void)setNotchDetailVisible:(BOOL)notchDetailVisible {
	if (notchDetailVisible != notchDetailIsVisible) {
		notchDetailIsVisible = notchDetailVisible;
		
		[notchDetail setHidden:!notchDetailVisible];
	}
}

- (BOOL)_ignoresHitTest {
	return YES;
}

@end
