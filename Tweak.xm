//
//  Tweak.xm
//  Notch'd
//
//  Created by Janik Schmidt on 03.01.19.
//

#include "Tweak.h"



#pragma mark - Hooks
%group SpringBoard
static void bundleIdentifierBecameVisible(NSString* bundleIdentifier) {	
	notchPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
	
	if (bundleIdentifier && notchPreferences) {
		NSDictionary* appPreferences = [notchPreferences objectForKey:bundleIdentifier];
		
		if (appPreferences) {
			BOOL _enabled = (BOOL)[[appPreferences objectForKey:@"enabled"] ?: @YES boolValue];
			BOOL _showNotch = (BOOL)[[appPreferences objectForKey:@"showNotch"] ?: @YES boolValue];
			BOOL _showRoundedCorners = (BOOL)[[appPreferences objectForKey:@"showRoundedCorners"] ?: @YES boolValue];
			
			[notchWindow setNotchVisible:_enabled && _showNotch animated:YES];
			[notchWindow setRoundedCornersVisible:_enabled && _showRoundedCorners animated:YES];
		}
	}
}
static void bundleIdentifierBecameHidden(NSString* bundleIdentifier) {
	[notchWindow setNotchVisible:YES animated:YES];
	[notchWindow setRoundedCornersVisible:YES animated:YES];
}

%hook SpringBoard
%property (nonatomic, retain) NotchWindow* notchWindow;
/**
 * Initialize Notch and Rounded Corners overlay
 */
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	
	CGRect notchFrame = UIScreen.mainScreen.bounds;
	if (isIpad) {
		if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
			notchFrame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width);
		} else {
			notchFrame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
		}

	}
	
	self.notchWindow = [[NotchWindow alloc] initWithFrame:notchFrame];
	notchWindow = self.notchWindow;
	
	[self.notchWindow setNotchVisible:notchVisible roundedCornersVisible:roundedCornersVisible];
	[self.notchWindow setNotchDetailVisible:notchDetailVisible];
	[self.notchWindow makeKeyAndVisible];
	
	if (isPeace) {
		[[%c(SBReachabilityManager) sharedInstance] ignoreWindowForReachability:self.notchWindow];
	}
}

/**
 * Hide the Notch overlay if the user takes a screenshot
 */
- (void)takeScreenshotAndEdit:(BOOL)arg1 {
	if (hideInScreenshots) {
		[self.notchWindow setHidden:YES];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			%orig;
		});
	} else {
		%orig;
	}
}

- (void)screenCapturer:(id)arg1 didCaptureScreenshotsOfScreens:(id)arg2 {
	%orig;
	
	[self.notchWindow setHidden:NO];
}
%end    /// %hook SpringBoard

/**
 * Show and hide the Notch overlay in various situations
 */
%hook SBMainWorkspace
- (BOOL)_preflightTransitionRequest:(SBMainWorkspaceTransitionRequest*)arg1 {
	long long environmentMode = arg1.applicationContext.layoutState.unlockedEnvironmentMode;
	
	if (environmentMode == 3 && arg1.applicationContext.layoutState.elements.allObjects.count) {
		NSString* bundleIdentifier = arg1.applicationContext.layoutState.elements.allObjects[0].identifier;
		
		bundleIdentifierBecameVisible(bundleIdentifier);
	} else {
		bundleIdentifierBecameHidden(nil);
	}
	
	return %orig;
}
%end	/// %hook SBMainWorkspace

%hook SBFluidSwitcherViewController
- (void)sceneLayoutControllerDidEndLayoutStateTransition:(SBWorkspaceApplicationSceneTransitionContext*)arg1 wasInterrupted:(BOOL)arg2 {
	if (arg1.layoutState.elements.allObjects.count) {
		long long environmentMode = arg1.layoutState.unlockedEnvironmentMode;
		NSString* bundleIdentifier = arg1.layoutState.elements.allObjects[0].identifier;
		
		switch (environmentMode) {
			case 1:
			case 2:
				bundleIdentifierBecameHidden(nil);
				break;
			case 3:
				bundleIdentifierBecameVisible(bundleIdentifier);
				break;
		}
	}
	
	%orig;
}
%end	/// %hook SBFluidSwitcherViewController

