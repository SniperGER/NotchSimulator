#include "D22AP.h"

static NSDictionary* d22Preferences;
static BOOL showRoundedCorners = YES;
static BOOL modernDock = YES;
static BOOL modernStatusBar = YES;
static BOOL homeGrabberEnabled = YES;
static BOOL modernKeyboard = YES;
static BOOL reduceIconRows = YES;
static NSInteger switcherKillStyle = 1;

static CGFloat screenCornerRadius = 39;
static CGFloat bottomBarInset = 20;

static BOOL properFixedBounds = YES;
static BOOL properBounds = NO;



static BOOL (*old__IS_D2x)();
static BOOL (*old___UIScreenHasDevicePeripheryInsets)();

BOOL _IS_D2x(){
	return YES;
}

BOOL __UIScreenHasDevicePeripheryInsets() {
	return YES;
}

void applicationIsLaunching(NSString* identifier) {
	d22Preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
	
	if (identifier && d22Preferences) {
		BOOL roundedCornersHidden = NO;
		NSDictionary* appSettings = [d22Preferences objectForKey:identifier];
		
		if (appSettings) {
			roundedCornersHidden = (BOOL)[[appSettings objectForKey:@"roundedCornersHidden"]?:@NO boolValue];
			showRoundedCorners = !roundedCornersHidden;
		}
	}
}

static void bundleIdentifierBecameVisible(NSString* identifier) {
	d22Preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
	
	if (identifier && d22Preferences) {
		if ([identifier isEqualToString:@"com.apple.springboard"]) {
			[[[[[NSClassFromString(@"SBPrototypeController") sharedInstance] rootSettings] homeScreenSettings] grabberSettings] setAutoHideOverride:homeGrabberEnabled ? 0x7fffffffffffffff : 5];
		} else {
			BOOL d2xHomeGrabber = NO;
			NSDictionary* appSettings = [d22Preferences objectForKey:identifier];
			
			if (appSettings) {
				BOOL d2xDisabled = (BOOL)[[appSettings objectForKey:@"d2xDisabled"] ?: @NO boolValue];
				if (d2xDisabled) {
					if ([appSettings objectForKey:@"d2xHomeGrabber"]) {
						d2xHomeGrabber = (BOOL)[[appSettings objectForKey:@"d2xHomeGrabber"] ?: @YES boolValue];
					} else {
						d2xHomeGrabber = (BOOL)[[d22Preferences objectForKey:@"d2xHomeGrabber"] ?: @YES boolValue];
					}
				}
			} else {
				d2xHomeGrabber = (BOOL)[[d22Preferences objectForKey:@"d2xHomeGrabber"] ?: @YES boolValue];
			}
			
			[[[[[NSClassFromString(@"SBPrototypeController") sharedInstance] rootSettings] homeScreenSettings] grabberSettings] setAutoHideOverride:d2xHomeGrabber ? 0x7fffffffffffffff : 5];
		}
	}
}

static void bundleIdentifierBecameHidden(NSString *bundleIdentifier) {
	[[[[[NSClassFromString(@"SBPrototypeController") sharedInstance] rootSettings] homeScreenSettings] grabberSettings] setAutoHideOverride:homeGrabberEnabled ? 0x7fffffffffffffff : 5];
}



%group SpringBoard

%hook SBIconListView
+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(UIInterfaceOrientation)arg1 {
	if (!modernDock) return %orig;
	NSUInteger r = %orig;
	if (UIInterfaceOrientationIsLandscape(arg1)) {
		return r;
	} else if (reduceIconRows) {
		return r - 1;
	}
	
	return r;
}
%end	/// %hook SBIconListView



%hook SBAppSwitcherSettings
- (NSInteger)effectiveKillAffordanceStyle {
	return switcherKillStyle;
}

- (NSInteger)killAffordanceStyle {
	return switcherKillStyle;
}

- (void)setKillAffordanceStyle:(NSInteger)style {
	%orig(switcherKillStyle);
}
%end	/// %hook SBAppSwitcherSettings



%hook SBHomeGrabberView
-(NSInteger)_calculatePresence {
	if ([self valueForKey:@"_settings"]) {
		SBHomeGrabberSettings *grabberSettings = (SBHomeGrabberSettings *)[self valueForKey:@"_settings"];
		if ([grabberSettings autoHideOverride] == 5) return 2;
	}
	return %orig;
}
%end



