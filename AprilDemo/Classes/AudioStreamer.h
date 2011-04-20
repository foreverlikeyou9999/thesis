//
//  AudioStreamer.h
//  StreamingAudioPlayer
//
//  Created by Matt Gallagher on 27/09/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.

//  Edited by Russell de Moose, March 2011. 


#ifdef TARGET_OS_IPHONE			
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif TARGET_OS_IPHONE			

#include <pthread.h>
#include <AudioToolbox/AudioToolbox.h>

#define LOG_QUEUED_BUFFERS 0

#define kNumAQBufs 16			// Number of audio queue buffers we allocate.
// Needs to be big enough to keep audio pipeline
// busy (non-zero number of queued buffers) but
// not so big that audio takes too long to begin
// (kNumAQBufs * kAQBufSize of data must be
// loaded before playback will start).
// Set LOG_QUEUED_BUFFERS to 1 to log how many
// buffers are queued at any time -- if it drops
// to zero too often, this value may need to
// increase. Min 3, typical 8-24.

#define kAQBufSize 2048			// Number of bytes in each audio queue buffer
// Needs to be big enough to hold a packet of
// audio from the audio file. If number is too
// large, queuing of audio before playback starts
// will take too long.
// Highly compressed files can use smaller
// numbers (512 or less). 2048 should hold all
// but the largest packets. A buffer size error
// will occur if this number is too small.

#define kAQMaxPacketDescs 512	// Number of packet descriptions in our array
bool interruptedOnPlayback;

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

extern NSString * const ASStatusChangedNotification;

@interface AudioStreamer : NSObject 
{
	NSURL *url;
	
	//
	// Special threading consideration:
	//	The audioQueue property should only ever be accessed inside a
	//	synchronized(self) block and only *after* checking that ![self isFinishing]
	//
	AudioQueueRef audioQueue;
	AudioFileStreamID audioFileStream;	// the audio file stream parser
	
	AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];		// audio queue buffers
	AudioStreamPacketDescription packetDescs[kAQMaxPacketDescs];	// packet descriptions for enqueuing audio
	//This applies to VBR streaming audio. 
	unsigned int fillBufferIndex;	// the index of the audioQueueBuffer that is being filled
	size_t bytesFilled;				// how many bytes have been filled
	size_t packetsFilled;			// how many packets have been filled
	bool inuse[kNumAQBufs];			// flags to indicate that a buffer is still in use
	NSInteger buffersUsed;
	
	AudioStreamerState state;
	//AudioStreamerStopReason stopReason;
	//AudioStreamerErrorCode errorCode;
	OSStatus err;
	
	bool discontinuous;			// flag to indicate middle of the stream
	
	pthread_mutex_t queueBuffersMutex;			// a mutex to protect the inuse flags
	pthread_cond_t queueBufferReadyCondition;	// a condition varable for handling the inuse flags

	
	CFReadStreamRef stream; // reference to a stream object. 
	NSNotificationCenter *notificationCenter;
	
	NSUInteger dataOffset;
	UInt32 bitRate;
	
	bool seekNeeded;
	double seekTime;
	double sampleRate;
	double lastProgress;
	int numBuffersToEnqueueLater;
}

//@property AudioStreamerErrorCode errorCode;
@property (readonly) AudioStreamerState state;
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




@end






