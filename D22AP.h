#include <sys/sysctl.h>
#include <sys/utsname.h>
#define DPKG_PATH "/var/lib/dpkg/info/ml.festival.notchsimulator.list"

@interface SBLeafIcon : NSObject
- (id)leafIdentifier;
@end

@interface _UIStatusBar : UIView
+ (void)setDefaultVisualProviderClass:(Class)classOb;
+ (void)setForceSplit:(BOOL)arg1;
@end

@interface _UIStatusBarVisualProvider_Split : NSObject
+ (CGSize)intrinsicContentSizeForOrientation:(NSInteger)orientation;
@end

@interface UIKeyboardDockView : UIView
@property (nonatomic, assign) BOOL fakeBounds;
@end

@interface _UIScreenFixedCoordinateSpace : NSObject
- (UIScreen *)_screen;
@end

@interface UIScreen ()
- (UIEdgeInsets)_sceneSafeAreaInsets;
@end

@interface FBProcess : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;
@end

@interface FBScene : NSObject
@property (nonatomic,retain,readonly) FBProcess * clientProcess;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (id)applicationWithBundleIdentifier:(NSString *)arg1;
@end

@interface SBHomeGrabberSettings : NSObject
- (void)setEnabled:(BOOL)enabled;
- (void)setAutoHideOverride:(NSInteger)override;
- (NSInteger)autoHideOverride;
@end

@interface SBHomeScreenSettings : NSObject
- (SBHomeGrabberSettings *)grabberSettings;
@end

@interface SBRootSettings : NSObject
- (SBHomeScreenSettings *)homeScreenSettings;
@end

@interface SBPrototypeController : NSObject
+ (instancetype)sharedInstance;
- (SBRootSettings *)rootSettings;
@end
