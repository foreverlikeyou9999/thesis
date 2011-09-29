//
//  MapViewController.m
//  MayDemo
//
//  Created by Russell de Moose on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController

@synthesize panner;
@synthesize map, coordinates, coordinate, pin;
@synthesize locationManager; 
@synthesize allStations, selectedStations, tempSelection;

BOOL wasAlreadyPlaying = false;

- (void)setupStations 
{
	//-----------Temp station dictionary----------------//
	
	allStations = [NSArray arrayWithObjects:@"http://wfuv-onair.streamguys.org:80/onair-hi", @"http://wnycfm.streamguys.com/", @"Others", nil];	
	selectedStations = [NSMutableArray arrayWithCapacity:1];
	
	//--------------------------------------//
}

//------Audio methods-------------------//

//--------------------------------------//
- (void)createStreamer
{
	if (wasAlreadyPlaying == true)
	{
		NSLog(@"Calling restartStream.");
		
		//[stream startStream:selectedStations];
		
	}
	else
	{
		NSLog(@"Calling startStream.");
		//[stream fmodKill];
	
		stream = [[fmodStreamer alloc] init];
	
		//[stream startStream:selectedStations];
		[stream startStream:tempSelection];
	
		
	}
}
//--------------------------------------//



//--------------------------------------//
-(IBAction)pannerMoved:(id)sender {
	
	[stream changePan:panner.value];
	
}
//--------------------------------------//


//--------------------------------------//
- (IBAction)pauseResume:(id)sender 
{
    [stream pause];		
}
//--------------------------------------//

//----------------------End audio methods-------------------//


- (void)captureStations:(NSUInteger)selection

{
	[selectedStations addObject:[allStations objectAtIndex:selection]];
	NSLog(@"%@", selectedStations);
	tempSelection = [allStations objectAtIndex:selection];
	
}	

- (void) viewDidLoad 

{

	[self createStreamer];
	
//////////---------------------------------------------/////////////
	
	
	self.locationManager = [[[CLLocationManager alloc] init] autorelease]; //for retain count 
	//adds one to retain count with alloc; then we autorelease to decrement retain count 
	
	if (self.locationManager.locationServicesEnabled)
	{
		//if location services are on
		
		self.locationManager.delegate = self; //sets itself as delegate 
		self.locationManager.distanceFilter = 3; // sets 2000 METERS as minimum poll distance
		// self.locationManager.desiredAccuracy = 1; //determines the radio being used, depending on accuracy
		// more accurate results with GPS, but more polls take longer to populate 
		
		
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //Best accuracy, most battery intensive. 
		
		
		[self.locationManager startUpdatingLocation]; //get location, send back to delegate 
		
		
	}
	
	else {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location, location, location" 
														message:@"Please relaunch and allow me to use your location. Thanks." 
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.cancelButtonIndex = 0; 
		[alert show];
		[alert release];
		
		//.applicationWillTerminate;
		//exit(0);
	}
	
	
	CLLocation *position = self.locationManager.location;
	if (!position) {
		NSLog(@"Balls");	
	}
	
	CLLocationCoordinate2D where = [position coordinate];
	double x = where.latitude;
	double y = where.longitude;
	int o = position.course; 
	
	NSLog(@"%s %d,%d","You are at coordinates", x, y);
	NSLog(@"%s %i %s", "Your orientation is", o, "degrees."); 
	
	
	
	//----------------------------------------------------------------------------//	
	
	// check if the hardware has a compass
	
	
	
	if ([locationManager headingAvailable] == NO) {
		
		// No compass is available. This application cannot function without a compass, 
		// so a dialog will be displayed and no magnetic data will be measured.
		
		//self.locationManager = nil; 
		
		//This nil kills the mapview and all methods that depend on a CLLocation manager.  Not desired. Would rather display an alert. Commented out for testing on 3G.
		
		UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"Not gonna work here anymore!" 
																 message:@"This device does not have a compass. Orientation tracking will not function properly and this application may not make sense." 
																delegate:nil cancelButtonTitle:@"I'm sorry!" otherButtonTitles:nil];
		noCompassAlert.cancelButtonIndex = 0; 
		[noCompassAlert show];
		[noCompassAlert release];
		
		
	} 
	
	else {
		// heading service configuration
		locationManager.headingFilter = kCLHeadingFilterNone;
		
		// setup delegate callbacks
		locationManager.delegate = self;
		
		// start the compass
		[locationManager startUpdatingHeading];
		
		if (self.locationManager.headingFilter) {
			NSLog(@"There is a heading filter");
		} else {
			NSLog(@"Damn, no heading filter");
		}
		
	}
	
	
	//------------------------Annotations-----------------------------//
	
	CLLocationCoordinate2D cHall;
    cHall.latitude = 40.76;
    cHall.longitude = -73.980735;
	
	CLLocationCoordinate2D fuv;
    fuv.latitude = 40.8614;
    fuv.longitude = -73.890057;
	
	CLLocationCoordinate2D nyc;
    nyc.latitude = 40.727072;
    nyc.longitude = -74.005516;
	
	//Use NSMutableArray if annotating more than one location
	
	coordinates = [[NSMutableArray array] retain];
	Annotation *Carnegie = [[Annotation alloc] init];
	Annotation *WFUV = [[Annotation alloc] init];
	Annotation *WNYC = [[Annotation alloc] init];

	Carnegie.coordinate = cHall;
	WFUV.coordinate = fuv;
	WNYC.coordinate = nyc;
	
	//[coordinates addObject:Carnegie];
	[coordinates addObject:WFUV];
	[coordinates addObject:WNYC];
	
	[map addAnnotations:coordinates];
	
}
	

