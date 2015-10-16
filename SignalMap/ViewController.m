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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
	controller = [[SignalController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startTracking:(id)sender {
	[controller setup];
	NSLog(@"Tracking started");
}
- (IBAction)stopTracking:(id)sender {
	[controller destroy];
	NSLog(@"Tracking stopped");
}
- (IBAction)getInfo:(id)sender {
	NSDictionary *results = [controller getInfo];
	NSLog(@"(%lf,%lf) %d\t%f",
		 [[results objectForKey: @"Latitude"] doubleValue],
		 [[results objectForKey: @"Longitude"] doubleValue],
		 [[results objectForKey: @"RawSignal"] intValue],
		 [[results objectForKey: @"Signal"] floatValue]
		 );
}

@end
