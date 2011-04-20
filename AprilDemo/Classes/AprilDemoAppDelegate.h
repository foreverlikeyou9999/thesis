//
//  AprilDemoAppDelegate.h
//  AprilDemo
//
//  Created by Russell de Moose on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AprilDemoViewController.h" 
#import <QuartzCore/QuartzCore.h>

@class AprilDemoViewController;

@interface AprilDemoAppDelegate : NSObject <UIApplicationDelegate> 

{ 
	
	//Conforms to both the UIApplicationDelegate and CLLocationManagerDelegate protocols
	
    UIWindow *window;
	//CLLocationManager *locationManager;
	//CLHeading *heading;
	AprilDemoViewController *viewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AprilDemoViewController *viewController;
//@property (nonatomic, retain) CLLocationManager *locationManager;




@end
