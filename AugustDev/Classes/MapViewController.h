//
//  MapViewController.h
//  MayDemo
//
//  Created by Russell de Moose on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import <math.h>
#import "Annotation.h"
#import <MapKit/MapKit.h>
#import "AugustDevViewController.h"
#import "AugustDevAppDelegate.h"
#import "fmodStreamer.h"

	
	@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> 
	
	{
 
		fmodStreamer *stream;
		UISlider *panner;
		NSArray *allStations;
		NSMutableArray *selectedStations;
		NSString *tempSelection;
		float panski;
		NSTimer  *panTimer;
		NSMutableArray *reversePanArray;
		
		// ------------Map objects----------// 
		
		IBOutlet MKMapView *map;	
		MKPinAnnotationView *pin;
		NSMutableArray *coordinates;
		
 
		
		CLLocationManager *locationManager; //For location updates.
		CLHeading *orientation; //For compass readings
		
	}

	@property (nonatomic, retain) IBOutlet UISlider	*panner;
	@property (nonatomic, retain) NSArray *allStations;
	@property (nonatomic, retain) NSMutableArray *reversePanArray;
	@property (nonatomic, retain) NSMutableArray *selectedStations;
	@property (nonatomic, retain) NSString *tempSelection;

 
	@property (nonatomic, retain) IBOutlet MKMapView *map;
	@property (nonatomic, retain) MKPinAnnotationView *pin;
	@property (nonatomic, retain) NSMutableArray *coordinates;
	@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
	
	@property (nonatomic, retain) CLLocationManager *locationManager;


	
	//----------- View methods------------//
	
- (void)createStreamer;
- (IBAction)pauseResume:(id)sender;
- (void)pannerMoved;
- (void)goToMenu:(id)sender;
- (void)captureStations:(NSUInteger)selection;
- (void)setupStations;
- (IBAction)startPan:(id)sender;


	

	@end