/**
 * Handle started fluid gestures
 */
%hook SBFluidSwitcherGestureWorkspaceTransaction
- (void)_beginWithGesture:(id)arg1 {
    bundleIdentifierBecameHidden(nil);
	
    %orig;
}
%end	/// %hook SBFluidSwitcherGestureWorkspaceTransaction

/**
 * Handle device wake
 */
%hook SBScreenWakeAnimationController
- (void)_handleAnimationCompletionIfNecessaryForWaking:(BOOL)arg1 {
	if (!arg1) {
		bundleIdentifierBecameHidden(nil);
	}
	
	%orig;
}
%end	/// %hook SBScreenWakeAnimationController

/**
 * Handle transitions to CoverSheet
 */
%hook SBCoverSheetPrimarySlidingViewController
- (void)_beginTransitionFromAppeared:(BOOL)arg1 {
	bundleIdentifierBecameHidden(nil);
	
	%orig;
}

- (void)_endTransitionToAppeared:(BOOL)arg1 {
	SBApplication* frontMostApplication = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];

	if (!arg1 == 1 && frontMostApplication) {
		bundleIdentifierBecameVisible(frontMostApplication.bundleIdentifier);
	}
	
	%orig;
}
%end	/// %hook SBCoverSheetPrimarySlidingViewController
%end    // %group SpringBoard

%group D2xAP
/**
 * Disable Home Screen rotation
 */
%hook SpringBoard
- (long long) homeScreenRotationStyle {
	if (disableHomeScreenRotation && !isIpad) return 0;
	return %orig;
}
%end    /// %hook SpringBoard

%hook SBHomeScreenViewController
- (NSInteger)supportedInterfaceOrientations {
	if (disableHomeScreenRotation && !isIpad) return UIInterfaceOrientationMaskPortrait;
	return %orig;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)arg1 {
	if (disableHomeScreenRotation && isIpad) return YES;
	return %orig;
}
%end	/// %hook SBHomeScreenViewController

%hook SBDeckSwitcherPersonality
/**
 * Round those corners!
 */
- (double)_cardCornerRadiusInAppSwitcher {
	if (roundedCornersVisible) return isIpad ? 13.5 : 27.3;
	return %orig;
}
%end	/// %hook SBDeckSwitcherPersonality

/**
 * Reduce the icon row count by 1 if enabled
 */
%hook SBIconListView
+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(UIInterfaceOrientation)arg1 {
	if (isIpad) return %orig;
	
	NSUInteger r = %orig;
	if (UIInterfaceOrientationIsLandscape(arg1)) {
		return r;
	} else if (reduceIconRows) {
		return r - 1;
	}
	
	return r;
}
%end	/// %hook SBIconListView

/**
 * Set the App Switcher kill style
 * 1 = Hold, 2 = Swipe
 * Limited to iOS 11
 */
%hook SBAppSwitcherSettings
- (NSInteger)effectiveKillAffordanceStyle {
	return isPeace ? %orig : switcherKillStyle;
}

- (NSInteger)killAffordanceStyle {
	return isPeace ? %orig : switcherKillStyle;
}

- (void)setKillAffordanceStyle:(NSInteger)style {
	%orig(isPeace ? style : switcherKillStyle);
}
%end	/// %hook SBAppSwitcherSettings

/**
 * Make the dock inset
 */
%hook SBDockView
- (BOOL)isDockInset {
	if (!modernDock && !isIpad) return NO;
	return %orig;
}
%end	/// %hook SBDockView

/**
 * Show the Control Center animation on the lock screen
 */
