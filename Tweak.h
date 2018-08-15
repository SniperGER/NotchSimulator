#import "D22APWindow.h"
#define DPKG_PATH "/var/lib/dpkg/info/ml.festival.notchsimulator.list"

static NSDictionary* notchPreferences;
static D22APWindow* notchWindow;
static BOOL showNotch = YES;
static BOOL showRoundedCorners = YES;
static BOOL hideVisualsInScreenshots = YES;

@interface SpringBoard : NSObject
@property (nonatomic, retain) D22APWindow* notchWindow;
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
