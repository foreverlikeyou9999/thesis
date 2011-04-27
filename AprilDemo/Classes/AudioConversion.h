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



@interface AudioConversion : NSObject {
	
	OSStatus err;
	CFReadStreamRef stream; // reference to a stream object. 
	UInt32 bytesPerPacket;
	UInt32 packetsPerBuffer;
	UInt32 outputBufferSize;
	SInt64 offset;
	//UInt8 bytes;
	UInt8 outputBuffer;
	UInt32 maxPacketSize;
	size_t bytesFilled;
	size_t packetsFilled;
	size_t bytesPerBuffer;
	UInt32 bitRate;
	bool discontinuous;			// flag to indicate middle of the stream
	
	AudioStreamerState state;

}

- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isWaiting;
- (BOOL)isIdle;
- (void)startConversion;




- (void)audioToConverter:(const void *)inInputData
			 numberBytes:(UInt32)inNumberBytes
		   numberPackets:(UInt32)inNumberPackets
	  packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;

- (void)streamProperties:(AudioFileStreamID)inAudioFileStream
	fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID
				 ioFlags:(UInt32 *)ioFlags; 

 

@end
