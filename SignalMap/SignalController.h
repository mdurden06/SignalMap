//
//  SignalController.h
//  SignalMap
//
//  Created by Ethan Laur on 10/15/15.
//  Copyright © 2015 Ethan Laur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum { kdNone, kdEDGE, kd3G, kd4G, kdLTE } dataType;

@interface SignalData : NSObject
{
	BOOL isConnected;
	int rawSignalStrength;
	dataType connectedService;
}
- (float)getSignalStrength; //returns percent of strength (or 0 if not connected)
- (dataType)getConnectedService; //returns connected data network type **does not refresh**
- (int)getRawSignalStrength; //returns rawSignalStrength var (or 0 if not connected)
@end

@interface LocationData : NSObject<CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;
	double currLatitude,
		  currLongitude;
	time_t lastUpdate;
}
- (void)setup;
- (int)secondsSinceLastUpdate;
- (double)getLatitude;
- (double)getLongitude;
- (NSDictionary *)getLocation; //auto updating
- (void)destroy;
@end

@interface SignalController : NSObject
{
	SignalData *signalInfo;
	LocationData *locationInfo;
}
- (void)setup: (NSObject *)p;
- (void)destroy;
- (NSDictionary *)getInfo;
@end


@interface CTTelephonyNetworkInfo
- (id)signalStrength;
@end