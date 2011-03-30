//Russell de Moose 
//March Thesis Demo

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ThesisMarchDemoViewController.h" 
#import <QuartzCore/QuartzCore.h>

@class ThesisMarchDemoViewController;

@interface ThesisMarchDemoAppDelegate : NSObject <UIApplicationDelegate> 

{ 
	
	//Conforms to both the UIApplicationDelegate and CLLocationManagerDelegate protocols
	
    UIWindow *window;
	//CLLocationManager *locationManager;
	//CLHeading *heading;
	ThesisMarchDemoViewController *viewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ThesisMarchDemoViewController *viewController;
//@property (nonatomic, retain) CLLocationManager *locationManager;




@end
