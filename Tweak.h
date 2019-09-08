//
//  Tweak.h
//  Notch'd
//
//  Created by Janik Schmidt on 03.01.19.
//

#include "substrate.h"
#include "NotchWindow.h"
#include <dlfcn.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>

#define DPKG_PATH "/var/lib/dpkg/info/ml.festival.notchsimulator.list"
#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

#define kBiometricEventMesaMatched 		3
#define kBiometricEventMesaSuccess 		4
#define kBiometricEventMesaFailed 		10
#define kBiometricEventMesaDisabled 	6



/**
 * Headers
 */
@class SBDashBoardMesaUnlockBehaviorConfiguration,
	SBLayoutElement,
	SBMainDisplayLayoutState,
	SBWorkspaceApplicationSceneTransitionContext,
	SBWorkspaceEntity;

@interface PKGlyphView : UIView
@end

@interface SpringBoard : UIApplication
@property (nonatomic, strong) NotchWindow* notchWindow;

- (id)_accessibilityFrontMostApplication;
@end

@interface SBApplication : NSObject
- (NSString*)bundleIdentifier;
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
@end

@interface SBDashBoardMesaUnlockBehaviorConfiguration : NSObject
- (BOOL)_isAccessibilityRestingUnlockPreferenceEnabled;
@end

@interface SBDashBoardProudLockViewController : UIViewController
- (void)_setIconState:(NSInteger)arg1 animated:(BOOL)arg2 NS_DEPRECATED_IOS(11_0,11_4);
- (void)_setIconVisible:(BOOL)arg1 animated:(BOOL)arg2 NS_DEPRECATED_IOS(11_0,11_4);
@end

@interface SBDashBoardQuickActionsView : UIView
@end

@interface SBDashBoardTodayPageView : UIView
// %new
- (UIView*)presentingViewOfClass:(Class)className;
@end

@interface SBLayoutElement : NSObject
- (NSString*)identifier;
@end

@interface SBLockScreenController : NSObject {
	SBDashBoardMesaUnlockBehaviorConfiguration* _mesaUnlockBehaviorConfiguration;
}
+ (id)sharedInstance;
- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2;
@end

@interface SBMainDisplayLayoutState : NSObject
@property(readonly, nonatomic) long long unlockedEnvironmentMode;
- (NSSet<SBLayoutElement*>*)elements;
@end

@interface SBMainWorkspaceTransitionRequest : NSObject
@property(retain, nonatomic) SBWorkspaceApplicationSceneTransitionContext* applicationContext;
@end

@interface SBReachabilityManager
+ (id)sharedInstance;
- (void)ignoreWindowForReachability:(id)arg1;
@end

@interface SBUIProudLockIconView : UIView
@end

@interface SBWorkspaceApplicationSceneTransitionContext : NSObject
@property(readonly, nonatomic) SBMainDisplayLayoutState* layoutState;
@end

@interface UIView (SBRemoveAllSubviews)
- (void)sb_removeAllSubviews;
@end



/**
 * Instances
 */
static NSDictionary* notchPreferences;
static NotchWindow* notchWindow;

static BOOL isIpad = NO;
static BOOL isPeace = NO;



/**
 * Preferences
 */
static BOOL enabled = YES;
static BOOL notchVisible = YES;
static BOOL roundedCornersVisible = YES;
static BOOL notchDetailVisible = YES;
static BOOL hideInScreenshots = YES;

static BOOL latchEnabled = YES;

static BOOL d2xEnabled = YES;
static BOOL modernDock = YES;
static BOOL reduceIconRows = NO;
static NSInteger switcherKillStyle = 1;
static BOOL disableHomeScreenRotation = YES;