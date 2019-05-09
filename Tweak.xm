//
//  Tweak.xm
//  Notch'd
//
//  Created by Janik Schmidt on 03.01.19.
//

#import "Tweak.h"

%group SpringBoard

%hook SpringBoard
%property (nonatomic, retain) NotchWindow* notchWindow;
/**
 * Initialize Notch and Rounded Corners overlay
 */
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    
    self.notchWindow = [[NotchWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    notchWindow = self.notchWindow;
    
    [self.notchWindow setNotchVisible:notchVisible roundedCornersVisible:roundedCornersVisible];
    [self.notchWindow makeKeyAndVisible];
}
%end    /// %hook SpringBoard



//@interface SBUIAnimationController : NSObject
//- (id)animationSettings;
//@end
//
//%hook SBUIAnimationController
//- (void)_prepareAnimation {
//    %orig;
//    
//    HBLogDebug(@"animation test (prepare)");
//    [self performSelector:@selector(crashThisBitch)];
//}
//
//- (void)__startAnimation {
//    %orig;
//    
//    NSLog(@"[NotchSimulator] %@", self);
//}
//- (void)_startAnimation {
//    %orig;
//    
//    HBLogDebug(@"animation test (start)");
//    [self performSelector:@selector(crashThisBitch)];
//}
//
//-(void)setAnimationSettings:(id)arg1 {
//    HBLogDebug(@"animation test (set anim settings)");
//    [self performSelector:@selector(crashThisBitch)];
//}
//%end

%end    // %group SpringBoard



%group D22AP

/**
 * Disable Home Screen rotation
 */
%hook SpringBoard
- (long long) homeScreenRotationStyle {
    if (disableHomeScreenRotation) return 0;
    return %orig;
}
%end    /// %hook SpringBoard

%hook SBHomeScreenViewController
- (NSInteger)supportedInterfaceOrientations {
    if (disableHomeScreenRotation) return UIInterfaceOrientationMaskPortrait;
    return %orig;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)arg1 {
    if (disableHomeScreenRotation) return YES;
    return %orig;
}
%end	/// %hook SBHomeScreenViewController

/**
 * Round those corners!
 */
%hook SBDeckSwitcherPersonality
- (double)_cardCornerRadiusInApplication {
    if (roundedCornersVisible) return 39;
    return %orig;
}

- (double)_cardCornerRadiusInAppSwitcher {
    if (roundedCornersVisible) return 27.3;
    return %orig;
}
%end	/// %hook SBDeckSwitcherPersonality

/**
 * Reduce the icon row count by 1 if enabled
 */
%hook SBIconListView
+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(UIInterfaceOrientation)arg1 {
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
 */
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

/**
 * Make the dock inset
 */
%hook SBDockView
- (BOOL)isDockInset {
    if (!modernDock) return NO;
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

%end    // %group D22AP



%group ProudLock

/**
 * Create a new ProudLock view controller and set the presenter
 */
%hook SBDashBoardViewController
- (void)loadView {
    proudLockViewController = MSHookIvar<SBDashBoardProudLockViewController*>(self, "_proudLockViewController");
    
    if (!proudLockViewController) {
        proudLockViewController = [%c(SBDashBoardProudLockViewController) new];
        MSHookIvar<SBDashBoardProudLockViewController*>(self,"_proudLockViewController") = proudLockViewController;
    }
    
    [proudLockViewController setPresenter:self];
    
    %orig;
}
%end    /// %hook SBDashBoardViewController

/**
 * Make the dashboard view recognize our ProudLock view
 */
%hook SBDashBoardView
- (void)setProudLockIconView:(id)arg1 {
    %orig(proudLockViewController.view);
}

- (id)proudLockIconView {
    return proudLockViewController.view;
}
%end    /// %hook SBDashBoardView

/**
 * Add the ProudLock view to the hierachy because iOS won't do it
 */
%hook SBDashBoardView
- (void)layoutSubviews {
    %orig;
    
    proudLockIconView = MSHookIvar<SBUIProudLockIconView*>(self, "_proudLockIconView");
    if (!proudLockIconView) {
        proudLockIconView = (SBUIProudLockIconView*)proudLockViewController.view;
        MSHookIvar<SBUIProudLockIconView*>(self, "_proudLockIconView") = proudLockIconView;
        
        [[[self subviews] lastObject] addSubview:proudLockIconView];
    }
    
    BOOL iconVisible = MSHookIvar<BOOL>(proudLockViewController, "_iconVisible");
    if (!iconVisible) {
        [proudLockViewController _setIconVisible:YES animated:NO];
        [proudLockViewController _setIconState:1 animated:NO];
    }
}
%end    /// %hook SBDashBoardView

/**
 * Load a fixed CAML bundle for use on @2x devices
 */
%hook SBUICAPackageView
- (id)initWithPackageName:(id)arg1 inBundle:(id)arg2 {
    NSBundle* themeBundle = [NSBundle bundleWithPath:@"/Library/Application Support/NotchSimulator/biglock_fixed.bundle"];
    return %orig(@"biglock_fixed", themeBundle);
}
%end    /// %hook SBUICAPackageView

/**
 * Move down the lockscreen date view to make space for our ProudLock view
 */
%hook SBFLockScreenDateView
- (void)layoutSubviews {
    %orig;
    
    UIView* timeView = MSHookIvar<UIView*>(self, "_timeLabel");
    CGRect timeViewRect = timeView.frame;
    timeViewRect.origin.y = 35;
    [timeView setFrame:timeViewRect];
    
    UIView* dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
    CGRect dateSubtitleRect = dateSubtitleView.frame;
    dateSubtitleRect.origin.y = timeViewRect.size.height + (35 - 7);
    [dateSubtitleView setFrame:dateSubtitleRect];
    
    UIView* customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
    CGRect customSubtitleRect = customSubtitleView.frame;
    customSubtitleRect.origin.y = timeViewRect.size.height + (35 - 7);
    [customSubtitleView setFrame:customSubtitleRect];
}
%end	/// %hook SBFLockScreenDateView

/**
 * Move down the widget view controller only if the device is locked
 */
%hook WGWidgetGroupViewController
- (void)viewDidLayoutSubviews {
    CGRect origFrame = self.view.frame;
    
    if (![[%c(SBLockScreenManager) sharedInstance] isLockScreenActive]) {
        origFrame.origin.y = 0;
    } else {
        origFrame.origin.y = 35;
    }
    [self.view setFrame:origFrame];
    
    %orig;
}
%end	/// %hook WGWidgetGroupViewController

/**
 * Move down notification containers
 */
%hook SBDashBoardAdjunctListView
- (void)setFrame:(CGRect)arg1 {
    arg1.origin.y += 35;
    %orig(arg1);
}
%end	/// %hook NCNotificationListCollectionView

%hook NCNotificationListCollectionView
- (void)setFrame:(CGRect)arg1 {
    arg1.origin.y = 35;
    %orig(arg1);
}

/**
 * Move our ProudLock view with the notification container
 */
- (void)scrollViewDidScroll:(id)arg1 {
    UIEdgeInsets adjustedInsets = [self adjustedContentInset];
    CGPoint contentOffset = [self contentOffset];
    [proudLockViewController.view setTransform:CGAffineTransformMakeTranslation(0, (-adjustedInsets.top + -contentOffset.y))];
    
    %orig;
}
%end	/// %hook NCNotificationListCollectionView

/**
 * Some hacky stuff to make our ProudLock view disappear when we've hit too many Touch ID failures
 * This still doesn't work correctly, and I might never find a proper solution
 */
static SBDashBoardPasscodeViewController* passcodeVC;
%hook SBDashBoardPasscodeViewController
- (void)loadView {
    passcodeVC = self;
    %orig;
}

- (BOOL)useBiometricPresentation {
    return YES;
}
%end    /// SBDashBoardPasscodeViewController

%hook SBUIInteractionForwardingView
- (void)setAlpha:(CGFloat)arg1 {
    if (passcodeVC) {
        if (arg1 == 0) {
            [passcodeVC setShowProudLock:NO];
        } else {
            [passcodeVC setShowProudLock:YES];
        }
    }
    
    %orig;
}
%end    /// SBUIInteractionForwardingView

%end    // %group ProudLock



%group UIKit

/**
 * More corner rounding stuff
 */
%hook UIScreen
- (double)_displayCornerRadius {
    if (roundedCornersVisible) return 39;
    return %orig;
}
%end    /// %hook UIScreen

%hook UITraitCollection
- (double)_displayCornerRadius {
    if (roundedCornersVisible) return 39;
    return %orig;
}
%end    /// %hook UITraitCollection

%end    // %group UIKit



%group CameraHack

/**
 * Move down the camera toolbar
 */
%hook CAMViewfinderView
- (void)layoutSubviews {
    %orig;
    
    CGRect topBarFrame = [[self topBar] frame];
    topBarFrame.origin.y = 40;
    [[self topBar] setFrame:topBarFrame];
}
%end    /// %hook CAMViewfinderView

%end    // %group CameraHack



%group SafariHack

/**
 * Move Safari's toolbar icons to the edge where they belong
 */
%hook BrowserToolbar
- (UIEdgeInsets)safeAreaInsets {
    return UIEdgeInsetsMake(0, 0, 21, 0);
}
%end    /// %hook BrowserToolbar

%end    //  %group SafariHack



extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef prop);
static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef prop, uint32_t* outTypeCode);

CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef key, uint32_t* outTypeCode) {
    CFPropertyListRef r = orig_MGCopyAnswer_internal(key, outTypeCode);
    #define k(string) CFEqual(key, CFSTR(string))
     NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (k("oPeik/9e8lQWMszEjbPzng") || k("ArtworkTraits")) {
        CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
        CFRelease(r);
        
        CFNumberRef num;
        uint32_t deviceSubType = 0x984;
        
        num = CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType);
        CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), num);

        return copy;
    } else if ((k("8olRm6C1xqr7AJGpLRnpSw") || k("PearlIDCapability")) && [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        return (__bridge CFPropertyListRef)@YES;
    } else if (k("y5dppxx/LzxoNuW+iIKR3g") || k("DeviceCornerRadius")) {
        return (__bridge CFPropertyListRef)@39;
    } else if (k("JwLB44/jEB8aFDpXQ16Tuw") || k("HomeButtonType")) {
        return (__bridge CFPropertyListRef)@2;
    } else if (k("/YYygAofPDbhrwToVsXdeA") || k("HwModelStr")) {
        return (__bridge CFPropertyListRef)@"D22AP";
    } else if (k("Z/dqyWS6OZTRy10UcmUAhw") || k("marketing-name")) {
        return (__bridge CFPropertyListRef)@"iPhone X";
    } else if (k("h9jDsbgj7xIVeIQ8S3/X3Q") || k("ProductType")) {
        return (__bridge CFPropertyListRef)@"iPhone10,3";
    }

    return r;
}

