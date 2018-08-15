#import "ProudLock.h"

static NSDictionary* latchPreferences;
static SBDashBoardProudLockViewController* proudLockViewController;
static SBUIProudLockIconView* proudLockIconView;

static CGFloat yOffset = 0;

%hook SBDashBoardViewController
- (void)loadView {
	proudLockViewController = MSHookIvar<SBDashBoardProudLockViewController*>(self, "_proudLockViewController");
	if (!proudLockViewController) {
		proudLockViewController = [%c(SBDashBoardProudLockViewController) new];
		MSHookIvar<SBDashBoardProudLockViewController*>(self,"_proudLockViewController") = proudLockViewController;
	}
	
	%orig;
}
%end    // %hook SBDashBoardViewController



%hook SBDashBoardView
- (void)layoutSubviews {
	%orig;
	
	proudLockIconView = MSHookIvar<SBUIProudLockIconView*>(self, "_proudLockIconView");
	if (!proudLockIconView) {
		proudLockIconView = (SBUIProudLockIconView*)proudLockViewController.view;
		MSHookIvar<SBUIProudLockIconView*>(self, "_proudLockIconView") = proudLockIconView;
		
		[[[self subviews] lastObject] addSubview:proudLockIconView];
		[proudLockViewController _setIconVisible:YES animated:NO];
		[proudLockViewController _setIconState:1 animated:NO];
	}
}
%end    // %hook SBDashBoardView



%hook SBDashBoardPasscodeViewController
- (void)viewWillAppear:(BOOL)arg1 {
	MSHookIvar<SBUIProudLockIconView*>(self, "_proudLockIconViewToUpdate") = proudLockIconView;
}
%end



%hook SBFLockScreenDateView
- (void)layoutSubviews {
	%orig;
	
	UIView* timeView = MSHookIvar<UIView*>(self, "_timeLabel");
	CGRect timeViewRect = timeView.frame;
	timeViewRect.origin.y = (35 + yOffset);
	[timeView setFrame:timeViewRect];
	
	UIView* dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
	CGRect dateSubtitleRect = dateSubtitleView.frame;
	dateSubtitleRect.origin.y = timeViewRect.size.height + (35 + yOffset) - 7;
	[dateSubtitleView setFrame:dateSubtitleRect];
	
	UIView* customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
	CGRect customSubtitleRect = customSubtitleView.frame;
	customSubtitleRect.origin.y = timeViewRect.size.height + (35 + yOffset) - 7;
	[customSubtitleView setFrame:customSubtitleRect];
}
%end	// %hook SBFLockScreenDateView



%hook WGWidgetGroupViewController
- (void)viewDidLayoutSubviews {
	CGRect origFrame = self.view.frame;
	origFrame.origin.y = (35 + yOffset);
	[self.view setFrame:origFrame];
	
	%orig;
}
%end	// %hook WGWidgetGroupViewController



%hook NCNotificationListCollectionView
- (void)setFrame:(CGRect)arg1 {
	arg1.origin.y = (35 + yOffset);
	%orig(arg1);
}

- (CGRect)frame {
	CGRect r = %orig;
	r.origin.y = (35 + yOffset);
	return r;
}
%end	// %hook NCNotificationListCollectionView



%hook SBDashBoardAdjunctListView
- (void)setFrame:(CGRect)arg1 {
	arg1.origin.y += (35 + yOffset);
	%orig(arg1);
}
%end	// %hook NCNotificationListCollectionView



%hook SBUIProudLockIconView
- (void)setTransform:(CGAffineTransform)arg1 {
	%orig(CGAffineTransformMakeTranslation(0, yOffset));
}
%end    // %hook SBUIProudLockIconView



%hook SBUICAPackageView
- (id)initWithPackageName:(id)arg1 inBundle:(id)arg2 {
	NSBundle* themeBundle = [NSBundle bundleWithPath:@"/Library/Application Support/NotchSimulator/biglock_fixed.bundle"];
	return %orig(@"biglock_fixed", themeBundle);
}
%end    // %hook SBUICAPackageView



%ctor {
	if (access(DPKG_PATH, F_OK) != -1) {
		latchPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
		
		BOOL enabled = (BOOL)[[latchPreferences objectForKey:@"enabled"] ?: @YES boolValue];
		BOOL latchEnabled = (BOOL)[[latchPreferences objectForKey:@"latchEnabled"] ?: @YES boolValue];
		yOffset = (CGFloat)[[latchPreferences objectForKey:@"latchOffsetY"] ?: @0  floatValue];
		
		if (enabled && latchEnabled) {
			%init();
		}
	}
}
