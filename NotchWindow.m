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
		[self setUserInteractionEnabled:YES];
		[self setWindowLevel:UIWindowLevelAlert-100];
		[self _setSecure:YES];
		
		CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		CGFloat notchWidth = MIN(screenWidth-166, 209);
		CGFloat notchOffset = MAX((screenWidth - notchWidth) / 2, 46);
		
#pragma mark - Notch
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
			notchIsVisible = YES;
			notch = [[UIView alloc] initWithFrame:frame];
			[notch setBackgroundColor:[UIColor blackColor]];
			[self addSubview:notch];
			
			notchPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, screenWidth, screenHeight + 40)];
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
			[notchCutoutPath addLineToPoint:CGPointMake(screenWidth, screenHeight + 40)];
			[notchCutoutPath addLineToPoint:CGPointMake(0, screenHeight + 40)];
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
			notchDetailIsVisible = NO;
			
			notchDetail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notch_detail" inBundle:[NSBundle bundleWithPath:@"/Library/Application Support/NotchSimulator"] compatibleWithTraitCollection:nil]];
			[notchDetail setFrame:CGRectSetX(notchDetail.frame, notchOffset + 20)];
			[notchDetail setHidden:!notchDetailIsVisible];
			[notch addSubview:notchDetail];
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
		
		roundedCornersPath = [UIBezierPath bezierPathWithRect:frame];
		[roundedCornersPath appendPath:[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius]];
		[roundedCornersPath setUsesEvenOddFillRule:YES];
		
		CAShapeLayer* maskLayer = [CAShapeLayer layer];
		[maskLayer setPath:roundedCornersPath.CGPath];
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

- (void)setNotchVisible:(BOOL)notchVisible animated:(BOOL)animated {
	[UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
		[notch setTransform:CGAffineTransformMakeTranslation(0, notchVisible ? 0 : -40)];
	}];
}

- (void)setRoundedCornersVisible:(BOOL)roundedCornersVisibleVisible animated:(BOOL)animated {
	CGFloat scale = 1.0626;
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) scale = 1.0282;
		
	[UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
		[roundedCorners setTransform:CGAffineTransformMakeScale(roundedCornersVisibleVisible ? 1 : 1.0626, roundedCornersVisibleVisible ? 1 : 1.0626)];
	}];
}

- (void)setNotchDetailVisible:(BOOL)notchDetailVisible {
	if (notchDetailVisible != notchDetailIsVisible) {
		notchDetailIsVisible = notchDetailVisible;
		
		[notchDetail setHidden:!notchDetailVisible];
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (notchIsVisible && CGPathContainsPoint(notchPath.CGPath, nil, point, true)) {
		return self;
	}
	
	if (roundedCornersAreVisible && CGPathContainsPoint(roundedCornersPath.CGPath, nil, point, true)) {
		return self;
	}
	
	return nil;
}

@end
