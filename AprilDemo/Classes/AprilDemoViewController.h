//
//  AprilDemoViewController.h
//  AprilDemo
//
//  Created by Russell de Moose on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <UIKit/UIKit.h> 
#include <Foundation/Foundation.h>
#import "AprilDemoAppDelegate.h"
//#import "MapViewController.h"


@interface AprilDemoViewController : UIViewController 

{
	//MapViewController *mapness;
	UIBarButtonItem *done;
	
}
	
@property (nonatomic, retain) IBOutlet UIBarButtonItem *done;	
//@property (nonatomic, retain) MapViewController *mapness;
	
// ---------------TABLE TEST------------//
@property (nonatomic, retain) NSArray *arryData;
@property (nonatomic, retain) IBOutlet UITableView *table;
	
//----------- View methods------------//


	- (IBAction) sourceSelect: (id)sender;
	

@end

