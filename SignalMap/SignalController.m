//
//  SignalController.m
//  SignalMap
//
//  Created by Ethan Laur on 10/15/15.
//  Copyright © 2015 Ethan Laur. All rights reserved.
//

#import "SignalController.h"

/*****Undocumented API Calls*****/
int CTGetSignalStrength();
NSString * CTSIMSupportGetSIMStatus();
/**End Undocumented API Calls**/

@implementation SignalData
#define SIGNAL_RANGE 100.0
- (float)getSignalStrength {
	return (float)((float)[self getRawSignalStrength] / SIGNAL_RANGE) * 100.0;
}
- (int)getRawSignalStrength {
	//check connection info
	isConnected = [CTSIMSupportGetSIMStatus() isEqualToString: @"kCTSIMSupportSIMStatusReady"];
	//check signal info
	for (int i = 0; i < 10; i++)
		rawSignalStrength += CTGetSignalStrength();
	rawSignalStrength /= 10;
	//compare
	isConnected = (rawSignalStrength > 0) && isConnected;
	NSLog(@"Connected: %c\tRaw signal strength: %d\n", isConnected ? '1' : '0', rawSignalStrength);
	if (!isConnected)
		return 0;
	return rawSignalStrength;
}
@end

@implementation LocationData
- (void)setup {
	locationManager = [CLLocationManager new];
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.delegate = self;
	//locationManager.allowsBackgroundLocationUpdates = YES;
	[locationManager requestWhenInUseAuthorization];
	[locationManager startUpdatingLocation];
}
- (void)destroy {
	[locationManager stopUpdatingLocation];
}
- (int)secondsSinceLastUpdate {
	return (int)(time(NULL) - lastUpdate);
}
- (double)getLatitude {
	return currLatitude;
}
- (double)getLongitude {
	return currLongitude;
}
- (NSDictionary *)getLocation {
	return @{
		    @"Latitude" : [NSNumber numberWithDouble: currLatitude],
		    @"Longitude" : [NSNumber numberWithDouble: currLongitude],
		    @"TimeSinceUpdate" : [NSNumber numberWithInt: [self secondsSinceLastUpdate]]
		    };
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	lastUpdate = time(NULL);
	CLLocation *curPos = [locations objectAtIndex:0];;
	currLatitude = [curPos coordinate].latitude;
	currLongitude = [curPos coordinate].longitude;
	NSLog(@"New location: %lf, %lf\n", currLatitude, currLongitude);
}
@end

@implementation SignalController
- (void)setup {
	signalInfo = [[SignalData alloc] init];
	locationInfo = [[LocationData alloc] init];
	[locationInfo setup]; //set up locationinfo
	[signalInfo getRawSignalStrength]; //get initial signal reading data
}
- (void)destroy {
	[locationInfo destroy];
}
- (NSDictionary *)getInfo {
	NSDictionary *locationData = [locationInfo getLocation];
	return @{
		    @"Latitude" : [locationData objectForKey:@"Latitude"],
		    @"Longitude" : [locationData objectForKey:@"Longitude"],
		    @"Signal" : [NSNumber numberWithFloat: [signalInfo getSignalStrength]],
		    @"RawSignal" : [NSNumber numberWithInt: [signalInfo getRawSignalStrength ]],
		    @"TimeSinceLastLocation" : [NSNumber numberWithInt: (int)[locationData objectForKey: @"TimeSinceUpdate"]]
		    };
}
@end
