//
//  audioPlayback.h
//  thesis_test
//
//  Created by Russell de Moose on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>



@interface audioPlayback : NSObject {
	
	
	ALCcontext* mContext;
	ALCdevice* mDevice;
	NSMutableDictionary *soundDictionary;
	NSMutableArray *bufferStorageArray;
}

@property (nonatomic, retain) NSMutableDictionary *soundDictionary;
@property (nonatomic, retain) NSMutableArray *bufferStorageArray;	
@property (nonatomic, readonly) ALCdevice *mDevice;
@property (nonatomic, readonly) ALCcontext *mContext;


- (void) initOpenAL;
- (AudioFileID) openAudioFile:(NSString *)filePath;
//- (AudioFileID) openAudioFile;
- (UInt32) audioFileSize:(AudioFileID)fileDescriptor;
- (void) prepareOpenAL;
- (void) playSound:(NSString*)soundKey;
- (void) stopSound:(NSString*)soundKey;
- (void) cleanUpOpenAL:(id)sender;


@end
 
 
