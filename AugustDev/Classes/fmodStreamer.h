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
		FMOD::Sound	   *sound2;
		FMOD::Sound	   *sound3;
		FMOD::Channel  *channel;
		FMOD::Channel  *channel2;
		FMOD::Channel  *channel3;
		FMOD_VECTOR	listenerpos;
		FMOD_RESULT result;
		float pan;
		NSTimer *urlStream;
        NSTimer *urlStream2;
        NSTimer *urlStream3;
		NSString *url;
        NSString *url2;
        NSString *url3;
        NSString *search;
		
		unsigned int  version;
	}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *url2;
@property (nonatomic, retain) NSString *url3;
@property (nonatomic, retain) NSString *search;	

	- (void)createSystem;
    - (void)startStream:(NSString *)first andAlso:(NSString *)second andAlso:(NSString *)third;
//	- (void)startStream:(NSString *)whichStation;

	- (void)restartStream;
	- (void)play:(NSTimer *)urlStream;
	- (void)play2:(NSTimer *)urlStream2;
	- (void)play3:(NSTimer *)urlStream3;
	- (void)pause;
	- (void)fmodKill;
	- (void)changePan:(float)panRatio;
	- (void)setVolume:(float)volume;
	- (void) killSoundForMenu;



@end