%ctor {
    // File integrity check
    if (access(DPKG_PATH, F_OK) == -1) {
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
        hideInScreenshots = (BOOL)[[notchPreferences objectForKey:@"hideVisualsInScreenshots"] ?: @YES boolValue];
        
        latchEnabled = (BOOL)[[notchPreferences objectForKey:@"latchEnabled"] ?: @YES boolValue];
        
        d2xEnabled = (BOOL)[[notchPreferences objectForKey:@"d2xEnabled"] ?: @YES boolValue];
        modernDock = (BOOL)[[notchPreferences objectForKey:@"d2xDock"] ?: @YES boolValue];
        reduceIconRows = (BOOL)[[notchPreferences objectForKey:@"d2xReduceIconRows"] ?: @NO boolValue];
        switcherKillStyle = (NSInteger)[[notchPreferences objectForKey:@"d2xSwitcherStyle"] ?: @1 integerValue];
        disableHomeScreenRotation = (BOOL)[[notchPreferences objectForKey:@"d2xDisableHomeRotation"] ?: @YES boolValue];
        
        if (enabled) {
            if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
                %init(SpringBoard);
                
                if (latchEnabled) {
                    %init(ProudLock);
                }
                
                if (d2xEnabled) {
                    %init(D22AP);
                }
            }
            
            /// TODO: App Preferences
            
            if (d2xEnabled) {
                uint8_t MGCopyAnswer_arm64_impl[8] = {0x01, 0x00, 0x80, 0xd2, 0x01, 0x00, 0x00, 0x14};
                const uint8_t* MGCopyAnswer_ptr = (const uint8_t*) MGCopyAnswer;
                if (memcmp(MGCopyAnswer_ptr, MGCopyAnswer_arm64_impl, 8) == 0) {
                    MSHookFunction((void *)(MGCopyAnswer_ptr + 8), (void*)new_MGCopyAnswer_internal, (void**)&orig_MGCopyAnswer_internal);
                }
                
                %init(UIKit);
                
                if ([bundleIdentifier isEqualToString:@"com.apple.camera"]) {
                    %init(CameraHack);
                }
                if ([bundleIdentifier isEqualToString:@"com.apple.mobilesafari"]) {
                    %init(SafariHack);
                }
            }
            
            %init;
        }
    }
    
//    if (d2xEnabled) {
//        uint8_t MGCopyAnswer_arm64_impl[8] = {0x01, 0x00, 0x80, 0xd2, 0x01, 0x00, 0x00, 0x14};
//        const uint8_t* MGCopyAnswer_ptr = (const uint8_t*) MGCopyAnswer;
//        if (memcmp(MGCopyAnswer_ptr, MGCopyAnswer_arm64_impl, 8) == 0) {
//            MSHookFunction((void *)(MGCopyAnswer_ptr + 8), (void*)new_MGCopyAnswer_internal, (void**)&orig_MGCopyAnswer_internal);
//        }
//        
//        if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
//            %init(SpringBoard);
//        }
//        if ([bundleIdentifier isEqualToString:@"com.apple.camera"]) {
//            %init(CameraHack);
//        }
//        if ([bundleIdentifier isEqualToString:@"com.apple.mobilesafari"]) {
//            %init(SafariHack);
//        }
//        
//        %init(UIKit);
//    }
//    
//    %init;
}
