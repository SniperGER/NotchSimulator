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
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		CGFloat notchWidth = MIN(screenWidth-166, 209);
		CGFloat notchOffset = MAX((screenWidth - notchWidth) / 2, 46);
		
#pragma mark - Notch
		notchIsVisible = YES;
		notch = [[UIView alloc] initWithFrame:frame];
		[self addSubview:notch];
		
		UIBezierPath* notchPath = [UIBezierPath bezierPath];
		[notchPath moveToPoint:CGPointMake(notchOffset - 6, 0)];
		[notchPath addCurveToPoint:CGPointMake(notchOffset, 6)
					 controlPoint1:CGPointMake((notchOffset - 6) + 3.31, 0)
					 controlPoint2:CGPointMake(notchOffset, 6 - 3.31)];
		[notchPath addLineToPoint:CGPointMake(notchOffset, 10)];
		[notchPath addCurveToPoint:CGPointMake(notchOffset + 20, 10 + 20)
					 controlPoint1:CGPointMake(notchOffset, 10 + 11.05)
					 controlPoint2:CGPointMake((notchOffset + 20) - 11.05, 10 + 20)];
		[notchPath addLineToPoint:CGPointMake((notchOffset + notchWidth) - 20, 30)];
		[notchPath addCurveToPoint:CGPointMake(notchOffset + notchWidth, 10)
					 controlPoint1:CGPointMake(((notchOffset + notchWidth) - 20) + 11.05, 10 + 20)
					 controlPoint2:CGPointMake(notchOffset + notchWidth, 10 + 11.05)];
		[notchPath addLineToPoint:CGPointMake(notchOffset + notchWidth, 6)];
		[notchPath addCurveToPoint:CGPointMake(notchOffset + notchWidth + 6, 0)
					 controlPoint1:CGPointMake(notchOffset + notchWidth, 6 - 3.31)
					 controlPoint2:CGPointMake((notchOffset + notchWidth + 6) - 3.31, 0)];
		
		[notchPath closePath];
		
		CAShapeLayer* notchLayer = [CAShapeLayer new];
		[notchLayer setPath:notchPath.CGPath];
		[notchLayer setFillColor:UIColor.blackColor.CGColor];
		[notch.layer addSublayer:notchLayer];
		
#pragma mark - Rounded Corners
		roundedCornersAreVisible = YES;
		roundedCorners = [[UIView alloc] initWithFrame:frame];
		[roundedCorners setBackgroundColor:[UIColor blackColor]];
		[self addSubview:roundedCorners];
		
		UIBezierPath* cutoutPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, screenWidth, screenHeight)];
		[cutoutPath appendPath:[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:40]];
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

- (BOOL)_ignoresHitTest {
	return YES;
}

@end