%hook SBDashBoardTeachableMomentsContainerViewController
- (BOOL)_shouldTeachAboutControlCenter {
	return YES;
}
%end	/// %hook SBDashBoardTeachableMomentsContainerViewController

%hook SBDashBoardQuickActionsView

- (void)_layoutQuickActionButtons {
	%orig;
	
	if (!isPeace) return;
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
	for (UIView* subview in self.subviews) {
		if (subview.frame.size.width < 50) {
			if (subview.frame.origin.x < UIScreen.mainScreen.bounds.size.width / 2) {
				CGRect _frame = subview.frame;
				_frame = CGRectMake(46, _frame.origin.y - 90, 50, 50);
				subview.frame = _frame;
				[subview sb_removeAllSubviews];
				
				[subview init];
			} else {
				CGRect _frame = subview.frame;
				_frame = CGRectMake(subview.superview.frame.size.width - 96, _frame.origin.y - 90, 50, 50);
				subview.frame = _frame;
				[subview sb_removeAllSubviews];
				
				[subview init];
#pragma clang diagnostic pop
			}
		}
	}
}

%end	/// %hook SBDashBoardQuickActionsView
%end	// %group D2xAP

%group ProudLock
%hook SBUICAPackageView
/**
 * Replace the path for the CAML bundle with our own
 */
- (id)initWithPackageName:(id)arg1 inBundle:(id)arg2 {
	if (TARGET_OS_SIMULATOR) return %orig;
	return %orig(arg1, [NSBundle bundleWithPath:@"/Library/Application Support/NotchSimulator"]);
}
%end	/// %hook SBUICAPackageView

/**
 * Make the padlock visible on iOS 11
 */
%hook SBDashBoardView
- (void)layoutSubviews {
	%orig;
	
	if (!isPeace) {
		SBUIProudLockIconView* proudLockIconView = MSHookIvar<SBUIProudLockIconView*>(self, "_proudLockIconView");
		if (proudLockIconView) {
			SBDashBoardProudLockViewController* proudLockViewController = (SBDashBoardProudLockViewController*)proudLockIconView.nextResponder;
			
			[proudLockViewController _setIconVisible:YES animated:NO];
			[proudLockViewController _setIconState:1 animated:NO];
		}
	}
}
%end	/// %hook SBDashBoardView

/**
 * Make the passcode lockscreen show the Face ID glyph instead of Touch ID
 */
%hook PKGlyphView
- (void)setHidden:(BOOL)arg1 {
	if ([self.superview isKindOfClass:%c(SBUIPasscodeBiometricAuthenticationView)]) {
		%orig(NO);
		return;
	}
	
	%orig;
}

- (BOOL)hidden {
	if ([self.superview isKindOfClass:%c(SBUIPasscodeBiometricAuthenticationView)]) {
		return NO;
	}
	
	return %orig;
}
%end	/// %hook PKGlyphView

%hook SBUIBiometricResource
- (id)init {
	id r = %orig;
	
	MSHookIvar<BOOL>(r, "_hasMesaHardware") = NO;
	MSHookIvar<BOOL>(r, "_hasPearlHardware") = YES;
	
	return r;
}
%end	/// %hook SBUIBiometricResource

/**
 * Fix offsets
 */
static CGFloat offset = 0;

%hook SBDashBoardViewController
- (void)loadView {
	if (%c(JPWeatherManager) != nil) {
		%orig;
		return;
	}
	
	CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
	if (screenWidth <= 320) {
		offset = 20;
	} else if (screenWidth <= 375) {
		offset = 35;
	} else if (screenWidth <= 414) {
		offset = 28;
	}
	
	%orig;
}

/**
 * Add support for "Rest to unlock"
 */
- (void)handleBiometricEvent:(unsigned long long)arg1 {
	%orig;

	if (arg1 == kBiometricEventMesaSuccess) {
		SBDashBoardMesaUnlockBehaviorConfiguration* unlockBehavior = MSHookIvar<SBDashBoardMesaUnlockBehaviorConfiguration*>(self, "_mesaUnlockBehaviorConfiguration");
		if ([unlockBehavior _isAccessibilityRestingUnlockPreferenceEnabled]) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[[%c(SBLockScreenManager) sharedInstance] _finishUIUnlockFromSource:12 withOptions:nil];
			});
		}
	}
}
%end	/// %hook SBDashBoardViewController