%hook SBHomeGrabberSettings
- (BOOL)_isPrototypingEnabled:(id)something {
	return TRUE;
}
%end



%hook BSPlatform
- (NSInteger)homeButtonType {
	return 2;
}
%end	/// %hook BSPlatform



%hook SBDeckSwitcherPersonality
- (CGFloat)_cardCornerRadiusInApplication {
	if (showRoundedCorners) {
		return 39;
	}
	
	return 0;
}

- (CGFloat)_cardCornerRadiusInAppSwitcher {
	if (showRoundedCorners) {
		return 27.3;
	}
	
	return 5;
}
%end	/// %hook SBDeckSwitcherPersonality



%hook SBDockView
- (BOOL)isDockInset {
	return modernDock;
}
%end	/// %hook SBDockView



%hook SBDashBoardQuickActionsViewController
+ (BOOL)deviceSupportsButtons {
	return YES;
}
%end	/// %hook SBDashBoardQuickActionsViewController



//%hook SBStatusBarStateAggregator
//- (id)_sbCarrierNameForOperator:(id)arg1 {
//	return @"";
//}
//%end


%hook SBLeafIcon
- (void)launchFromLocation:(long long)arg1 context:(id)arg2 activationSettings:(id)arg3 actions:(id)arg4 {
	applicationIsLaunching([self leafIdentifier]);
	
	%orig;
}
%end	/// %hook SBLeafIcon


