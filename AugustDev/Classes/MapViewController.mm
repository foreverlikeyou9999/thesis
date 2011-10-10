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
@synthesize allStations; 
@synthesize selectedStations, tempSelection, reversePanArray;
@synthesize firstStation, secondStation, thirdStation;

BOOL wasAlreadyPlaying = false;
int panInt;

- (void)setupStations 
{
	//-----------Temp station array----------------//
	
	allStations = [NSMutableArray arrayWithObjects:@"http://wfuv-onair.streamguys.org:80/onair-hi", @"http://wnycfm.streamguys.com/", @"http://wbgo.streamguys.net/wbgo96", nil];	
    
    NSLog(@"Station array created.");

	//--------------------------------------//
}

- (void)resetStations 
{
    firstStation = @"one";
    secondStation = @"two";
    thirdStation = @"three";
    
    NSLog(@"Stations reset");
    
}


//------Audio methods-------------------//

//--------------------------------------//
- (void)createStreamer
{
	if (wasAlreadyPlaying == true)
	{
		NSLog(@"Calling restartStream.");
		
		[stream startStream:firstStation andAlso:secondStation andAlso:thirdStation];       
        //[stream startStream:tempSelection];

		
	}
	else
	{
		NSLog(@"Calling startStream.");
	
		stream = [[fmodStreamer alloc] init];
	
		[stream createSystem];
		[stream startStream:firstStation andAlso:secondStation andAlso:thirdStation];
	//	[stream startStream:tempSelection];
      
	}
}
//--------------------------------------//

//--------------------------------------//

-(IBAction)startPan:(id) sender
{
	panTimer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pannerMoved:) userInfo:nil repeats:YES];
}
//--------------------------------------//

//--------------------------------------//

//-(IBAction)setVolumeManually:(id) sender
//{
//	[stream setVolume:panner.value];
//}
//--------------------------------------//




//--------------------------------------//
-(void) pannerMoved: (NSTimer *)panTimer {


	[stream changePan:panski];
	[stream setVolume:volumeski];

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
	//Adds user selection to Array, reading from master array, at specified index. 

	//Pseudocode e.g. Add WSOU, which comes from master station list, 
	//to my station variable, using the row of the selection as an index for the switch.
    
    switch (selection)
    {
    
    case (0):
        firstStation = [allStations objectAtIndex:selection]; 
        NSLog(@"First station written to variable. It is %@", firstStation);	
        break;
    case (1):
        secondStation = [allStations objectAtIndex:selection];
        NSLog(@"Second station written to variable. It is %@", secondStation);
        break;
    case (2):
        thirdStation = [allStations objectAtIndex:selection];
        NSLog(@"Third station written to variable. It is %@", thirdStation);
        break;
    default:
        break;
    }
	
	//tempSelection = [allStations objectAtIndex:selection];
	
}	

- (void) viewDidLoad 

{
	// Create streaming object 
	//[self createStreamer];

	
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
		
		//-----------PAN TEST----------------------
		
		
		
		//-----------------------------------------------//
	}
	
	else {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location, location, location" 
														message:@"Please relaunch and allow me to use your location. Thanks." 
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.cancelButtonIndex = 0; 
		[alert show];
		[alert release];

	}
	
	
	CLLocation *position = self.locationManager.location;
	if (!position) {
		NSLog(@"Balls");	
	}
	
	CLLocationCoordinate2D where = [position coordinate];
	double x = where.latitude;
	double y = where.longitude;
	int o = position.course; 
	
	NSLog(@"%s %g,%f","You are at coordinates", x, y);
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
	
	CLLocationCoordinate2D fuv;
    fuv.latitude = 40.8614;
    fuv.longitude = -73.890057;
	
	CLLocationCoordinate2D nyc;
    nyc.latitude = 40.727072;
    nyc.longitude = -74.005516;
	
	//Use NSMutableArray if annotating more than one location
	
	coordinates = [[NSMutableArray array] retain];

	Annotation *WFUV = [[Annotation alloc] init];
	Annotation *WNYC = [[Annotation alloc] init];

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
		if  (heading.trueHeading >= 1 && heading.trueHeading <= 15 )	
		{
			panski = (heading.trueHeading / -90);
			volumeski = 0.9;
		}
		else if  (heading.trueHeading >= 15 && heading.trueHeading <= 30 )	
		{
			panski = (heading.trueHeading / -90);
			volumeski = 0.8;
		}
		else if  (heading.trueHeading >= 30 && heading.trueHeading <= 45 )	
		{
			panski = (heading.trueHeading / -90);
			volumeski = 0.7;
		}
		else if  (heading.trueHeading >= 45 && heading.trueHeading <= 60 )	
		{
			panski = (heading.trueHeading / -90);
			volumeski = 0.5;
		}
		else if  (heading.trueHeading >= 60 && heading.trueHeading <= 75 )	
		{
			panski = (heading.trueHeading / -90);
			volumeski = 0.4;
		}
		else if  (heading.trueHeading >= 75 && heading.trueHeading <= 90 )	
		{
			panski = (heading.trueHeading / -90);
			volumeski = 0.2;
		}
		else if (heading.trueHeading >= 90 && heading.trueHeading <= 180)
		{
			panski = -1;
			volumeski = 0.2;
		}
		else if (heading.trueHeading >= 180 && heading.trueHeading <= 270)
		{
			panski = 1;
			volumeski = 0.2;
		}
		else if (heading.trueHeading >= 270 && heading.trueHeading <= 285)
		{
			panski = 0.8;
			volumeski = 0.4;
		}
		else if (heading.trueHeading >= 285 && heading.trueHeading <= 300)
		{
			panski = 0.6;
			volumeski = 0.5;
		}
		else if (heading.trueHeading >= 300 && heading.trueHeading <= 315)
		{
			panski = 0.4;
			volumeski = 0.7;
		}
		else if (heading.trueHeading >= 315 && heading.trueHeading <= 330)
		{
			panski = 0.2;
			volumeski = 0.8;
		}
		else if (heading.trueHeading >= 330 && heading.trueHeading <= 360)
		{
			panski = 0.1;
			volumeski = 0.9;
		}
		
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
	[panTimer invalidate];
}


@end
