//Thesis test. Jan 30 2011. This copy going to git repo.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CombinedViewController.h" 
 

//@class thesis_testViewController;

@class CombinedViewController;

@interface thesis_testAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> { 
	
	//Conforms to both the UIApplicationDelegate and CLLocationManagerDelegate protocols
	
    UIWindow *window;
   // thesis_testViewController *viewController;

	CLLocationManager *locationManager;
	CLHeading *heading;
	CombinedViewController *combinedView;
	
	 
	

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet thesis_testViewController *viewController;
@property (nonatomic, retain) IBOutlet CombinedViewController *combinedView;

@property (nonatomic, retain) CLLocationManager *locationManager;





@end
