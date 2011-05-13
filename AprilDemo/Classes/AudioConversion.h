//
//  AudioConverter.h
//  AprilDemo
//
//  Created by Russell de Moose on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <pthread.h>

#define kAQMaxPacketDescs 512	// Number of packet descriptions in our array


typedef enum
{
	AS_INITIALIZED = 0,
	AS_STARTING_FILE_THREAD,
	AS_WAITING_FOR_DATA,
	AS_WAITING_FOR_QUEUE_TO_START,
	AS_PLAYING,
	AS_BUFFERING,
	AS_STOPPING,
	AS_STOPPED,
	AS_PAUSED
} AudioStreamerState; //enumerated anonymous data type, now solely known as an AudioStreamerState.

typedef struct MyAudioConverterSettings {
	AudioStreamBasicDescription inASBD; 
	AudioStreamBasicDescription outASBD;
	AudioFileID inputFile; 
	AudioFileID outputFile;
	
	UInt64 inputFilePacketIndex; 
	UInt64 inputFilePacketCount; 
	UInt32 inputFilePacketMaxSize;
	AudioStreamPacketDescription *inputFilePacketDescriptions;
	
	UInt32 bytesPerPacket;
	
	//void *sourceBuffer; 
	
} MyAudioConverterSettings;



@interface AudioConversion : NSObject {
	
	NSAutoreleasePool * pool;

	
	
	OSStatus err;	
	UInt32 packetsPerBuffer;
	UInt32 outputBufferSize;
	SInt64 offset;
	//UInt8 bytes;
	UInt32 outputBuffer;
	
	//------Stream variables--------//
	
	CFReadStreamRef stream; // reference to a stream object. 
	UInt32 bytesPerPacket;
	UInt32 maxPacketSize;
	size_t bytesFilled;
	size_t packetsFilled;
	size_t bytesPerBuffer;
	UInt32 bitRate;
	bool discontinuous;			// flag to indicate middle of the stream
	
	NSURL *url;
	NSInteger *buffersUsed;
	pthread_mutex_t queueBuffersMutex;			// a mutex to protect the inuse flags
	pthread_cond_t queueBufferReadyCondition;	// a condition variable for handling the inuse flags
	
	AudioFileStreamID audioFileStream;
	AudioStreamerState state;
	
	//--------Input to audio converter----------//
	
	void *sourceBuffer; //April 27. Moving this buffer to an instance variable, rather than member of structure. 
	
	MyAudioConverterSettings audioConverterSettings;
}

@property (readwrite) AudioStreamerState state;
@property (readwrite) UInt32 bitRate;



- (void)start;
- (BOOL)isPaused;
- (BOOL)isWaiting;
- (BOOL)isIdle;
- (void)startConversion;
- (BOOL)isFinishing;
- (BOOL)openFileStream;

- (id) initWithURL:(NSURL *) someURL;


//- (void)provideAudio: (AudioConverterRef)converter 					  
//		    inputData:(AudioBufferList) ioData
//		    numberPackets:(UInt32) ioNumberDataPackets
//			outASPD:(AudioStreamPacketDescription *) outDataPacketDescription;

- (void)audioToConverter:(const void *)inInputData
			 numberBytes:(UInt32)inNumberBytes
		   numberPackets:(UInt32)inNumberPackets
	  packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;

- (void)streamProperties:(AudioFileStreamID)inAudioFileStream
	fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID
				 ioFlags:(UInt32 *)ioFlags; 

 

@end
