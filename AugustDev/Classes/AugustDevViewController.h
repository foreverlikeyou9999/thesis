//
//  AugustDevViewController.h
//  AugustDev
//
//  Created by Russell de Moose on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "AudioStreamer_Sept.h" 

@interface AugustDevViewController : UIViewController <UITextFieldDelegate>
{
	UILabel        *time;
    UILabel        *status;
	UILabel        *buffered;
    UILabel        *lasttag;
    UITextField    *urltext;
    NSTimer        *timer;
	
	AudioStreamer_Sept *stream;
}

@property (nonatomic, retain) IBOutlet UILabel      *time;
@property (nonatomic, retain) IBOutlet UILabel      *status;
@property (nonatomic, retain) IBOutlet UILabel      *buffered;
@property (nonatomic, retain) IBOutlet UILabel      *lasttag;
@property (nonatomic, retain) IBOutlet UITextField  *urltext;

@property (nonatomic, retain) IBOutlet UISlider	*panner;

- (IBAction)pauseResume:(id)sender;
- (IBAction)pannerMoved:(id)sender;
- (void)timerUpdate:(NSTimer *)timer;
- (void)createStreamer;

@end
