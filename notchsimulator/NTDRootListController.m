#include "NTDRootListController.h"
#include "NTDAppSettingsController.h"
#import "OrderedDictionary.h"
#include <spawn.h>

#if __cplusplus
extern "C" {
#endif
	CFSetRef SBSCopyDisplayIdentifiers();
	NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);
#if __cplusplus
}
#endif

@implementation NTDRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray* specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];
		[specifiers addObjectsFromArray:[self installedApplications]];
		_specifiers = specifiers;
	}
	
	return _specifiers;
}

- (NSMutableArray*)installedApplications {
	NSMutableArray* specifiers = [NSMutableArray array];
	NSArray* displayIdentifiers = [(__bridge NSSet *)SBSCopyDisplayIdentifiers() allObjects];
	
	NSMutableDictionary* apps = [NSMutableDictionary new];
	for (NSString* identifier in displayIdentifiers) {
		NSString* name = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
		if (name) {
			[apps setObject:name forKey:identifier];
		}
	}
	
	OrderedDictionary* orderedApps = (OrderedDictionary*)[apps copy];
	orderedApps = [self sortedDictionary:orderedApps];
	
	PSSpecifier* groupSpecifier = [PSSpecifier groupSpecifierWithName:@"Applications:"];
	[specifiers addObject:groupSpecifier];
	
	for (NSString* bundleIdentifier in orderedApps.allKeys) {
		NSString* displayName = orderedApps[bundleIdentifier];
		
		PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:displayName target:self set:nil get:@selector(getIsWidgetSetForSpecifier:) detail:[NTDAppSettingsController class] cell:PSLinkListCell edit:nil];
		[specifier setProperty:@"NTDAppSettingsController" forKey:@"detail"];
		[specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"isController"];
		[specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
		[specifier setProperty:bundleIdentifier forKey:@"bundleIdentifier"];
		[specifier setProperty:bundleIdentifier forKey:@"appIDForLazyIcon"];
		[specifier setProperty:@YES forKey:@"useLazyIcons"];
		[specifiers addObject:specifier];
	}
	
	return specifiers;
}

- (OrderedDictionary*)sortedDictionary:(OrderedDictionary*)dictionary {
	NSArray* sortedValues;
	OrderedDictionary* mutable = [OrderedDictionary dictionary];
	sortedValues = [[dictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString* value in sortedValues) {
		NSString* key = [[dictionary allKeysForObject:value] objectAtIndex:0];
		[mutable setObject:value forKey:key];
	}
	return mutable;
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

- (void)respring {
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Restart SpringBoard" message:@"Restarting SpringBoard will apply all changed settings." preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel handler:nil];
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Restart SpringBoard"
															style:UIAlertActionStyleDestructive
														  handler:^(UIAlertAction* action) {
															  pid_t pid;
															  int status;
															  const char* args[] = {"killall", "-9", "SpringBoard", NULL};
															  posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
															  waitpid(pid, &status, WEXITED);
														  }];
	
	[alertController addAction:cancelAction];
	[alertController addAction:confirmAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
