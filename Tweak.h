//
//  Tweak.h
//  Notch'd
//
//  Created by Janik Schmidt on 03.01.19.
//

#include "substrate.h"
#import "NotchWindow.h"

#define DPKG_PATH "/var/lib/dpkg/info/ml.festival.notchsimulator.list"


/**
 * Headers
 */
@interface SpringBoard : UIApplication
@property (nonatomic, strong) NotchWindow* notchWindow;
@end

@interface CAMViewfinderView : UIView
- (UIView*)bottomBar;
- (UIView*)topBar;
@end

@interface SBDashBoardProudLockViewController : UIViewController {
    BOOL _desiredIconState;
    BOOL _iconVisible;
}

- (void)_setIconVisible:(BOOL)arg1 animated:(BOOL)arg2;
- (void)_setIconState:(long long)arg1 animated:(BOOL)arg2;
- (void)setPresenter:(id)arg1;
@end

@interface SBUIProudLockIconView : UIView
@end

@interface SBDashBoardView : UIView
@end

@interface SBDashBoardPasscodeViewController : UIViewController
- (void)setShowProudLock:(BOOL)arg1;
- (BOOL)useBiometricPresentation;
@end

@interface SBDashBoardPasscodeView : UIView
- (void)resetForFailedMesaAttemptWithStatusText:(id)arg1 andSubtitle:(id)arg2;
@end

@interface SBLockScreenManager
+ (instancetype)sharedInstance;
- (BOOL)isLockScreenActive;
@end

@interface SBUIPasscodeLockViewSimpleFixedDigitKeypad : UIView
- (BOOL)isBiometricAuthenticationAllowed;
-(void)_updateBiometricGlyphForBioEvent:(unsigned long long)arg1 animated:(BOOL)arg2 completion:(id)arg3 ;
-(void)_updateProudLockForBioEvent:(unsigned long long)arg1 animated:(BOOL)arg2 completion:(id)arg3 ;
@end

@interface WGWidgetGroupViewController : UIViewController
@end

@interface NCNotificationListCollectionView : UIScrollView
//- (UIEdgeInsets)adjustedContentInset;
@end

@interface SBDashBoardQuickActionsView : UIView
@end

@interface UIView (SBRemoveAllSubviews)
- (void)sb_removeAllSubviews;
@end



/**
 * Instances
 */
static NSDictionary* notchPreferences;
static NotchWindow* notchWindow;
static SBDashBoardProudLockViewController* proudLockViewController;
static SBUIProudLockIconView* proudLockIconView;

static BOOL isIpad = NO;
static BOOL isPeace = NO;



/**
 * Preferences
 */
static BOOL enabled = YES;
static BOOL notchVisible = YES;
static BOOL roundedCornersVisible = YES;
static BOOL hideInScreenshots = YES;

static BOOL latchEnabled = YES;

static BOOL d2xEnabled = YES;
static BOOL modernDock = YES;
static BOOL reduceIconRows = NO;
static NSInteger switcherKillStyle = 1;
static BOOL disableHomeScreenRotation = YES;
