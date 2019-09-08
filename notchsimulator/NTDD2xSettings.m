#import "NTDD2xSettings.h"

@implementation NTDD2xSettings

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"D2xSettings" target:self];
	}
	
	for (PSSpecifier* specifier in _specifiers) {
		if (specifier.properties[@"noIpad"] && [specifier.properties[@"noIpad"] boolValue]) {
			NSMutableDictionary* properties = [specifier.properties mutableCopy];
			[properties setValue:@(UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad) forKey:@"enabled"];
			[specifier setProperties:properties];
		}
	}
	
	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return ([settings objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
}

@end