/**
 * Fix the position of the padlock on the passcode screen
 */
%hook SBFLockScreenDateView
- (void)layoutSubviews {
	%orig;
	
	if (%c(JPWeatherManager) != nil || UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
		return;
	}

	UIView* timeView = MSHookIvar<UIView*>(self, "_timeLabel");
	UIView* dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
	UIView* customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
	
	[timeView setFrame:CGRectSetY(timeView.frame, timeView.frame.origin.y + offset)];
	[dateSubtitleView setFrame:CGRectSetY(dateSubtitleView.frame, dateSubtitleView.frame.origin.y + offset)];
	[customSubtitleView setFrame:CGRectSetY(customSubtitleView.frame, customSubtitleView.frame.origin.y + offset)];
}
%end	/// %hook SBFLockScreenDateView

%hook NCNotificationListCollectionView
- (void)setFrame:(CGRect)frame {
	if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
		%orig;
		return;
	}
	
	%orig(CGRectSetY(frame, frame.origin.y + offset));
}
%end	/// %hook NCNotificationListCollectionView

%hook SBDashBoardTodayPageView
- (void)setFrame:(CGRect)arg1 {
	if ([self presentingViewOfClass:%c(SBCoverSheetPositionView)] && !UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
		%orig(CGRectMake(0, offset, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - offset));
	} else {
		%orig;
	}
}

%new
- (UIView*)presentingViewOfClass:(Class)className {
	UIResponder* responder = self;
	while (![responder isKindOfClass:className]) {
		responder = [responder nextResponder];
		if (!responder) break;
	}
	
	return (UIView*)responder;
}
%end	/// %hook SBDashBoardTodayPageView

/**
 * Fix the position of the Face ID glyph on the passcode screen
 */
%hook LAUIPearlGlyphView
- (void)setFrame:(CGRect)arg1 {
	if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
		%orig;
		return;
	}
	
	%orig(CGRectSetY(arg1, arg1.origin.y - offset));
}
%end	/// %hook LAUIPearlGlyphView

%hook SBUIProudLockIconView
- (void)layoutSubviews {
	%orig;
	
	[self setHidden:!isIpad && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)];
}
%end	/// %hook SBUIProudLockIconView
%end	// %group ProudLock

%group UIKit
/**
 * More corner rounding stuff
 */
%hook UIScreen
- (double)_displayCornerRadius {
	if (roundedCornersVisible) return isIpad ? 18 : 39;
	return %orig;
}
%end    /// %hook UIScreen

%hook UITraitCollection
- (double)displayCornerRadius {
	if (roundedCornersVisible) return isIpad ? 18 : 39;
	return %orig;
}
%end    /// %hook UITraitCollection

/**
 * Force iOS to use modern status bars
 * On iOS 12, this is required so SpringBoard doesn't crash
 */
%hook UIStatusBar_Base
+ (Class)_implementationClass {
	return NSClassFromString(@"UIStatusBar_Modern");
}

