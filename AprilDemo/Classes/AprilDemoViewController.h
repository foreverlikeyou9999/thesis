//
//  AprilDemoViewController.h
//  AprilDemo
//
//  Created by Russell de Moose on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <UIKit/UIKit.h> 
#include <Foundation/Foundation.h>
#include "CoreLocation/CoreLocation.h"
#include "AudioToolbox/AudioToolbox.h"
#include "OpenAL/al.h"
#include "OpenAL/alc.h"
#include <math.h>
#import "AprilDemoAppDelegate.h"
#import "Annotation.h"
#import <MapKit/MapKit.h>
#import "AudioStreamer.h"


@interface AprilDemoViewController : UIViewController <CLLocationManagerDelegate, MKAnnotation>

{
	
		// Map objects 
		
		MKMapView *map;	
		NSMutableArray *coordinates;
		
		
		CLLocationManager *locationManager; //For location updates.
		CLHeading *heading; //For compass readings
		
		
		// OpenAL and audio objects
		
		ALCcontext *mContext; //OpenAL Virtual Context
		ALCdevice *mDevice; //OpenAL device; connection to hardware
		
		NSMutableArray *bufferStorageArray;
		NSMutableArray *soundLibrary; //Library of NSDictionaries, each describing a track.
	
		AudioStreamer *streamer;
		
		
		BOOL tracking;
		BOOL soundsLoaded;
		UInt32 bufferSize;
		ALenum format;
		ALsizei freq;
		int numBuffers;
		UInt32 filterSize;
		float defaultGaussianC;
		float defaultGainScale;
		float gaussianC;
		float defaultGainFloor;
		float gainFloor;
		
	}
	
	@property (nonatomic, retain) IBOutlet MKMapView *map;
	@property (nonatomic, retain) NSMutableArray *coordinates;

	
	@property (readonly, nonatomic) IBOutlet UITextView *whereabouts;
	@property (nonatomic, retain) IBOutlet UIButton *loadingSounds;
	
	@property (nonatomic, retain) CLLocationManager *locationManager;
	
	
	
	// OpenAL and audio methods


	- (IBAction) annotate: (id)sender;

	
	- (void)initOpenAL; //Necessary OpenAL initializer method.
	- (IBAction)loadSounds:(NSString*)activeCategory; //Shadel-specific. Should not be needed. 
	- (AudioFileID)openAudioFile:(NSString *)filePath; //Opens audio file in OpenAL from NSString, returns an ID. 
	- (UInt32)audioFileSize:(AudioFileID)fileDescriptor; //Takes in Audio file and gives size
	- (BOOL)loadNextStreamingBufferForSound:(NSMutableDictionary*)record intoBuffer:(NSUInteger)bufferID; //loads next buffer for a given sound, which is an NSDictionary, into bufferID int.
	- (void)rotateBufferThread:(NSMutableDictionary*)record;
	- (BOOL)rotateBufferForStreamingSound:(NSMutableDictionary*)record;
	
	- (IBAction)togglePlayback:(id)sender;
	- (void)playAllSounds;
	- (void)pauseAllSounds;
	- (IBAction)stopAllSounds;
	- (void)playLongSoundFromRecord:(NSMutableDictionary*)record;
	- (void)cleanUpOpenAL:(id)sender; //Close up OpenAL
	
	- (IBAction)toggleTracking;
	
	- (IBAction)updateAngleWidth; //Shadel method for updating angle width from a slider. 
	- (IBAction)updateGainFloor; //Shadel method for gain scaling. 
	
	//- (unsigned char)convolve:(unsigned char*)outData forHeading:(float)heading;
	//- (unsigned char *)convolve:(unsigned char *)outData withFilter:(unsigned char *)filter forRecord:(NSMutableDictionary*)record;
	
	- (IBAction)showInfo:(id)sender; //?
	- (float)gaussianBellCurve:(float)difference; //Bell curve method for gain scaling
	- (void)convolve:(unsigned char *)outData withFilter:(unsigned char *)filter;


@end

