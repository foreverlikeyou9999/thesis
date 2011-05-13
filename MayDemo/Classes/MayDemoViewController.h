//
//  MayDemoViewController.h
//  MayDemo
//
//  Created by Russell de Moose on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <UIKit/UIKit.h> 
#include <Foundation/Foundation.h>
#import "MayDemoAppDelegate.h"
#import "MapViewController.h"

@interface MayDemoViewController : UIViewController {

	MapViewController *mapness;
	UIBarButtonItem *done;
	NSArray *arrydata;
	
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *done;	
@property (nonatomic, retain) MapViewController *mapness;

// ---------------TABLE TEST------------//
@property (nonatomic, retain) NSArray *arryData;
@property (nonatomic, retain) IBOutlet UITableView *table;

//----------- View methods------------//


- (IBAction) sourceSelect: (id)sender;


@end