%hook SBMainDisplaySceneManager
- (void)_noteDidChangeToVisibility:(NSUInteger)visibility forScene:(FBScene *)scene {
	NSString *bundleIdentifier = nil;
	if (scene) {
		bundleIdentifier = scene.clientProcess.bundleIdentifier;
	}
	
	d22Preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
	if (bundleIdentifier && ([[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier] || [bundleIdentifier isEqualToString:@"com.apple.springboard"])) {
		if (visibility != 1) {
			showRoundedCorners = (BOOL)[[d22Preferences objectForKey:@"showRoundedCorners"] ?: @YES boolValue];
			bundleIdentifierBecameHidden(bundleIdentifier);
		} else {
			bundleIdentifierBecameVisible(bundleIdentifier);
		}
	}
	
	%orig;
}
%end	/// %hook SBMainDisplaySceneManager



%hook SBDashBoardTeachableMomentsContainerViewController
- (BOOL)_shouldTeachAboutControlCenter {
	return YES;
}
%end	/// %hook SBDashBoardTeachableMomentsContainerViewController

%end	// %group SpringBoard



%group BoundsHack
//int uname(struct utsname *);
//
//%hookf(int, sysctl, const int *name, u_int namelen, void *oldp, size_t *oldlenp, const void *newp, size_t newlen) {
//	if (namelen == 2 && name[0] == CTL_HW && name[1] == HW_MACHINE) {
//		int r = %orig;
//		if (oldp != NULL) {
//			const char* hardwareModel = "iPhone10,3";
//			strncpy((char*)oldp, hardwareModel, strlen(hardwareModel));
//		}
//		return r;
//	} else{
//		return %orig;
//	}
//}
//
//
//
//%hookf(int, sysctlbyname, const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
//	if (strcmp(name, "hw.machine") == 0) {
//		int r = %orig;
//		if (oldp != NULL) {
//			const char* hardwareModel = "iPhone10,3";
//			strncpy((char*)oldp, hardwareModel, strlen(hardwareModel));
//		}
//		return r;
//	} else {
//		return %orig;
//	}
//}
//
//
//
//%hookf(int, uname, struct utsname *value) {
//	int r = %orig;
//
//	const char* hardwareModel = "iPhone10,3";
//	strcpy(value->machine, hardwareModel);
//
//	return r;
//}



%hook UIScreen
- (CGRect)nativeBounds {
	CGRect r = %orig;
	
	if (r.size.height > r.size.width) {
		r.size.width = 1125;
		r.size.height = 2436;
	} else {
		r.size.width = 2436;
		r.size.height = 1125;
	}
	
	return r;
}

- (BOOL)isInterfaceAutorotationDisabled {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		BOOL orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook UIScreen



%hook UIView
- (CGRect)_convertViewPointToSceneSpaceForKeyboard:(CGRect)keyboard {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook UIView



%hook _UIScreenRectangularBoundingPathUtilities
- (void)_loadBezierPathsForScreen:(id)screen {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end	/// %hook _UIScreenRectangularBoundingPathUtilities



%hook _UIPreviewInteractionDecayTouchForceProvider
- (id)initWithTouchForceProvider:(id)thing {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		id orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook _UIPreviewInteractionDecayTouchForceProvider



%hook UIPopoverPresentationController
- (CGRect)_sourceRectInContainerView {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook UIPopoverPresentationController



%hook UIPanelBorderView
- (void)layoutSubviews {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end	/// %hook UIPanelBorderView



%hook UIPeripheralHost
+ (BOOL)pointIsWithinKeyboardContent:(CGPoint)point {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		BOOL orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (void)setInputViews:(id)stuff animationStyle:(id)stuff1 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end	/// %hook UIPeripheralHost



%hook _UIScreenFixedCoordinateSpace
- (CGRect)bounds {
	CGRect bounds = %orig;
	if ([self _screen] == [UIScreen mainScreen] && !properFixedBounds) {
		if (bounds.size.height > bounds.size.width) {
			bounds.size.height = 812;
			bounds.size.width = 375;
		} else {
			bounds.size.width = 812;
			bounds.size.height = 375;
		}
	}
	return bounds;
}

- (CGRect)convertRect:(CGRect)arg1 toCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (CGRect)convertRect:(CGRect)arg1 fromCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (CGPoint)convertPoint:(CGPoint)arg1 toCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGPoint orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (CGPoint)convertPoint:(CGPoint)arg1 fromCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGPoint orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook _UIScreenFixedCoordinateSpace



%hook UIKeyboardAssistantBar
- (void)showKeyboard:(id)keyboard {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end	/// %hook UIKeyboardAssistantBar



%hook UIApplicationRotationFollowingController
- (void)window:(id)window setupWithInterfaceOrientation:(NSInteger)orientation {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end	/// %hook UIApplicationRotationFollowingController



%hook UIScreenMode
- (CGSize)size {
	return CGSizeMake(1125,2436);
}
%end	/// %hook UIScreenMode



%hook UIWindow
- (UIEdgeInsets)safeAreaInsets {
	UIEdgeInsets orig = %orig;

	if (orig.top > 30) {
		orig.bottom = homeGrabberEnabled ? bottomBarInset : 0;
	}
	else {
		if (orig.left < 10) {
			orig.left = homeGrabberEnabled ? bottomBarInset : 0;
		} else if (orig.right < 10) {
			orig.right = homeGrabberEnabled ? bottomBarInset : 0;
		}
	}
	return orig;
}
%end	/// %hook UIWindow



%hook UIScrollView
- (UIEdgeInsets)adjustedContentInset {
	UIEdgeInsets orig = %orig;
	if (orig.top == 64 && modernStatusBar) {
		orig.top = 88;
	}
	if (orig.top == 32 && modernStatusBar) {
		orig.top = 0;
	}
	return orig;
}
%end	/// %hook UIScrollView

%end	// %group BoundsHack



%group ExtraHooks

%hook UIScreen
+ (UIEdgeInsets)sc_safeAreaInsets {
	UIEdgeInsets orig = %orig;
	orig.top = 0;
	orig.bottom = homeGrabberEnabled ? [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets].bottom : 0;
	return orig;
}

+ (UIEdgeInsets)sc_safeAreaInsetsForInterfaceOrientation:(UIInterfaceOrientation)orientation {
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
		return UIEdgeInsetsMake(0, modernStatusBar ? insets.top : 20, 0, homeGrabberEnabled ? insets.bottom : 0);
	} else {
		UIEdgeInsets orig = %orig;
		orig.top = 0;
		orig.bottom = homeGrabberEnabled ? [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets].bottom : 0;
		return orig;
	}
}

+ (UIEdgeInsets)sc_visualSafeInsets {
	UIEdgeInsets orig = %orig;
	orig.top = 0;
	orig.bottom = homeGrabberEnabled ? [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets].bottom : 0;
	return orig;
}

+ (UIEdgeInsets)sc_filterSafeInsets {
	UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
	return UIEdgeInsetsMake(modernStatusBar ? insets.top : 20,0,0,0);
}

+ (UIEdgeInsets)sc_headerSafeInsets {
	UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
	return UIEdgeInsetsMake(modernStatusBar ? insets.top : 20,0,0,0);
}

+ (UIEdgeInsets)sc_safeFooterButtonInset {
	UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
	
	if (modernStatusBar) return UIEdgeInsetsMake(0, 0, homeGrabberEnabled ? insets.bottom : 0, 0);
	return %orig;
}

+ (CGFloat)sc_headerHeight {
	CGFloat orig = %orig;
	
	if (modernStatusBar) {
		return orig + (modernStatusBar ? 24 : 0);
	}
	
	return orig;
}
%end	/// %hook UIScreen



%hook CALayer
- (CGPoint)convertPoint:(CGPoint)arg1 toLayer:(id)arg2  {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGPoint orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (CGPoint)convertPoint:(CGPoint)arg1 fromLayer:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGPoint orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (CGRect)convertRect:(CGRect)arg1 toLayer:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (CGRect)convertRect:(CGRect)arg1 fromLayer:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook CALayer

%hook UIInputViewSet
- (BOOL)inSyncWithOrientation:(NSInteger)orientation forKeyboard:(id)keyboard {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		BOOL orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

+ (id)inputSetWithPlaceholderAndAccessoryView:(id)view {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		id orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook UIInputViewSet

%end	// %group ExtraHooks



%group ExtremeBounds

%hook UIScreen
- (CGRect)bounds {
	if (properBounds || (!modernStatusBar && !homeGrabberEnabled)) return %orig;
	
	CGRect bounds = %orig;
	if (bounds.size.height > bounds.size.width) {
		bounds.size.height = 812;
	} else {
		bounds.size.width = 812;
	}
	return bounds;
}
%end	/// %hook UIScreen

%end	// %group ExtremeBounds



%hook UIScreen
- (CGRect)applicationFrame {
	CGRect r = %orig;
	return CGRectMake(0, 44, r.size.width, r.size.height);
}

//- (CGRect)nativeBounds {
//	return CGRectMake(0, 0, 1125, 2436);
//}_s
//
//- (CGFloat)nativeScale {
//	return 3;
//}

- (CGFloat)_displayCornerRadius {
	if (showRoundedCorners) {
		return screenCornerRadius;
	}
	
	return 0;
}

- (BOOL)_wantsWideContentMargins {
	return NO;
}

- (UIEdgeInsets)_sceneSafeAreaInsets {
	UIEdgeInsets r = %orig;
	
	if (r.bottom == 34) {
		r.bottom = homeGrabberEnabled ? bottomBarInset : 0;
	}
	
	return r;
}
%end	// %hook UIScreen



%hook UITraitCollection
- (CGFloat)displayCornerRadius {
	if (showRoundedCorners) {
		return screenCornerRadius;
	}
	
	return -1;
}
%end	// %hook UITraitCollection



%hook _UIStatusBar
+ (BOOL)forceSplit {
	return modernStatusBar;
}

+ (void)setForceSplit:(BOOL)arg1 {
	%orig(modernStatusBar);
}

+ (void)setDefaultVisualProviderClass:(Class)arg1 {
	%orig(modernStatusBar ? NSClassFromString(@"_UIStatusBarVisualProvider_Split") : NSClassFromString(@"_UIStatusBarVisualProvider_iOS"));
}

+ (void)initialize {
	%orig;
	
	[NSClassFromString(@"_UIStatusBar") setForceSplit:modernStatusBar];
	[NSClassFromString(@"_UIStatusBar") setDefaultVisualProviderClass:modernStatusBar ? NSClassFromString(@"_UIStatusBarVisualProvider_Split") : NSClassFromString(@"_UIStatusBarVisualProvider_iOS")];
}

- (void)_prepareVisualProviderIfNeeded {
	%orig;
	
	[NSClassFromString(@"_UIStatusBar") setForceSplit:modernStatusBar];
	[NSClassFromString(@"_UIStatusBar") setDefaultVisualProviderClass:modernStatusBar ? NSClassFromString(@"_UIStatusBarVisualProvider_Split") : NSClassFromString(@"_UIStatusBarVisualProvider_iOS")];
}

+ (CGFloat)heightForOrientation:(NSInteger)orientation {
	if (modernStatusBar) {
		return [NSClassFromString(@"_UIStatusBarVisualProvider_Split") intrinsicContentSizeForOrientation:orientation].height;
	}
	
	return [NSClassFromString(@"_UIStatusBarVisualProvider_iOS") intrinsicContentSizeForOrientation:orientation].height;
}
%end	// %hook _UIStatusBar


%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
	return modernStatusBar ? NSClassFromString(@"_UIStatusBarVisualProvider_Split") : NSClassFromString(@"_UIStatusBarVisualProvider_iOS");
}
%end	// %hook _UIStatusBarVisualProvider_iOS



%hook UIStatusBar_Base
+ (BOOL)forceModern {
	return modernStatusBar;
}
+ (Class)_statusBarImplementationClass {
	return modernStatusBar ? NSClassFromString(@"UIStatusBar_Modern") : NSClassFromString(@"UIStatusBar");
}
%end	// %hook UIStatusBar_Base



%hook UIRemoteKeyboardWindowHosted
- (UIEdgeInsets)safeAreaInsets {
	UIEdgeInsets r = %orig;
	
	if (NSClassFromString(@"JCPBarmojiCollectionView") && modernKeyboard) {
		r.bottom = 60;
	} else {
		r.bottom = modernKeyboard ? 44 : (homeGrabberEnabled ? bottomBarInset : 0);
	}
	
	return r;
}
%end	// %hook UIRemoteKeyboardWindowHosted



%hook UIKeyboardImpl
+ (UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)arg1 inputMode:(id)arg2 {
	UIEdgeInsets r = %orig;
	
	if (r.bottom == 75) {
		if (NSClassFromString(@"JCPBarmojiCollectionView") && modernKeyboard) {
			r.bottom = 60;
		} else {
			r.bottom = modernKeyboard ? 44 : 0;
		}
	}
	
	if (r.left == 75) { r.left = modernKeyboard ? 17 : 0; }
	if (r.right == 75) { r.right = modernKeyboard ? 17 : 0; }
	return r;
}

+ (UIEdgeInsets)deviceSpecificStaticHitBufferForInterfaceOrientation:(NSInteger)arg1 inputMode:(id)arg2 {
	if (!modernKeyboard) return %orig;
	UIEdgeInsets r = %orig;
	if (r.bottom == 17) { r.bottom = 0; }
	
	return r;
}
%end	// %hook UIKeyboardImpl



%hook UIKeyboardDockView
%property (nonatomic, assign) BOOL fakeBounds;

- (CGRect)bounds {
	if (!modernKeyboard) return %orig;
	if (self.fakeBounds) {
		CGRect r = %orig;
		
		if (NSClassFromString(@"JCPBarmojiCollectionView")) {
			r.size.height += 4;
		} else {
			r.size.height += 15;
		}
		
		return r;
	} else {
		return %orig;
	}
}

- (void)layoutSubviews {
	self.fakeBounds = YES;
	%orig;
	
	if (modernKeyboard) {
		for (UIView *subview in self.subviews) {
			if ([subview isKindOfClass:NSClassFromString(@"JCPBarmojiCollectionView")]) {
				CGRect frame = subview.frame;
				frame.origin.y = self.frame.size.height - 17 - frame.size.height;
				subview.frame = frame;
			}
		}
	}
	
	self.fakeBounds = NO;
}
%end	// %hook UIKeyboardDockView



%hook UIInputWindowController
- (UIEdgeInsets)_viewSafeAreaInsetsFromScene {
	if (!modernKeyboard) return %orig;
	if (NSClassFromString(@"JCPBarmojiCollectionView")) {
		return UIEdgeInsetsMake(0,0,60,0);
	} else {
		return UIEdgeInsetsMake(0,0,44,0);
	}
}
%end	// %hook UIInputWindowController



%hook UIViewController
- (BOOL)prefersHomeIndicatorAutoHidden {
	if (!homeGrabberEnabled) return YES;
	return %orig;
}
%end



%hook UIView
+ (UIEdgeInsets)tfn_systemSafeAreaInsetsForInterfaceOrientation:(NSInteger)orientation withStatusBarHidden:(BOOL)hidden {
	if (properFixedBounds) {
		UIEdgeInsets unmod = %orig;
		properFixedBounds = NO;
		UIEdgeInsets orig = %orig;
		
		if (!homeGrabberEnabled) {
			orig.bottom = unmod.bottom;
		} else if (orig.bottom > bottomBarInset) {
			orig.bottom = bottomBarInset;
		}
		
		if (!modernStatusBar) {
			orig.top = unmod.top;
		}
		
		properFixedBounds = YES;
		properBounds = YES;
		return orig;
	} else {
		return %orig;
	}
}
%end	/// %hook UIView



%ctor {
	if (access(DPKG_PATH, F_OK) != -1) {
		d22Preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
		
		BOOL enabled = (BOOL)[[d22Preferences objectForKey:@"enabled"] ?: @YES boolValue];
		BOOL d2xEnabled = (BOOL)[[d22Preferences objectForKey:@"d2xEnabled"] ?: @YES boolValue];
		showRoundedCorners = (BOOL)[[d22Preferences objectForKey:@"showRoundedCorners"] ?: @YES boolValue];
		
		modernDock = (BOOL)[[d22Preferences objectForKey:@"d2xDock"] ?: @YES boolValue];
		modernStatusBar = (BOOL)[[d22Preferences objectForKey:@"d2xStatusBar"] ?: @YES boolValue];
		homeGrabberEnabled = (BOOL)[[d22Preferences objectForKey:@"d2xHomeGrabber"] ?: @YES boolValue];
		modernKeyboard = (BOOL)[[d22Preferences objectForKey:@"d2xKeyboard"] ?: @YES boolValue];
		reduceIconRows = (BOOL)[[d22Preferences objectForKey:@"d2xReduceIconRows"] ?: @NO boolValue];
		switcherKillStyle = (NSInteger)[[d22Preferences objectForKey:@"d2xSwitcherStyle"] ?: @1 integerValue];
		
		BOOL enabledInApp = YES;
		
		if (enabled && d2xEnabled) {
			NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
			NSDictionary* appSettings = [d22Preferences objectForKey:identifier];
			
			if (appSettings) {
				enabledInApp = (BOOL)[[appSettings objectForKey:@"d2xEnabled"] ?: @YES boolValue];
				showRoundedCorners = (BOOL)[[appSettings objectForKey:@"showRoundedCorners"] ?: @YES boolValue];
				
				modernStatusBar = (BOOL)[[appSettings objectForKey:@"d2xStatusBar"] ?: @YES boolValue];
				homeGrabberEnabled = (BOOL)[[appSettings objectForKey:@"d2xHomeGrabber"] ?: @YES boolValue];
				modernKeyboard = (BOOL)[[appSettings objectForKey:@"d2xKeyboard"] ?: @YES boolValue];
			}
		
			NSArray* disabledBoundsIdentifiers = @[@"com.apple.mobilephone", @"com.spotify.client"];
			NSArray* disabledExtremeBounds= @[@"net.whatsapp.WhatsApp", @"com.spotify.client"];
		
			if ([identifier isEqualToString:@"com.apple.springboard"]) {
				%init(SpringBoard);
			} else if (identifier && enabledInApp) {
				if ([disabledBoundsIdentifiers containsObject:identifier]) {
					%init(ExtraHooks);
				} else {
					if (![disabledExtremeBounds containsObject:identifier]) {
						%init(ExtremeBounds);
					}
					
					%init(BoundsHack);
				}
			} else {
				return;
			}
			
			MSHookFunction(((void*)MSFindSymbol(NULL, "_IS_D2x")),(void*)_IS_D2x, (void**)&old__IS_D2x);
			MSHookFunction(((void*)MSFindSymbol(NULL, "__UIScreenHasDevicePeripheryInsets")),(void*)__UIScreenHasDevicePeripheryInsets, (void**)&old___UIScreenHasDevicePeripheryInsets);
			
			%init;
			[NSClassFromString(@"_UIStatusBar") setDefaultVisualProviderClass:NSClassFromString(@"_UIStatusBarVisualProvider_Split")];
		}
	}
}
