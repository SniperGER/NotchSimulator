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
    [self.notchWindow makeKeyAndVisible];
}

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

%end    // %group SpringBoard



%group D22AP

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
	
	for (UIView* subview in self.subviews) {
		if (subview.frame.size.width < 50) {
			if (subview.frame.origin.x < UIScreen.mainScreen.bounds.size.width / 2) {
				CGRect _frame = subview.frame;
				_frame = CGRectMake(46, _frame.origin.y - 90, 50, 50);
				subview.frame = _frame;
				[subview sb_removeAllSubviews];
				
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
				[subview init];
#pragma clang diagnostic pop
			} else {
				CGFloat _screenWidth = UIScreen.mainScreen.bounds.size.width;
				CGRect _frame = subview.frame;
				_frame = CGRectMake(_screenWidth - 96, _frame.origin.y - 90, 50, 50);
				subview.frame = _frame;
				[subview sb_removeAllSubviews];
				
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
				[subview init];
#pragma clang diagnostic pop
			}
		}
	}
}

%end	/// %hook SBDashBoardQuickActionsView

%end    // %group D22AP



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
- (double)_displayCornerRadius {
    if (roundedCornersVisible) return isIpad ? 18 : 39;
    return %orig;
}
%end    /// %hook UITraitCollection

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
#define k(string) CFEqual(key, CFSTR(string))
	
	CFPropertyListRef r = orig_MGCopyAnswer_internal(key, outTypeCode);
	NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	
	if (isIpad) {
		if (k("oPeik/9e8lQWMszEjbPzng") || k("ArtworkTraits")) {
			CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
			CFRelease(r);
			
			CFNumberRef num;
			uint32_t deviceSubType = 0xAAC;
			
			num = CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType);
			CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), num);
			
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
		if (k("oPeik/9e8lQWMszEjbPzng") || k("ArtworkTraits")) {
			CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
			CFRelease(r);
			
			CFNumberRef num;
			uint32_t deviceSubType = 0x984;
			
			num = CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType);
			CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), num);
			
			return copy;
		} else if (k("y5dppxx/LzxoNuW+iIKR3g") || k("DeviceCornerRadius")) {
			return (__bridge CFPropertyListRef)@39;
		} else if (k("JwLB44/jEB8aFDpXQ16Tuw") || k("HomeButtonType")) {
			return (__bridge CFPropertyListRef)@2;
		} else if (k("/YYygAofPDbhrwToVsXdeA") || k("HwModelStr")) {
			return (__bridge CFPropertyListRef)@"D321AP";
		} else if (k("Z/dqyWS6OZTRy10UcmUAhw") || k("marketing-name")) {
			return (__bridge CFPropertyListRef)@"iPhone XS";
		} else if (k("h9jDsbgj7xIVeIQ8S3/X3Q") || k("ProductType")) {
			return (__bridge CFPropertyListRef)@"iPhone11,2";
		} else if (k("iBLsDETxB4ATmspGucaJyg") || k("IsLargeFormatPhone")) {
			return (__bridge CFPropertyListRef)@YES;
		}
	}
	
	if ((k("8olRm6C1xqr7AJGpLRnpSw") || k("PearlIDCapability")) && [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		return (__bridge CFPropertyListRef)@YES;
	} else if (k("JwLB44/jEB8aFDpXQ16Tuw") || k("HomeButtonType")) {
		return (__bridge CFPropertyListRef)@2;
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
				
                if (!isIpad && [bundleIdentifier isEqualToString:@"com.apple.camera"]) {
                    %init(CameraHack);
                }
                if (!isIpad && [bundleIdentifier isEqualToString:@"com.apple.mobilesafari"]) {
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
