//
//  SignalController.m
//  SignalMap
//
//  Created by Ethan Laur on 10/15/15.
//  Copyright © 2015 Ethan Laur. All rights reserved.
//

#import "SignalController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
@import UIKit;

/*****Undocumented API Calls*****/
int CTGetSignalStrength();
NSString * CTSIMSupportGetSIMStatus();
void CTIndicatorsGetSignalStrength(long int *, long int *, long int *);
/**End Undocumented API Calls**/

@implementation SignalData
#define SIGNAL_RANGE 80.0
//real range: 40 to 120
- (float)getSignalStrength {
	return (float)((float)(SIGNAL_RANGE - ([self getRawSignalStrength] - 40)) / SIGNAL_RANGE) * 100.0;
}

- (int)signalStrength{ //pretty clever hack, but it works!
	UIApplication *app = [UIApplication sharedApplication];
	NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
	NSString *dataNetworkItemView = nil;
	for (id subview in subviews) {
		if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]]) {
			dataNetworkItemView = subview;
			break;
		}
	}
	return [[dataNetworkItemView valueForKey:@"signalStrengthRaw"] intValue];
}

- (int)getRawSignalStrength {
	//check connection info
	isConnected = [CTSIMSupportGetSIMStatus() isEqualToString: @"kCTSIMSupportSIMStatusReady"];
	//check signal info
	for (int i = 0; i < 10; i++)
		rawSignalStrength += [self signalStrength];
	rawSignalStrength /= 10;
	rawSignalStrength *= -1;
	//compare
	isConnected = (rawSignalStrength > 0) && isConnected;
	NSLog(@"Connected: %c\tRaw signal strength: %d\n", isConnected ? '1' : '0', rawSignalStrength);
	if (!isConnected)
		return 0;
	return rawSignalStrength;
}
- (dataType)getConnectedService {
	dataType ret = kdNone;
	CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
	NSString *networkType = [telephonyInfo currentRadioAccessTechnology];
	
	NSLog(@"Current Radio Access Technology: %@, (%@)", telephonyInfo.currentRadioAccessTechnology,
		 [[telephonyInfo subscriberCellularProvider]carrierName]);
	if ([networkType isEqualToString: CTRadioAccessTechnologyCDMA1x])
		ret = kdEDGE;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyCDMAEVDORev0])
		ret = kdEDGE;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyCDMAEVDORevA])
		ret = kdEDGE;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyCDMAEVDORevB])
		ret = kdEDGE;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyEdge])
		ret = kdEDGE;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyeHRPD])
		ret = kdEDGE;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyGPRS])
		ret = kdEDGE;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyHSDPA])
		ret = kd4G;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyHSUPA])
		ret = kd3G;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyWCDMA])
		ret = kd3G;
	else if ([networkType isEqualToString: CTRadioAccessTechnologyLTE])
		ret = kdLTE;
	return ret;
}
@end

@implementation LocationData
- (void)setup {
	locationManager = [CLLocationManager new];
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.delegate = self;
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
		    @"TimeSinceLastLocation" : [NSNumber numberWithInt: (int)[locationData objectForKey: @"TimeSinceUpdate"]],
		    @"ConnectedService" : [NSNumber numberWithInt: (int)[signalInfo getConnectedService]]
		    };
}
@end
