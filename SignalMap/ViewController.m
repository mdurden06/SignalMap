//
//  ViewController.m
//  SignalMap
//
//  Created by Ethan Laur on 10/15/15.
//  Copyright © 2015 Ethan Laur. All rights reserved.
//

#import "ViewController.h"
#import "SignalController.h"
#import <CoreLocation/CoreLocation.h>

SignalController *controller;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *signalLabel;
@property (weak, nonatomic) IBOutlet UILabel *rawSignalLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectedServiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *carrierLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	_infoButton.enabled = NO;
	controller = [[SignalController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startTracking:(id)sender {
	[controller setup: self];
	_infoButton.enabled = YES;
	NSLog(@"Tracking started");
}
- (IBAction)stopTracking:(id)sender {
	[controller destroy];
	NSLog(@"Tracking stopped");
}
- (IBAction)getInfo:(id)sender {
	NSDictionary *results = [controller getInfo];
//	NSLog(@"(%lf,%lf) %d\t%f\tService: %d",
//		 [[results objectForKey: @"Latitude"] doubleValue],
//		 [[results objectForKey: @"Longitude"] doubleValue],
//		 [[results objectForKey: @"RawSignal"] intValue],
//		 [[results objectForKey: @"Signal"] floatValue],
//		 [[results objectForKey: @"ConnectedService"] intValue]
//		 );
	dataType connectedService = (dataType)[[results objectForKey: @"ConnectedService"] intValue];
	[_locationLabel setText: [NSString stringWithFormat: @"%.4lf, %.4lf",
						 [[results objectForKey: @"Latitude"] doubleValue],
						 [[results objectForKey: @"Longitude"] doubleValue]
						 ]];
	[_signalLabel setText: [NSString stringWithFormat: @"%.2f%%",
					    [[results objectForKey: @"Signal"] floatValue]
					    ]];
	[_rawSignalLabel setText: [NSString stringWithFormat: @"%ddbm",
					    [[results objectForKey: @"RawSignal"] intValue]
					    ]];
	[_lastUpdateLabel setText: [NSString stringWithFormat: @"%d",
						  [[results objectForKey: @"TimeSinceLastLocation"] intValue]
						  ]];
	[_connectedServiceLabel setText: [NSString stringWithFormat: @"%s",
							    connectedService == kdNone ? "None" :
							    connectedService == kdEDGE ? "Edge" :
							    connectedService == kd3G ? "3G" :
							    connectedService == kd4G ? "4G" :
							    connectedService == kdLTE ? "LTE" :
							    "Unknown"
						  ]];
	[_carrierLabel setText: [results objectForKey: @"Carrier"]];
}

@end
