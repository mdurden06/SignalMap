//
//  APIController.h
//  SignalMap
//
//  Created by Ethan Laur on 10/15/15.
//  Copyright © 2015 Ethan Laur. All rights reserved.
//

#import <Foundation/Foundation.h>

//{ - [

@interface StorageController : NSObject
{
	BOOL fileOpen;
	BOOL cacheFlushed;
	NSString *filePath;
	NSString *sandboxPath;
	NSMutableArray *memoryCache;
	NSOutputStream *fileHandle;
	NSObject *parent; //APIController
#define cacheFile "APIDataCache"
}
- (void)setup: (NSObject *)p;
- (void)destroy;
- (void)pushDictonary: (NSDictionary *)dict;
- (void)flushCache;
//accessed ONLY via link controller
- (NSInputStream *) getCacheFile;
- (BOOL)isCacheAvailable;
- (void)cacheIsEmpty;
@end

@interface LinkController : NSObject
{
	BOOL linkConnected;
	BOOL linkValid;
	UInt32 linkID;
	StorageController *store;
	NSObject *parent;
}
- (void)setup: (NSObject *)p;
- (void)destroy;
- (BOOL)connectUID: (UInt32) uid withKey: (UInt32) key; //returns true if auth pass
- (void)disconnect;
- (BOOL)sync: (NSDictionary *)data;
- (BOOL)loadStorageController: (StorageController *)sc;
@end

@interface APIController : NSObject
{
#define configFile "APIConfig"
	//private fields
	NSString *configPath;
	NSString *sandboxPath;
	NSMutableDictionary *config;
	//public interfaces
	StorageController *store;
	LinkController *link;
}
- (void)setup;
- (void)destroy;
- (BOOL)writeConfig;
@end

@interface SandboxController : NSObject
+ (NSString *)getSandboxPath;
+ (NSString *)getFilePath: (NSString *)File withSandbox: (NSString *)Sandbox;
@end
