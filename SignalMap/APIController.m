//
//  APIController.m
//  SignalMap
//
//  Created by Ethan Laur on 10/15/15.
//  Copyright © 2015 Ethan Laur. All rights reserved.
//

#import "APIController.h"

//{ - [

@implementation StorageController

- (void)setup: (NSObject *)p {
	parent = p;
}

@end

@implementation LinkController

@end

@implementation APIController

- (void)setup {
	store = [[StorageController alloc] init];
	link = [[LinkController alloc] init];
	config = [NSMutableDictionary alloc];
	sandboxPath = [SandboxController getSandboxPath];
	configPath = [SandboxController getFilePath: @configFile withSandbox:sandboxPath];
	config = [config initWithContentsOfFile: configPath];
	[store setup: self];
	[link setup: self];
	if (![link connectUID:
	 	(UInt32)[[config objectForKey: @"APIID"] intValue]
		withKey: (UInt32)[[config objectForKey: @"APIKey"] intValue]])
		NSLog(@"Could not connect with API ID %u", (UInt32)[[config objectForKey: @"APIID"] intValue]);
	else
		NSLog(@"Connected to API with ID %u", (UInt32)[[config objectForKey: @"APIID"] intValue]);
}

@end

@implementation SandboxController

+ (NSString *)getSandboxPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}
+ (NSString *)getFilePath: (NSString *)File withSandbox: (NSString *)Sandbox {
	return [Sandbox stringByAppendingPathComponent: File];
}

@end
