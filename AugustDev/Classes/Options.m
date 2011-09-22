    //
//  Options.m
//  MayDemo
//
//  Created by Russell de Moose on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Options.h"


@implementation Options


@synthesize doneWithOptions;


- (IBAction)updateAngleWidth
{
	angleWidthSliderValue.text = [NSString stringWithFormat:@"%.02f",angleWidthSlider.value];
	gaussianC = angleWidthSlider.value;
}

- (IBAction)updateGainFloor
{
	gainFloorSliderValue.text = [NSString stringWithFormat:@"%.02f",gainFloorSlider.value];
	gainFloor = gainFloorSlider.value;
}



- (IBAction)optionsDone:(id)sender 

{
	[self.view removeFromSuperview];
	NSLog(@"Should remove options screen and return to map view");
	
}




// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
