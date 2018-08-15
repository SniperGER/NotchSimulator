#import "NTDAppSettingsController.h"

@implementation NTDAppSettingsController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"AppSettings" target:self];
	}
	
	return _specifiers;
}

-(void)setSpecifier:(PSSpecifier*)specifier {
	[super setSpecifier:specifier];
	
	self.bundleIdentifier = [specifier propertyForKey:@"bundleIdentifier"];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	NSMutableDictionary *appSettings = [settings objectForKey:self.bundleIdentifier];
	if (!appSettings) {
		appSettings = [NSMutableDictionary new];
	}
	return ([appSettings objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	if (![settings objectForKey:self.bundleIdentifier]) {
		[settings setObject:[NSMutableDictionary new] forKey:self.bundleIdentifier];
	}
	[(NSMutableDictionary *)[settings valueForKey:self.bundleIdentifier] setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
}

@end
