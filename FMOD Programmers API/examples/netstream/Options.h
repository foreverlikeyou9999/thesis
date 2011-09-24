//
//  Options.h
//  MayDemo
//
//  Created by Russell de Moose on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Options : UIViewController {
	
	IBOutlet UISlider *angleWidthSlider;
	IBOutlet UILabel *angleWidthSliderValue;
	IBOutlet UISlider *gainFloorSlider;
	IBOutlet UILabel *gainFloorSliderValue;
	
	float defaultGaussianC;
	float defaultGainScale;
	float gaussianC;
	float defaultGainFloor;
	float gainFloor;

	
	//--------Stuff from MayDemoViewController----------//
	
	IBOutlet UIBarButtonItem *doneWithOptions;

	
}

	@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneWithOptions;	


	- (IBAction)optionsDone:(id)sender;
	- (IBAction)updateAngleWidth;
	- (IBAction)updateGainFloor;



@end
