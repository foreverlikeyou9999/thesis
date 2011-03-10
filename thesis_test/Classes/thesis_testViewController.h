

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import "thesis_testAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

//------------------------------// testing OpenAL 

#import "audioPlayback.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "audioStream.h"
#import "Annotation.h"



@interface thesis_testViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate>  {
	
	MKMapView *map;	  
	//audioPlayback *audioPlayer;
	audioStream *audioStreamer;
	IBOutlet UITextView *whereabouts; 
	BOOL soundsloaded; 

	//---Shadel variables, for OpenAL formatting and gaussian bell curve adjustments ----//
	
	BOOL tracking;
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

	
	
	//------------openAL test-------------//
		
ALCcontext* mContext;
ALCdevice* mDevice;
NSMutableDictionary *soundDictionary;
NSMutableArray *bufferStorageArray;
 

	
}



//@property (nonatomic, retain) NSMutableDictionary *soundDictionary;
//@property (nonatomic, retain) NSMutableArray *bufferStorageArray;	
@property (nonatomic, readonly) ALCdevice *mDevice;
@property (nonatomic, readonly) ALCcontext *mContext;

 


//@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (readonly, nonatomic) IBOutlet UITextView *whereabouts;

//@property (nonatomic, retain) audioPlayback *audioPlayer;
@property (nonatomic, retain) audioStream * audioStreamer;

/*

- (IBAction)playFile:(id)sender;
- (IBAction)stopFile:(id)sender;
- (IBAction) playSound:(NSString *)soundKey;
- (void) initOpenAL;
 
*/ 


- (void) initOpenAL;
- (void) playSound:(NSString*)soundKey;
- (AudioFileID) openAudioFile:(NSString *)filePath;
- (UInt32) audioFileSize:(AudioFileID)fileDescriptor;



@end

