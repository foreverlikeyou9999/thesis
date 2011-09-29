//
//  fmodStreamer.h
//  AugustDev
//
//  Created by Russell de Moose on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>			
#import <UIKit/UIKit.h>
		
#include <pthread.h>
#include <AudioToolbox/AudioToolbox.h>
#import "fmod.hpp"
#import "fmod_errors.h"


@interface fmodStreamer : NSObject 
	{
				
		bool discontinuous;			// flag to indicate middle of the stream
		bool paused;
		
		FMOD::System   *system;
		FMOD::Sound    *sound;
		FMOD::Channel  *channel;
		FMOD_VECTOR	listenerpos;
		FMOD_RESULT result;
		float pan;
		NSTimer *urlStream;
		NSString *url;
		
		unsigned int  version;
	}

@property (nonatomic, retain) NSString *url;
	
//	- (void)startStream:(NSMutableArray *)whichStation;
	- (void)startStream:(NSString *)whichStation;

	- (void)restartStream;
	- (void)play:(NSTimer *)urlStream;
	- (void)pause;
	- (void)fmodKill;
	- (void)changePan:(float)panRatio;
	- (void) killSoundForMenu;



@end
