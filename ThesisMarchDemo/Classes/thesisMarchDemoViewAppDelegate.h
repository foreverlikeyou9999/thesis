//Russell de Moose 
//March Thesis Demo

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ThesisMarchDemoViewViewController.h" 
#import <QuartzCore/QuartzCore.h>

@class ThesisMarchDemoViewViewController; 

@interface thesisMarchDemoViewAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> 

{ 
	
	//Conforms to both the UIApplicationDelegate and CLLocationManagerDelegate protocols
	
    UIWindow *window;
	CLLocationManager *locationManager;
	//CLHeading *heading;
	ThesisMarchDemoViewViewController *viewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ThesisMarchDemoViewViewController *viewController;
@property (nonatomic, retain) CLLocationManager *locationManager;




@end
