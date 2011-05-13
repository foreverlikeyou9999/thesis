//
//  AprilDemoAppDelegate.h
//  AprilDemo
//
//  Created by Russell de Moose on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DemoViewController.h" 
#import <QuartzCore/QuartzCore.h>

@class DemoViewController;

@interface AprilDemoAppDelegate : NSObject <UIApplicationDelegate> 

{ 
	
	//Conforms to both the UIApplicationDelegate and CLLocationManagerDelegate protocols
	
    UIWindow *window;
	UINavigationController *navigationController;

	DemoViewController *viewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DemoViewController *viewController;
@property (nonatomic, retain) UINavigationController *navigationController;




@end
