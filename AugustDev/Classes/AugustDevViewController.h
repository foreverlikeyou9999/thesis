//
//  AugustDevViewController.h
//  AugustDev
//
//  Created by Russell de Moose on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import <Foundation/Foundation.h>
#import "fmodStreamer.h"
#import "MapViewController.h"

@class MapViewController;

@interface AugustDevViewController : UIViewController 

{
	//----------Audio Variables---------//
	
	fmodStreamer *stream;
	UISlider	   *panner;
	
	//---------------------------------//
	
	// --------View and Picker Variables----------//
	
	MapViewController *mapness;
	UIBarButtonItem *done;
	NSArray	*arryData;
	UITableView *table;
	
	//---------------------------------//
}


@property (nonatomic, retain) IBOutlet UISlider		*panner;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *done;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSArray *arryData;



- (IBAction)pauseResume:(id)sender;
- (IBAction)pannerMoved:(id)sender;
- (void)createStreamer;

- (IBAction) sourceSelect: (id)sender;

@end
