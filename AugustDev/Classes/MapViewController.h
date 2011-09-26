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
		UISlider	   *panner;
		
		// ------------Map objects----------// 
		
		IBOutlet MKMapView *map;	
		MKPinAnnotationView *pin;
		NSMutableArray *coordinates;

		
		CLLocationManager *locationManager; //For location updates.
		CLHeading *heading; //For compass readings
		
	}

	@property (nonatomic, retain) IBOutlet UISlider		*panner;
	@property (nonatomic, retain) IBOutlet MKMapView *map;
	@property (nonatomic, retain) MKPinAnnotationView *pin;
	@property (nonatomic, retain) NSMutableArray *coordinates;
	@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
	
	@property (nonatomic, retain) CLLocationManager *locationManager;

	
	//----------- View methods------------//
	
- (IBAction) annotate: (id)sender;
- (void)createStreamer;
- (IBAction)pauseResume:(id)sender;
- (IBAction)pannerMoved:(id)sender;

	

	@end







