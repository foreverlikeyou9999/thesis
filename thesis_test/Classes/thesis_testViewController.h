

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import "thesis_testAppDelegate.h"




@interface thesis_testViewController : UIViewController {
	
	//CLLocationManager *locationManager;
	MKMapView *map;	  
	 
	IBOutlet UITextView *whereabouts; 
	
}

 
 
//@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (readonly, nonatomic) IBOutlet UITextView *whereabouts;


@end