+ (void)_setImplementationClass:(Class)arg1 {
	%orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end	/// %hook UIStatusBar_Base

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
	if (!isPeace) return NSClassFromString(@"_UIStatusBarVisualProvider_Split");
	
	return isIpad ?
		NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular") :
		NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end	/// %hook _UIStatusBarVisualProvider_iOS

%hook UIStatusBarWindow
+ (void)setStatusBar:(Class)arg1 {
	%orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end	/// %hook UIStatusBarWindow

/**
 * Fix the keyboard padding when in landscape
 */
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)arg1 inputMode:(id)arg2 {
	UIEdgeInsets r = %orig;
	
	if (!isIpad && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
		return UIEdgeInsetsMake(r.top, 0, r.bottom, 0);
	}
	
	return r;
}
%end	/// %hook UIKeyboardImpl

/**
 * Fix video gravity when an app uses AVPlayerViewController (no WKWebView yet)
 */
%hook AVPlayerViewControllerContentView
- (UIEdgeInsets)edgeInsetsForLetterboxedContent {
	UIEdgeInsets r = %orig;
	if (isIpad || !UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) return r;
	if (r.left > 40 || r.right > 40) return r;
	
	return UIEdgeInsetsMake(0, 40, 0, 40);
}
%end
%end	// %group UIKit



#pragma mark - Additional Hacks
%group CameraHack
/**
 * Apply the iPhone X layout to Camera.app
 * Note: Requires more work to fix new layout issues
 */
%hook CAMViewfinderView
- (NSInteger)layoutStyle {
	return 4;
}
%end	/// %hook CAMViewfinderView
%end 	// %group CameraHack

%group SafariHack
/**
 * Move Safari's toolbar icons to the edge where they belong
 */
%hook BrowserToolbar
- (UIEdgeInsets)safeAreaInsets {
	return UIEdgeInsetsMake(0, 0, 21, 0);
}
%end	/// %hook BrowserToolbar
%end	//%group SafariHack

%group PreferencesHack
/**
 * Make Preferences.app show "Face ID & Code" instead of "Touch ID & Code"
 * For some reason, iPad only shows string placeholders
 */
%hook PSUIPrefsListController
- (BOOL)shouldShowFaceID {
	return YES;
}
- (BOOL)shouldShowTouchID {
	return NO;
}
%end    /// %hook PSUIPrefsListController
%end	// %group PreferencesHack



#pragma mark - MobileGestalt Hooks
/**
 * This code is taken from tonyk7's MGSpoof, which is a modified patchfinder64 from xerub.
 * I use this only to prevent hardcoding the address of MGCopyAnswer_internal in case it's ever changed.
 */
typedef unsigned long long addr_t;

static addr_t step64(const uint8_t *buf, addr_t start, size_t length, uint32_t what, uint32_t mask) {
	addr_t end = start + length;
	while (start < end) {
		uint32_t x = *(uint32_t *)(buf + start);
		if ((x & mask) == what) {
			return start;
		}
		start += 4;
	}
	return 0;
}

static addr_t find_branch64(const uint8_t *buf, addr_t start, size_t length) {
	return step64(buf, start, length, 0x14000000, 0xFC000000);
}

static addr_t follow_branch64(const uint8_t *buf, addr_t branch) {
	long long w;
	w = *(uint32_t *)(buf + branch) & 0x3FFFFFF;
	w <<= 64 - 26;
	w >>= 64 - 26 - 2;
	return branch + w;
}


extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef prop);
static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef prop, uint32_t* outTypeCode);

CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef key, uint32_t* outTypeCode) {
#define k(string) CFEqual(key, CFSTR(string))
	
	CFPropertyListRef r = orig_MGCopyAnswer_internal(key, outTypeCode);
	NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	
	if (d2xEnabled) {
		if (isIpad) {
			// Make the device think it's an iPad Pro (12.9-inch) (3rd generation)
			if (k("oPeik/9e8lQWMszEjbPzng") || k("ArtworkTraits")) {
				CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
				CFRelease(r);
				
				uint32_t deviceSubType = 0xAAC;
				CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType));
				
				return copy;
			} else if (k("y5dppxx/LzxoNuW+iIKR3g") || k("DeviceCornerRadius")) {
				return (__bridge CFPropertyListRef)@18;
			} else if (k("/YYygAofPDbhrwToVsXdeA") || k("HwModelStr")) {
				return (__bridge CFPropertyListRef)@"J320AP";
			} else if (k("Z/dqyWS6OZTRy10UcmUAhw") || k("marketing-name")) {
				return (__bridge CFPropertyListRef)@"J320";
			} else if (k("h9jDsbgj7xIVeIQ8S3/X3Q") || k("ProductType")) {
				return (__bridge CFPropertyListRef)@"iPad8,5";
			}
		} else {
			// Make the device think it's an iPhone XS
			if (k("oPeik/9e8lQWMszEjbPzng") || k("ArtworkTraits")) {
				CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
				CFRelease(r);
				
				uint32_t deviceSubType = 0x984;
				CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType));
				
				return copy;
			} else if (k("/YYygAofPDbhrwToVsXdeA") || k("HwModelStr")) {
				return (__bridge CFPropertyListRef)@"D321AP";
			} else if (k("Z/dqyWS6OZTRy10UcmUAhw") || k("marketing-name")) {
				return (__bridge CFPropertyListRef)@"iPhone XS";
			} else if (k("h9jDsbgj7xIVeIQ8S3/X3Q") || k("ProductType")) {
				return (__bridge CFPropertyListRef)@"iPhone11,2";
			}
			
			// Add some camera stuff that isn't even working on single lens devices
			if (k("iBLsDETxB4ATmspGucaJyg") || k("IsLargeFormatPhone") ||
				k("YzrS+WPEMqyh/FBv/n/jvA") || k("RearFacingTelephotoCameraCapability") ||
				k("0/VAyl58TL5U/mAQEJNRQw") || k("DeviceHasAggregateCamera") ||
				k("hewg+QX1h57eGJGphdCong") || k("DeviceSupportsPortraitLightEffectFilters") ||
				k("oLjiDs+BWEdMVbjE0x6cnw") || k("DeviceSupportsStudioLightPortraitPreview")) {
				return (__bridge CFPropertyListRef)@YES;
			}
		}
		
		// Set the Home button type
		if (k("JwLB44/jEB8aFDpXQ16Tuw") || k("HomeButtonType")) {
			return (__bridge CFPropertyListRef)@2;
		}
	}
	
	// Configure rounded corners
	if (roundedCornersVisible) {
		if ((k("y5dppxx/LzxoNuW+iIKR3g") || k("DeviceCornerRadius")) && roundedCornersVisible) {
			return (__bridge CFPropertyListRef)@(isIpad ? 18 : 39);
		}
	}
	
	// Configure ProudLock
	if (latchEnabled && [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		if (k("8olRm6C1xqr7AJGpLRnpSw") || k("PearlIDCapability")) {
			return (__bridge CFPropertyListRef)@YES;
		} else if (k("z5G/N9jcMdgPm8UegLwbKg") || k("IsEmulatedDevice")) {
			return (__bridge CFPropertyListRef)@YES;
		}
	}
	
	return r;
}

static BOOL (*old___UIScreenHasDevicePeripheryInsets)();
BOOL __UIScreenHasDevicePeripheryInsets() {
  return YES;
}



