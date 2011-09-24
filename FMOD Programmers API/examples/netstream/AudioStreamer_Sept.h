//
//  AudioStreamer.h
//  StreamingAudioPlayer
//
//  Created by Matt Gallagher on 27/09/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.

//  Edited by Russell de Moose, March 2011. 


		
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
		
#include <pthread.h>
 
#include <AudioToolbox/AudioToolbox.h>
#import "fmod.hpp"
#import "fmod_errors.h"

#define LOG_QUEUED_BUFFERS 0

#define kNumFMODBufs 16			// Number of audio queue buffers we allocate.
// Needs to be big enough to keep audio pipeline
// busy (non-zero number of queued buffers) but
// not so big that audio takes too long to begin
// (kNumAQBufs * kAQBufSize of data must be
// loaded before playback will start).
// Set LOG_QUEUED_BUFFERS to 1 to log how many
// buffers are queued at any time -- if it drops
// to zero too often, this value may need to
// increase. Min 3, typical 8-24.

#define kFMODBufSize 2048			// Number of bytes in each audio queue buffer
// Needs to be big enough to hold a packet of
// audio from the audio file. If number is too
// large, queuing of audio before playback starts
// will take too long.
// Highly compressed files can use smaller
// numbers (512 or less). 2048 should hold all
// but the largest packets. A buffer size error
// will occur if this number is too small.

#define kFMODMaxPacketDescs 512	// Number of packet descriptions in our array


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
	} AudioStreamerState;

typedef enum
	{
		AS_NO_STOP = 0,
		AS_STOPPING_EOF,
		AS_STOPPING_USER_ACTION,
		AS_STOPPING_ERROR,
		AS_STOPPING_TEMPORARILY
	} AudioStreamerStopReason;

typedef enum
	{
		AS_NO_ERROR = 0,
		AS_NETWORK_CONNECTION_FAILED,
		AS_FILE_STREAM_GET_PROPERTY_FAILED,
		AS_FILE_STREAM_SEEK_FAILED,
		AS_FILE_STREAM_PARSE_BYTES_FAILED,
		AS_FILE_STREAM_OPEN_FAILED,
		AS_FILE_STREAM_CLOSE_FAILED,
		AS_AUDIO_DATA_NOT_FOUND,
		AS_AUDIO_QUEUE_CREATION_FAILED,
		AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED,
		AS_AUDIO_QUEUE_ENQUEUE_FAILED,
		AS_AUDIO_QUEUE_ADD_LISTENER_FAILED,
		AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED,
		AS_AUDIO_QUEUE_START_FAILED,
		AS_AUDIO_QUEUE_PAUSE_FAILED,
		AS_AUDIO_QUEUE_BUFFER_MISMATCH,
		AS_AUDIO_QUEUE_DISPOSE_FAILED,
		AS_AUDIO_QUEUE_STOP_FAILED,
		AS_AUDIO_QUEUE_FLUSH_FAILED,
		AS_AUDIO_STREAMER_FAILED,
		AS_GET_AUDIO_TIME_FAILED,
		AS_AUDIO_BUFFER_TOO_SMALL,
		
		//FMOD ERRORS
		AS_FMOD_FAILED
		
	} AudioStreamerErrorCode;

extern NSString * const ASStatusChangedNotification;

@interface AudioStreamer_Sept : NSObject 
{
	NSURL *url;
	
	//
	// Special threading consideration:
	//	The audioQueue property should only ever be accessed inside a
	//	synchronized(self) block and only *after* checking that ![self isFinishing]
	//

	AudioFileStreamID audioFileStream;	// the audio file stream parser

	AudioStreamPacketDescription packetDescs[kFMODMaxPacketDescs];	// packet descriptions for enqueuing audio
	unsigned int fillBufferIndex;	// the index of the audioQueueBuffer that is being filled
	size_t bytesFilled;				// how many bytes have been filled
	size_t packetsFilled;			// how many packets have been filled
	bool inuse[kNumFMODBufs];			// flags to indicate that a buffer is still in use
	NSInteger buffersUsed;
	
	AudioStreamerState state;
	AudioStreamerStopReason stopReason;
	AudioStreamerErrorCode errorCode; 
	OSStatus err;
	
	bool discontinuous;			// flag to indicate middle of the stream
	bool paused;
	
	pthread_mutex_t queueBuffersMutex;			// a mutex to protect the inuse flags
	pthread_cond_t queueBufferReadyCondition;	// a condition varable for handling the inuse flags
	
	CFReadStreamRef stream;
	NSNotificationCenter *notificationCenter;
	
	NSUInteger dataOffset;
	UInt32 bitRate;
	 
	bool seekNeeded;
	double seekTime;
	double sampleRate;
	double lastProgress;
	int numBuffersToEnqueueLater;
	
	FMOD::System   *system;
    FMOD::Sound    *sound;
    FMOD::Channel  *channel;
	FMOD_VECTOR	listenerpos;
	FMOD_RESULT result;
	float pan;
}

@property AudioStreamerErrorCode errorCode;
@property (readwrite) AudioStreamerState state;
@property (readonly) double progress;
@property (readwrite) UInt32 bitRate;


- (id)initWithURL:(NSURL *)aURL;
- (void)start;
- (void)stop;
- (void)pause;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isWaiting;
- (BOOL)isIdle;


/* FMOD Methods */

- (void)startStream;
- (void)pause;
- (void)fmodKill;
- (void)soundKill; 
- (void)changePan:(float)panRatio;

/* FMOD Methods */

/* Stream Callback Wrapper Methods */

- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream
					 fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID
								  ioFlags:(UInt32 *)ioFlags;

- (void)handleAudioPackets:(const void *)inInputData
			   numberBytes:(UInt32)inNumberBytes
			 numberPackets:(UInt32)inNumberPackets
		packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;

- (void)handleInterruptionChangeToState:(AudioQueuePropertyID)inInterruptionState;

- (void)handleReadFromStream:(CFReadStreamRef)aStream
				   eventType:(CFStreamEventType)eventType;

- (void) enqueueBuffer;

/* Stream Callback Wrapper Methods */





@end






