//
//  CoreAudioTestAppDelegate.m
//  CoreAudioTest
//
//  Created by Russell de Moose on 8/18/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
 

#import "location_testAppDelegate.h"
#import "location_testViewController.h"
#import <MapKit/MapKit.h>
 
 

@implementation location_testAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize locationManager;
 



#pragma mark -
#pragma mark Application lifecycle




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
    // Add the view controller's view to the window and display.
	
	self.locationManager = [[[CLLocationManager alloc] init] autorelease]; //for retain count 
	//adds one to retain count with alloc; then we autorelease to decrement retain count with autorelease 3
	
	if (self.locationManager.locationServicesEnabled)
	{
		//if location services are on
		
		self.locationManager.delegate = self; //sets itself as delegate 
		self.locationManager.distanceFilter = 3; // sets 2000 METERS as minimum poll distance
		// self.locationManager.desiredAccuracy = 1; //determines the radio being used, depending on accuracy
		// more accurate results with GPS, but more polls take longer to populate 
		 
		
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //O'Reilly example says use this (or kCLLocationAccuracyNearest x Meters; 
		
		
		[self.locationManager startUpdatingLocation]; //get location, send back to delegate 
		

	}
	else {
		
		viewController.whereabouts.text=@"This application cannot function without Location Services. Please relaunch and enable.";
		//.applicationWillTerminate;
		exit(0);
		
	}

	
	
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	CLLocation *position = self.locationManager.location;
	if (!position) {
		NSLog(@"Balls");
		//[viewController.audioController initializeAUGraph];
		//[viewController.audioController startAUGraph];
	}
	
	CLLocationCoordinate2D where = [position coordinate];
	double x = where.latitude;
	double y = where.longitude;
	int o = position.course; 
	
	NSLog(@"%s %d,%d","You are at coordinates", x, y);
	NSLog(@"%s %i %s", "Your orientation is", o, "degrees."); 
	
	
	NSString* loc = [NSString stringWithFormat:@"Your orientation is %d, %d", x, y];
	viewController.whereabouts.text= loc;

	if (loc){
		NSLog(@"Yes, loc is there; this shit should start now");
		
			
	}
	
	
    return YES;
	
	

	
}



- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	// need to account for mapness, meaning greater distance from equator 
	
	double size = 10.0;
	double scaling = ABS(cos(2*M_PI*newLocation.coordinate.latitude/360.0)); //this scales views properly
	
	MKCoordinateSpan span; // LOOK no * - C structure
	
	span.latitudeDelta = size / 100.0;
	span.longitudeDelta = size/ (scaling * 100.0);
	
	MKCoordinateRegion region; //structure
	region.span = span; 
	region.center = newLocation.coordinate; 
	
	[viewController.map setRegion:region animated:YES]; //animates to map
	viewController.map.showsUserLocation = YES; //shows a dot
	
	[viewController.map setTransform:CGAffineTransformMakeRotation(-1 * currentHeading.magneticHeading * 3.14159 / 180)];
	 //from stack overflow; should rotate map to reflect magnetometer (compass) position. Calculate for radians. 
 
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */ 
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end