%ctor {
	// File integrity check
	if (access(DPKG_PATH, F_OK) == -1 && !TARGET_OS_SIMULATOR) {
		NSLog(@"[Notch'd] You are using Notch'd from a source other than https://repo.festival.ml");
		NSLog(@"[Notch'd] To ensure system stability and security (or what's left of it, thanks to your jailbreak), Notch'd will disable itself now.");
		
		return;
	}
	
	NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	
	if (bundleIdentifier) {
		notchPreferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
		
		enabled = (BOOL)[[notchPreferences objectForKey:@"enabled"] ?: @YES boolValue];
		notchVisible = (BOOL)[[notchPreferences objectForKey:@"showNotch"] ?: @YES boolValue];
		roundedCornersVisible = (BOOL)[[notchPreferences objectForKey:@"showRoundedCorners"] ?: @YES boolValue];
		notchDetailVisible = (BOOL)[[notchPreferences objectForKey:@"showNotchDetails"] ?: @NO boolValue];
		hideInScreenshots = (BOOL)[[notchPreferences objectForKey:@"hideVisualsInScreenshots"] ?: @YES boolValue];

		latchEnabled = (BOOL)[[notchPreferences objectForKey:@"latchEnabled"] ?: @YES boolValue];
		
		d2xEnabled = (BOOL)[[notchPreferences objectForKey:@"d2xEnabled"] ?: @YES boolValue];
		modernDock = (BOOL)[[notchPreferences objectForKey:@"d2xDock"] ?: @YES boolValue];
		reduceIconRows = (BOOL)[[notchPreferences objectForKey:@"d2xReduceIconRows"] ?: @NO boolValue];
		switcherKillStyle = (NSInteger)[[notchPreferences objectForKey:@"d2xSwitcherStyle"] ?: @1 integerValue];
		disableHomeScreenRotation = (BOOL)[[notchPreferences objectForKey:@"d2xDisableHomeRotation"] ?: @YES boolValue];
		
		if (enabled) {
			isIpad = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad);
			isPeace = kCFCoreFoundationVersionNumber >= 1556.0;
			
			if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				%init(SpringBoard);
				
				if (d2xEnabled) {
					%init(D2xAP);
				}
				
				if (latchEnabled) {
					%init(ProudLock);
				}
			} else {
				NSDictionary* appPreferences = [notchPreferences objectForKey:bundleIdentifier];
				
				if (appPreferences) {
					enabled = (BOOL)[[appPreferences objectForKey:@"enabled"] ?: @YES boolValue];
					d2xEnabled = (BOOL)[[appPreferences objectForKey:@"d2xEnabled"] ?: @YES boolValue];
					notchVisible = (BOOL)[[appPreferences objectForKey:@"showNotch"] ?: @YES boolValue];
					roundedCornersVisible = (BOOL)[[appPreferences objectForKey:@"showRoundedCorners"] ?: @YES boolValue];
				}
			}
			
			if (enabled) {
				MSImageRef libGestalt = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
				
				if (libGestalt && !TARGET_OS_SIMULATOR) {
					void *MGCopyAnswerFn = MSFindSymbol(libGestalt, "_MGCopyAnswer");
					const uint8_t *MGCopyAnswer_ptr = (const uint8_t *)MGCopyAnswer;
					addr_t branch = find_branch64(MGCopyAnswer_ptr, 0, 8);
					addr_t branch_offset = follow_branch64(MGCopyAnswer_ptr, branch);
					MSHookFunction(((void *)((const uint8_t *)MGCopyAnswerFn + branch_offset)), (void *)new_MGCopyAnswer_internal, (void **)&orig_MGCopyAnswer_internal);
					MSHookFunction(((void*)MSFindSymbol(NULL, "__UIScreenHasDevicePeripheryInsets")),(void*)__UIScreenHasDevicePeripheryInsets, (void**)&old___UIScreenHasDevicePeripheryInsets);
				} else {
					libGestalt = MSGetImageByName("/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 11.4.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libMobileGestalt.dylib");
					
					MSHookFunction(((void*)MSFindSymbol(libGestalt, "_MGCopyAnswer")),(void*)new_MGCopyAnswer_internal, (void**)&orig_MGCopyAnswer_internal);
					MSHookFunction(((void*)MSFindSymbol(NULL, "__UIScreenHasDevicePeripheryInsets")),(void*)__UIScreenHasDevicePeripheryInsets, (void**)&old___UIScreenHasDevicePeripheryInsets);
				}
				
				if (d2xEnabled) {	
					%init(UIKit);
					
					if (!isIpad && [bundleIdentifier isEqualToString:@"com.apple.camera"]) {
						%init(CameraHack);
					}
					if (!isIpad && [bundleIdentifier isEqualToString:@"com.apple.mobilesafari"]) {
						%init(SafariHack);
					}
					if (!isIpad && [bundleIdentifier isEqualToString:@"com.apple.Preferences"]) {
						%init(PreferencesHack);
					}
				}
			
			
				%init;
			}
		}
	}
}