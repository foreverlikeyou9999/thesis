//
//  MapViewController.h
//  MayDemo
//
//  Created by Russell de Moose on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <UIKit/UIKit.h> 
#include <Foundation/Foundation.h>
#include "CoreLocation/CoreLocation.h"
#include "AudioToolbox/AudioToolbox.h"
#include "OpenAL/al.h"
#include "OpenAL/alc.h"
#include <math.h>
#import "MayDemoAppDelegate.h"
#import "Annotation.h"
#import <MapKit/MapKit.h>
#import "MayDemoViewController.h"
//#import "AudioConversion.h"
#import "Options.h"	
#import "AudioStreamer.h"
	
	@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> 
	
	{

	
		
		// ------------Map objects----------// 
		
		IBOutlet MKMapView *map;	
		MKPinAnnotationView *pin;
		NSMutableArray *coordinates;
	

		
		
		CLLocationManager *locationManager; //For location updates.
		CLHeading *heading; //For compass readings
		
		
		//--------- OpenAL and audio objects--------------//
		
		ALCcontext *mContext; //OpenAL Virtual Context
		ALCdevice *mDevice; //OpenAL device; connection to hardware
		
		NSMutableArray *bufferStorageArray;
		NSMutableArray *soundLibrary; //Library of NSDictionaries, each describing a track.
		
	//	AudioConversion *convert;
		void *convert;
		AudioStreamer *streamer;
		AudioStreamer *streamer2;
		
		BOOL tracking;
		BOOL soundsLoaded;
		UInt32 bufferSize;
		ALenum format;
		ALsizei freq;
		int numBuffers;
		UInt32 filterSize;
	
		// ----Options iVars------//
		

		float defaultGaussianC;
		float defaultGainScale;
		float gaussianC;
		float defaultGainFloor;
		float gainFloor;
		
		
		IBOutlet UIBarButtonItem *optionsSelect;
		IBOutlet UISlider *angleWidthSlider;
		IBOutlet UILabel *angleWidthSliderValue;
		IBOutlet UISlider *gainFloorSlider;
		IBOutlet UILabel *gainFloorSliderValue;



	}


//----------- View methods------------//

	

	@property (nonatomic, retain) IBOutlet MKMapView *map;
	@property (nonatomic, retain) MKPinAnnotationView *pin;
	@property (nonatomic, retain) NSMutableArray *coordinates;
	@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
	
	@property (nonatomic, retain) CLLocationManager *locationManager;

	@property (nonatomic, retain) IBOutlet UIBarButtonItem *optionsSelect;	


	
	//----------- View methods------------//
	
	
	- (void)createConverter;
	- (IBAction) annotate: (id)sender;
	
	//---------- OpenAL and audio methods------------//
	
	- (void)initOpenAL; //Necessary OpenAL initializer method.
	//- (IBAction)loadSounds:(NSString*)activeCategory; //Shadel-specific. Should not be needed. 
	-(void) loadSounds;
	- (AudioFileID)openAudioFile; //Opens audio file in OpenAL from NSString, returns an ID. 
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
	- (void)loadSounds;
	
	//- (IBAction)toggleTracking;
	
	- (IBAction)updateAngleWidth; //Shadel method for updating angle width from a slider. 
	- (IBAction)updateGainFloor; //Shadel method for gain scaling. 
	
	//- (unsigned char)convolve:(unsigned char*)outData forHeading:(float)heading;
	//- (unsigned char *)convolve:(unsigned char *)outData withFilter:(unsigned char *)filter forRecord:(NSMutableDictionary*)record;
	
	//- (IBAction)showInfo:(id)sender; //?
	- (float)gaussianBellCurve:(float)difference; //Bell curve method for gain scaling
	- (void)convolve:(unsigned char *)outData withFilter:(unsigned char *)filter;

	- (IBAction)showOptions:(id)sender;

//	- (IBAction) sourceSelect: (id)sender;

	- (void)createStreamer;
	
	@end







