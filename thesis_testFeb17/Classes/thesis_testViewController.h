

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



@interface thesis_testViewController : UIViewController {
	
	MKMapView *map;	  
	IBOutlet UIButton *play; 
	audioPlayback *audioPlayer;
	IBOutlet UITextView *whereabouts; 
	
	//------------openAL test-------------//
	
/*	
	
ALCcontext* mContext;
ALCdevice* mDevice;
NSMutableDictionary *soundDictionary;
NSMutableArray *bufferStorageArray;
 
 */
	
}

/*

@property (nonatomic, retain) NSMutableDictionary *soundDictionary;
@property (nonatomic, retain) NSMutableArray *bufferStorageArray;	
@property (nonatomic, readonly) ALCdevice *mDevice;
@property (nonatomic, readonly) ALCcontext *mContext;
 
 
 */

//@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (readonly, nonatomic) IBOutlet UITextView *whereabouts;
@property (nonatomic, retain) IBOutlet UIButton *play;
@property (nonatomic, retain) audioPlayback *audioPlayer;

-(IBAction)playFile:(id)sender;


/*

- (IBAction)playFile:(id)sender;
- (IBAction)stopFile:(id)sender;
- (IBAction) playSound:(NSString *)soundKey;
- (void) initOpenAL;
 
*/ 
 
- (AudioFileID) openAudioFile:(NSString *)filePath;
- (UInt32) audioFileSize:(AudioFileID)fileDescriptor;



@end