- (void) locationManager:(CLLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)location {
	
	// need to account for mapness, meaning greater distance from equator 
	
	/* Refuse updates more than a minute old - Stack Overflow suggestion */
	if (abs([newLocation.timestamp timeIntervalSinceNow]) > 60.0) {
		return;
	}
	
	double size = 10.0;
	double scaling = ABS(cos(2*M_PI*newLocation.coordinate.latitude/360.0)); //this scales views properly
	
	MKCoordinateSpan span; // LOOK no * - C structure
	
	span.latitudeDelta = size / 100.0;
	span.longitudeDelta = size/ (scaling * 100.0);
	
	MKCoordinateRegion region; //structure
	region.span = span; 
	region.center = newLocation.coordinate; 
	
	NSLog(@"Location updated");
	
	[map setRegion:region animated:YES]; //animates to map
	map.showsUserLocation = YES; //shows a dot

	

	
}


- (void)locationManager:(CLLocationManager *)locationManager didUpdateHeading:(CLHeading *)heading 
	
	{
	
	
	
	[map setTransform:CGAffineTransformMakeRotation(-1 * heading.magneticHeading * 3.14159 / 180)];
	
	// From stack overflow example. The heading information should be passed by this method, and the transform should be a rotation 
	// that converts from degrees to radians.
	
	// From Stack overflow. Used for Annotation positioning. Not sure which method it should be included with yet. 
	
	//for (MKAnnotation *annotation in self.mapView.annotations) {
	//	MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation]; 
	//	[annotationView setTransform:CGAffineTransformMakeRotation(currentHeading.magneticHeading * 3.14159 / 180)];
	//}
	
}


- (void)awakeFromNib


{
	
	NSLog(@"Loaded, guy");
	
}


- (void)dealloc
{
	NSLog(@"dealloc called");
	
	[locationManager release];
	[stream release];
	[super dealloc];
}
	
- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	
}

//--------------------------------------//
- (void)viewWillDisappear:(BOOL)animated
{
    /*
	 Shut down
	 */    
    
    [stream fmodKill];
	
}
//--------------------------------------//

- (void) goToMenu:(id)sender
{
	[stream killSoundForMenu];
	wasAlreadyPlaying = true;
	[self.view removeFromSuperview];
	NSLog(@"Back to menu.");
}


@end
