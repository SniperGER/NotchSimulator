#import "Tweak.h"

static void bundleIdentifierBecameVisible(NSString* bundleIdentifier) {
	notchPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
	
	if (bundleIdentifier && notchPreferences) {
		if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
			[notchWindow setNotchVisible:showNotch roundedCornersVisible:showRoundedCorners];
		} else {
			BOOL _showNotch = YES;
			BOOL _showRoundedCorners = NO;
			NSDictionary* appSettings = [notchPreferences objectForKey:bundleIdentifier];

			if (appSettings) {
				_showNotch = (BOOL)[[appSettings objectForKey:@"showNotch"] ?: @YES boolValue];
				_showRoundedCorners = (BOOL)[[appSettings objectForKey:@"showRoundedCorners"] ?: @YES boolValue];

				[notchWindow setNotchVisible:_showNotch && showNotch roundedCornersVisible:_showRoundedCorners && showRoundedCorners];
			} else {
				[notchWindow setNotchVisible:showNotch roundedCornersVisible:showRoundedCorners];
			}
		}
	}
}

%hook SpringBoard
%property (nonatomic, retain) D22APWindow* notchWindow;
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	
	self.notchWindow = [[D22APWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	[self.notchWindow makeKeyAndVisible];
	[self.notchWindow setNotchVisible:showNotch roundedCornersVisible:showRoundedCorners];
	
	notchWindow = self.notchWindow;
}

- (void)takeScreenshotAndEdit:(BOOL)arg1 {
	if (hideVisualsInScreenshots) {
		[self.notchWindow setHidden:YES];
		%orig;
		
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[self.notchWindow setHidden:NO];
		});
	} else {
		%orig;
	}
}
%end	// %hook SpringBoard



%hook SBMainDisplaySceneManager
- (void)_noteDidChangeToVisibility:(NSUInteger)visibility forScene:(FBScene *)scene {
	NSString *bundleIdentifier = nil;
	if (scene) {
		bundleIdentifier = scene.clientProcess.bundleIdentifier;
	}

	if (bundleIdentifier && ([[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier] || [bundleIdentifier isEqualToString:@"com.apple.springboard"])) {
		if (visibility != 1) {
			[notchWindow makeKeyAndVisible];
			[notchWindow setNotchVisible:showNotch roundedCornersVisible:showRoundedCorners];
		} else {
			bundleIdentifierBecameVisible(bundleIdentifier);
		}
	}
	
	%orig;
}
%end	// %hook SBMainDisplaySceneManager



%ctor {
	if (access(DPKG_PATH, F_OK) != -1) {
		NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
		
		notchPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.notchsimulator.plist"];
		
		BOOL enabled = (BOOL)[[notchPreferences objectForKey:@"enabled"] ?: @YES boolValue];
		showNotch = (BOOL)[[notchPreferences objectForKey:@"showNotch"] ?: @YES boolValue];
		showRoundedCorners = (BOOL)[[notchPreferences objectForKey:@"showRoundedCorners"] ?: @YES boolValue];
		hideVisualsInScreenshots = (BOOL)[[notchPreferences objectForKey:@"hideVisualsInScreenshots"] ?: @YES boolValue];
		
		if (enabled && [identifier isEqualToString:@"com.apple.springboard"]) {
			%init();
		}
	}
}
