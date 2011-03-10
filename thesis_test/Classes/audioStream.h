//
//  audioStream.h
//  thesis_test
//
//  Created by Russell de Moose on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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




@interface audioStream : NSObject {

	ALCcontext* mContext;
	ALCdevice* mDevice;
	NSMutableDictionary *soundDictionary;
	NSMutableArray *bufferStorageArray;
	
}




@property (nonatomic, retain) NSMutableDictionary *soundDictionary;
@property (nonatomic, retain) NSMutableArray *bufferStorageArray;	
@property (nonatomic, readonly) ALCdevice *mDevice;
@property (nonatomic, readonly) ALCcontext *mContext;

/*


- (void) initOpenAL;
- (AudioFileID) openAudioFile:(NSString *)filePath; 
- (NSMutableDictionary *) initializeStreamFromFile:(NSString *)fileName format:(ALenum)format freq:(ALsizei)freq;
- (NSUInteger)playStream:(NSString*)soundKey gain:(ALfloat)gain pitch:(ALfloat)pitch loops:(BOOL)loops;
- (UInt32) audioFileSize:(AudioFileID)fileDescriptor;
- (void) playSound:(NSString*)soundKey;
- (void) stopSound:(NSString*)soundKey;
- (void) cleanUpOpenAL:(id)sender;
- (void)rotateBufferThread:(NSString*)soundKey;
- (BOOL)rotateBufferForStreamingSound:(NSString*)soundKey;

*/

@end
