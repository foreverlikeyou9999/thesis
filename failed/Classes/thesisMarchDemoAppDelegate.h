//
//  thesisMarchDemoAppDelegate.h
//  thesisMarchDemo
//
//  Created by Russell de Moose on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CombinedViewController.h" 


@class thesisMarchDemoViewController;

@interface thesisMarchDemoAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
    UIWindow *window;
    thesisMarchDemoViewController *viewController;

	
	CLLocationManager *locationManager;
	CLHeading *heading;
	CombinedViewController *combinedView;
	
	
	
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet thesisMarchDemoViewController *viewController;


@property (nonatomic, retain) CLLocationManager *locationManager;





@end
