#import "AudioStreamer_Sept.h"		 
#import <CFNetwork/CFNetwork.h>
 

NSString * const ASStatusChangedNotification = @"ASStatusChangedNotification";
NSString * const AS_NO_ERROR_STRING = @"No error.";
NSString * const AS_FILE_STREAM_GET_PROPERTY_FAILED_STRING = @"File stream get property failed.";
NSString * const AS_FILE_STREAM_SEEK_FAILED_STRING = @"File stream seek failed.";
NSString * const AS_FILE_STREAM_PARSE_BYTES_FAILED_STRING = @"Parse bytes failed.";
NSString * const AS_FILE_STREAM_OPEN_FAILED_STRING = @"Open audio file stream failed.";  
NSString * const AS_FILE_STREAM_CLOSE_FAILED_STRING = @"Close audio file stream failed.";
NSString * const AS_GET_AUDIO_TIME_FAILED_STRING = @"Audio queue get current time failed.";
NSString * const AS_AUDIO_STREAMER_FAILED_STRING = @"Audio playback failed"; 
NSString * const AS_NETWORK_CONNECTION_FAILED_STRING = @"Network connection failed";
NSString * const AS_AUDIO_BUFFER_TOO_SMALL_STRING = @"Audio packets are larger than kAQBufSize.";


// Added on September 19, to keep error reporting structure intact with new systems.

NSString * const AS_FMOD_FAILED_STRING = @"FMOD System Failed. Take it up with them.";
bool interruptedOnPlayback;

#pragma mark Audio Callback Function Prototypes

void interruptionListenerCallback( void    *inUserData, UInt32    interruptionState ); 		

void MyPropertyListenerProc(	void *							inClientData,
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags);

void MyPacketsProc(				void *							inClientData,
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions);

OSStatus MyEnqueueBuffer(AudioStreamer_Sept* myData);

		
void MyAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState);

#pragma mark Audio Callback Function Implementations


//
// MyPropertyListenerProc
//
// Receives notification when the AudioFileStream has audio packets to be
// played. In response, this function creates the AudioQueue, getting it
// ready to begin playback (playback won't begin until audio packets are
// sent to the queue in MyEnqueueBuffer).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// kAudioQueueProperty_IsRunning listening added.
//


void MyPropertyListenerProc(	void *							inClientData,
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags)
{	
	// this is called by audio file stream when it finds property values
	AudioStreamer_Sept* streamer = (AudioStreamer_Sept *)inClientData;
	[streamer
		handlePropertyChangeForFileStream:inAudioFileStream
		fileStreamPropertyID:inPropertyID
		ioFlags:ioFlags];
}


//
// MyPacketsProc
//
// When the AudioStream has packets to be played, this function gets an
// idle audio buffer and copies the audio packets into it. The calls to
// MyEnqueueBuffer won't return until there are buffers available (or the
// playback has been stopped).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
void MyPacketsProc(				void *							inClientData,
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions)
{
	// this is called by audio file stream when it finds packets of audio
	AudioStreamer_Sept * streamer = (AudioStreamer_Sept *)inClientData;
	[streamer
		handleAudioPackets:inInputData
		numberBytes:inNumberBytes
		numberPackets:inNumberPackets
		packetDescriptions:inPacketDescriptions];
}

#ifdef TARGET_OS_IPHONE			
//
// MyAudioSessionInterruptionListener
//
// Invoked if the audio session is interrupted (like when the phone rings)
//
void MyAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	
	NSLog(@"Audio session interruption");
	
	AudioStreamer_Sept* streamer = (AudioStreamer_Sept *)inClientData;
	[streamer handleInterruptionChangeToState:inInterruptionState];
}


void interruptionListenerCallback (void *inUserData, UInt32 interruptionState) {
	
	// This callback, being outside the implementation block, needs a reference 
	//to the AudioPlayer object
	AudioStreamer_Sept *player = (AudioStreamer_Sept *)inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) {
		NSLog(@"kAudioSessionBeginInterruption");
        //if ([player audioStreamer]) {
			// if currently playing, pause
			[player pause];
			interruptedOnPlayback = YES;
        //}
		
	}// else if ((interruptionState == kAudioSessionEndInterruption) && player.interruptedOnPlayback) {
		else if (interruptionState == kAudioSessionEndInterruption) {
			NSLog(@"kAudioSessionEndInterruption");
			  AudioSessionSetActive( true );

        // if the interruption was removed, and the app had been playing, resume playback
        [player start];
        interruptedOnPlayback = NO;
			//	player.state = AS_PAUSED;
	}
}

#endif

#pragma mark CFReadStream Callback Function Implementations

//
// ReadStreamCallBack
//
// This is the callback for the CFReadStream from the network connection. This
// is where all network data is passed to the AudioFileStream.
//
// Invoked when an error occurs, the stream ends or we have data to read.
//
void ASReadStreamCallBack
(
   CFReadStreamRef aStream,
   CFStreamEventType eventType,
   void* inClientInfo
)
{
	AudioStreamer_Sept* streamer = (AudioStreamer_Sept *)inClientInfo;
	[streamer handleReadFromStream:aStream eventType:eventType];
}

@implementation AudioStreamer_Sept

@synthesize errorCode;
@synthesize state;
@synthesize bitRate;
@dynamic progress;


const float distanceFactor = 1.0f;
char buffer[2048] = {0};


/* FMOD Methods */


//-----------------------------------------//
void ERRCHECK(FMOD_RESULT result)
{
    if (result != FMOD_OK)
    {
        fprintf(stderr, "FMOD error! (%d) %s\n", result, FMOD_ErrorString(result));
        exit(-1);
    }
}
//-----------------------------------------//


//-----------------------------------------//
- (void)startStream 
{
	
	/* From previous viewDidLoad method. Moved in an attempt to MVC this billy. */
	
	
	listenerpos.x = 30.0f;
	listenerpos.y = 0.0f;
	listenerpos.z = -1.0f * distanceFactor;
	
	/* End MVC change. */
	
	
    result = FMOD_OK;
	
	/* --------Changing buffer to match audioStreamer buffer object size---------
	 char          buffer[200]   = {0};
	 */ 
	
	//char buffer[2048] = {0};
    unsigned int  version       = 0;
	
    /*
	 Create a System object and initialize
	 */    
    result = FMOD::System_Create(&system); 
    ERRCHECK(result);
    
    result = system->getVersion(&version);
    ERRCHECK(result);
    
    if (version < FMOD_VERSION)
    {
        fprintf(stderr, "You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
        exit(-1);
    }
	
    result = system->init(1, FMOD_INIT_NORMAL | FMOD_INIT_ENABLE_PROFILE, NULL);
    ERRCHECK(result);
    
    /*
	 Bump up the file buffer size a little bit for netstreams (to account for lag)
	 */
	
	/*----Change to match audioStreamer buffer size
	 result = system->setStreamBufferSize(64 * 1024, FMOD_TIMEUNIT_RAWBYTES); 
	 */
	
	result = system->setStreamBufferSize(2048, FMOD_TIMEUNIT_RAWBYTES);
    ERRCHECK(result); 
		
	/*
	 Set the distance units. (meters/feet etc)
	 */
    result = system->set3DSettings(1.0, distanceFactor, 1.0f);
    ERRCHECK(result);   
	
	
	// Play sounds.
	
	//[[NSString stringWithFormat:@"%@/SnowWhite.m4a", [[NSBundle mainBundle] resourcePath]] getCString:buffer maxLength:200 encoding:NSASCIIStringEncoding];
	//result = system->createSound(buffer, FMOD_SOFTWARE | FMOD_3D | FMOD_LOOP_NORMAL, NULL, &sound);
	//result = system->createSound(buffer, FMOD_SOFTWARE | FMOD_2D | FMOD_LOOP_NORMAL, NULL, &sound);
	//ERRCHECK(result);
	
	//result = system->playSound(FMOD_CHANNEL_FREE, sound, true, &channel);
	//ERRCHECK(result);
	
	NSLog(@"FMOD system started");
	
	FMOD_VECTOR pos = { 1.0f * distanceFactor, 0.0f, 0.0f };
	FMOD_VECTOR vel = {  0.0f, 0.0f, 0.0f };
	
	
	
	//result = channel->set3DAttributes(&pos, &vel);
	//ERRCHECK(result);
	
	result = channel->setPan(20.0f);
	
	result = channel->setPaused(false);
	ERRCHECK(result);
	paused  = false;
	state == AS_PLAYING;
	
}
//-----------------------------------------//



//-----------------------------------------//
- (void) fmodKill 

{
	
	NSLog(@"Killing FMOD? Bigger jerk.");
	
	if (sound)
	{
		sound->release();
		sound = NULL;
	}

	if (system)
	{
		system->release();
		system = NULL;
	}    

	
}
//-----------------------------------------//


//-----------------------------------------//
- (void) soundKill 
{
	
	NSLog(@"Killing sound? Jerk.");
	
	if (channel != NULL)
	{
		channel->stop();
		channel = NULL;
	}
	
	if (sound != NULL)
	{
		sound->release();
		sound = NULL;
	}
	   
}
//-----------------------------------------//


//-----------------------------------------//
- (void)changePan:(float)panRatio
{

	result = channel->setPan(panRatio);
	ERRCHECK(result);
	
}


/* End FMOD methods */




//-----------------------------------------//
// Init method for the object.
//
- (id)initWithURL:(NSURL *)aURL
{
	self = [super init];
	if (self != nil)
	{
		url = [aURL retain];
	}
	
	
	AudioSessionInitialize( NULL,
						   NULL,
						   interruptionListenerCallback,
						   self );
	  AudioSessionSetActive( true );
    
  /* UInt32 sessionCategory = kAudioSessionCategory_UserInterfaceSoundEffects;
    AudioSessionSetProperty( kAudioSessionProperty_AudioCategory,
							sizeof(sessionCategory),
							&sessionCategory );
    
    
    // create audio queue
    int frameCount = 512;
    
    AudioStreamBasicDescription audioFormat;
    
    audioFormat.mSampleRate = kAQMaxPacketDescs;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mBytesPerPacket = 4;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mBytesPerFrame = 4;
    audioFormat.mChannelsPerFrame = 2;
    audioFormat.mBitsPerChannel = 16;
	
    AudioSessionSetActive( true );
*/
	
		
	return self;
}
//-----------------------------------------//


//-----------------------------------------//
// Releases instance memory.
//
- (void)dealloc
{
	[self stop];
	[notificationCenter release];
	[url release];
	[super dealloc];
	sound->release();
	system->release();
	
}
//-----------------------------------------//


//-----------------------------------------//
// returns YES if the audio has reached a stopping condition.
//
- (BOOL)isFinishing
{
	@synchronized (self)
	{
		if ((errorCode != AS_NO_ERROR && state != AS_INITIALIZED) ||
			((state == AS_STOPPING || state == AS_STOPPED) &&
				stopReason != AS_STOPPING_TEMPORARILY))
		{
			return YES;
		}
	}
	
	return NO;
}
//-----------------------------------------//


//-----------------------------------------//
// returns YES if the run loop should exit.
//
- (BOOL)runLoopShouldExit
{
	@synchronized(self)
	{
		if (errorCode != AS_NO_ERROR ||
			(state == AS_STOPPED &&
			stopReason != AS_STOPPING_TEMPORARILY))
		{
			return YES;
		}
	}
	
	return NO;
}
//-----------------------------------------//


//-----------------------------------------//
// Converts an error code to a string that can be localized or presented
// to the user.
//
// Parameters:
//    anErrorCode - the error code to convert
//
// returns the string representation of the error code
//
+ (NSString *)stringForErrorCode:(AudioStreamerErrorCode)anErrorCode
{
	switch (anErrorCode)
	{
		case AS_NO_ERROR:
			return AS_NO_ERROR_STRING;
		case AS_FILE_STREAM_GET_PROPERTY_FAILED:
			return AS_FILE_STREAM_GET_PROPERTY_FAILED_STRING;
		case AS_FILE_STREAM_SEEK_FAILED:
			return AS_FILE_STREAM_SEEK_FAILED_STRING;
		case AS_FILE_STREAM_PARSE_BYTES_FAILED:
			return AS_FILE_STREAM_PARSE_BYTES_FAILED_STRING;
		case AS_FILE_STREAM_OPEN_FAILED:
			return AS_FILE_STREAM_OPEN_FAILED_STRING;
		case AS_FILE_STREAM_CLOSE_FAILED:
			return AS_FILE_STREAM_CLOSE_FAILED_STRING;
		case AS_GET_AUDIO_TIME_FAILED:
			return AS_GET_AUDIO_TIME_FAILED_STRING;
		case AS_NETWORK_CONNECTION_FAILED:
			return AS_NETWORK_CONNECTION_FAILED_STRING;
		case AS_AUDIO_STREAMER_FAILED:
			return AS_AUDIO_STREAMER_FAILED_STRING;
		case AS_AUDIO_BUFFER_TOO_SMALL:
			return AS_AUDIO_BUFFER_TOO_SMALL_STRING;
			
		//Conforming to previous structure with FMOD	
		case AS_FMOD_FAILED:
			return AS_FMOD_FAILED_STRING;
			
		default:
			return AS_AUDIO_STREAMER_FAILED_STRING;
	}
	
	return AS_AUDIO_STREAMER_FAILED_STRING;
}
//-----------------------------------------//


//-----------------------------------------//
// Sets the playback state to failed and logs the error.
//
// Parameters:
//    anErrorCode - the error condition
//
- (void)failWithErrorCode:(AudioStreamerErrorCode)anErrorCode
{
	@synchronized(self)
	{
		if (errorCode != AS_NO_ERROR)
		{
			// Only set the error once.
			return;
		}
		
		errorCode = anErrorCode;

		if (err)
		{
			char *errChars = (char *)&err;
			NSLog(@"%@ err: %c%c%c%c %d\n",
				[AudioStreamer_Sept stringForErrorCode:anErrorCode],
				errChars[3], errChars[2], errChars[1], errChars[0],
				(int)err);
		}
		else
		{
			NSLog(@"%@", [AudioStreamer_Sept stringForErrorCode:anErrorCode]);
		}

		if (state == AS_PLAYING ||
			state == AS_PAUSED ||
			state == AS_BUFFERING)
		{
			self.state = AS_STOPPING;
			stopReason = AS_STOPPING_ERROR;
			
			if (channel != NULL)
			{
				channel->stop();
				
			}
			
			if (sound != NULL)
			{
				sound->release();
				
			}
		}

#ifdef TARGET_OS_IPHONE			
		UIAlertView *alert =
			[[[UIAlertView alloc]
				initWithTitle:NSLocalizedStringFromTable(@"Audio Error", @"Errors", nil)
				message:NSLocalizedStringFromTable([AudioStreamer_Sept stringForErrorCode:self.errorCode], @"Errors", nil)
				delegate:self
				cancelButtonTitle:@"OK"
				otherButtonTitles: nil]
			autorelease];
		[alert 
			performSelector:@selector(show)
			onThread:[NSThread mainThread]
			withObject:nil
			waitUntilDone:NO];
#else
		NSAlert *alert =
			[NSAlert
				alertWithMessageText:NSLocalizedString(@"Audio Error", @"")
				defaultButton:NSLocalizedString(@"OK", @"")
				alternateButton:nil
				otherButton:nil
				informativeTextWithFormat:[AudioStreamer stringForErrorCode:self.errorCode]];
		[alert
			performSelector:@selector(runModal)
			onThread:[NSThread mainThread]
			withObject:nil
			waitUntilDone:NO];
#endif
	}
}
//-----------------------------------------//


//-----------------------------------------//
// Sets the state and sends a notification that the state has changed.
//
// Parameters:
//    anErrorCode - the error condition
//
- (void)setState:(AudioStreamerState)aStatus
{
	@synchronized(self)
	{
		if (state != aStatus)
		{
			state = aStatus;
			
			NSNotification *notification =
				[NSNotification
					notificationWithName:ASStatusChangedNotification
					object:self];
			[notificationCenter
				performSelector:@selector(postNotification:)
				onThread:[NSThread mainThread]
				withObject:notification
				waitUntilDone:NO];
		}
	}
}
//-----------------------------------------//



//-----------------------------------------//
// returns YES if the audio currently playing.
//
- (BOOL)isPlaying
{
	if (state == AS_PLAYING)
	{
		return YES;
	}
	
	return NO;
}
//-----------------------------------------//


//-----------------------------------------//
// returns YES if the audio currently playing.
//
- (BOOL)isPaused
{
	if (state == AS_PAUSED)
	{
		return YES;
	}
	
	return NO;
}
//-----------------------------------------//


//-----------------------------------------//
// returns YES if the AudioStreamer is waiting for a state transition of some
// kind.
//
- (BOOL)isWaiting
{
	@synchronized(self)
	{
		if ([self isFinishing] ||
			state == AS_STARTING_FILE_THREAD||
			state == AS_WAITING_FOR_DATA ||
			state == AS_WAITING_FOR_QUEUE_TO_START ||
			state == AS_BUFFERING)
		{
			return YES;
		}
	}
	
	return NO;
}
//-----------------------------------------//


//-----------------------------------------//
// returns YES if the AudioStream is in the AS_INITIALIZED state (i.e.
// isn't doing anything).
//
- (BOOL)isIdle
{
	if (state == AS_INITIALIZED)
	{
		return YES;
	}
	
	return NO;
}
//-----------------------------------------//


//-----------------------------------------//
// Open the audioFileStream to parse data and the fileHandle as the data
// source.
//
- (BOOL)openFileStream
{
	@synchronized(self)
	{
		NSAssert(stream == nil && audioFileStream == nil,
			@"audioFileStream already initialized");
		
		//
		// Attempt to guess the file type from the URL. Reading the MIME type
		// from the CFReadStream would be a better approach since lots of
		// URL's don't have the right extension.
		//
		// If you have a fixed file-type, you may want to hardcode this.
		//
		
		
		//AudioFileTypeID fileTypeHint = kAudioFileAAC_ADTSType;
		AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
		
		NSString *fileExtension = [[url path] pathExtension];
		if ([fileExtension isEqual:@"mp3"])
		{
			fileTypeHint = kAudioFileMP3Type;
		}
		else if ([fileExtension isEqual:@"wav"])
		{
			fileTypeHint = kAudioFileWAVEType;
		}
		else if ([fileExtension isEqual:@"aifc"])
		{
			fileTypeHint = kAudioFileAIFCType;
		}
		else if ([fileExtension isEqual:@"aiff"])
		{
			fileTypeHint = kAudioFileAIFFType;
		}
		else if ([fileExtension isEqual:@"m4a"])
		{
			fileTypeHint = kAudioFileM4AType;
		}
		else if ([fileExtension isEqual:@"mp4"])
		{
			fileTypeHint = kAudioFileMPEG4Type;
		}
		else if ([fileExtension isEqual:@"caf"])
		{
			fileTypeHint = kAudioFileCAFType;
		}
		else if ([fileExtension isEqual:@"aac"])
		{
			fileTypeHint = kAudioFileAAC_ADTSType;
		}

		// create an audio file stream parser
		err = AudioFileStreamOpen(self, MyPropertyListenerProc, MyPacketsProc, 
								fileTypeHint, &audioFileStream);
		if (err)
		{
			[self failWithErrorCode:AS_FILE_STREAM_OPEN_FAILED];
			return NO;
		}
		
		//
		// Create the GET request
		//
		CFHTTPMessageRef message= CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"GET", (CFURLRef)url, kCFHTTPVersion1_1);
		stream = CFReadStreamCreateForHTTPRequest(NULL, message);
		CFRelease(message);
		
		//
		// Enable stream redirection
		//
		if (CFReadStreamSetProperty(
			stream,
			kCFStreamPropertyHTTPShouldAutoredirect,
			kCFBooleanTrue) == false)
		{
#ifdef TARGET_OS_IPHONE
			UIAlertView *alert =
				[[UIAlertView alloc]
					initWithTitle:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
					message:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)
					delegate:self
					cancelButtonTitle:@"OK"
					otherButtonTitles: nil];
			[alert
				performSelector:@selector(show)
				onThread:[NSThread mainThread]
				withObject:nil
				waitUntilDone:YES];
			[alert release];
#else
		NSAlert *alert =
			[NSAlert
				alertWithMessageText:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
				defaultButton:NSLocalizedString(@"OK", @"")
				alternateButton:nil
				otherButton:nil
				informativeTextWithFormat:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)];
		[alert
			performSelector:@selector(runModal)
			onThread:[NSThread mainThread]
			withObject:nil
			waitUntilDone:NO];
#endif
			return NO;
		}
		
		//
		// Handle SSL connections
		//
		if( [[url absoluteString] rangeOfString:@"https"].location != NSNotFound )
		{
			NSDictionary *sslSettings =
				[NSDictionary dictionaryWithObjectsAndKeys:
					(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL, kCFStreamSSLLevel,
					[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
					[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredRoots,
					[NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
					[NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
					[NSNull null], kCFStreamSSLPeerName,
				nil];

			CFReadStreamSetProperty(stream, kCFStreamPropertySSLSettings, sslSettings);
		}
		
		//
		// Open the stream
		//
		if (!CFReadStreamOpen(stream))
		{
			CFRelease(stream);
#ifdef TARGET_OS_IPHONE
			UIAlertView *alert =
				[[UIAlertView alloc]
					initWithTitle:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
					message:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)
					delegate:self
					cancelButtonTitle:@"OK"
					otherButtonTitles: nil];
			[alert
				performSelector:@selector(show)
				onThread:[NSThread mainThread]
				withObject:nil
				waitUntilDone:YES];
			[alert release];
#else
		NSAlert *alert =
			[NSAlert
				alertWithMessageText:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
				defaultButton:NSLocalizedString(@"OK", @"")
				alternateButton:nil
				otherButton:nil
				informativeTextWithFormat:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)];
		[alert
			performSelector:@selector(runModal)
			onThread:[NSThread mainThread]
			withObject:nil
			waitUntilDone:NO];
#endif
			return NO;
		}
		
		//
		// Set our callback function to receive the data
		//
		CFStreamClientContext context = {0, self, NULL, NULL, NULL};
		CFReadStreamSetClient(
			stream,
			kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered,
			ASReadStreamCallBack,
			&context);
		CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	}
	
	NSLog(@"openFileStream returns.");
	return YES;
}
//-----------------------------------------//


//-----------------------------------------//
//
// startInternal
//
// This is the start method for the AudioStream thread. This thread is created
// because it will be blocked when there are no audio buffers idle (and ready
// to receive audio data).
//
// Activity in this thread:
//	- Creation and cleanup of all AudioFileStream and AudioQueue objects
//	- Receives data from the CFReadStream
//	- AudioFileStream processing
//	- Copying of data from AudioFileStream into audio buffers
//  - Stopping of the thread because of end-of-file
//	- Stopping due to error or failure
//
// Activity *not* in this thread:
//	- AudioQueue playback and notifications (happens in AudioQueue thread)
//  - Actual download of NSURLConnection data (NSURLConnection's thread)
//	- Creation of the AudioStreamer (other, likely "main" thread)
//	- Invocation of -start method (other, likely "main" thread)
//	- User/manual invocation of -stop (other, likely "main" thread)
//
// This method contains bits of the "main" function from Apple's example in
// AudioFileStreamExample.
//
- (void)startInternal
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	BOOL isRunning;
	NSLog(@"Starting internal.");

	@synchronized(self)
	{
		if (state != AS_STARTING_FILE_THREAD)
		{
			if (state != AS_STOPPING &&
				state != AS_STOPPED)
			{
				NSLog(@"### Not starting audio thread. State code is: %ld", state);
			}
			self.state = AS_INITIALIZED;
			[pool release];
			return; 
		}
		
	#ifdef TARGET_OS_IPHONE			
		// 
		// Set the audio session category so that we continue to play if the
		// iPhone/iPod auto-locks.
		//
		AudioSessionInitialize ( 
			NULL,                          // 'NULL' to use the default (main) run loop
			NULL,                          // 'NULL' to use the default run loop mode
			MyAudioSessionInterruptionListener,  // a reference to your interruption callback
			self                       // data to pass to your interruption listener callback
		);
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty (
			kAudioSessionProperty_AudioCategory,
			sizeof (sessionCategory),
			&sessionCategory
		);			

		AudioSessionSetActive(true);

	#endif
	
		self.state = AS_WAITING_FOR_DATA;
		
		// initialize a mutex and condition so that we can block on buffers in use.
		pthread_mutex_init(&queueBuffersMutex, NULL);
		pthread_cond_init(&queueBufferReadyCondition, NULL);
		
		if (![self openFileStream])
		{ 
			 goto cleanup;
			NSLog(@"Usually this would go to cleanup. Objective-C++ not thrilled with that idea right now.");
		}
	}
	
	//
	// Process the run loop until playback is finished or failed.
	//
	isRunning = YES;
	do
	{
		isRunning = [[NSRunLoop currentRunLoop]
			runMode:NSDefaultRunLoopMode
			beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
		
		//
		// If there are no queued buffers, we need to check here since the
		// handleBufferCompleteForQueue:buffer: should not change the state
		// (may not enter the synchronized section).
		//
		if (buffersUsed == 0 && self.state == AS_PLAYING)
		{
		
			if (err)
			{
				[self failWithErrorCode:AS_FMOD_FAILED];
				return;
			}
			self.state = AS_BUFFERING;
		}
	} while (isRunning && ![self runLoopShouldExit]);
	
cleanup:

	@synchronized(self)
	{
		//
		// Cleanup the read stream if it is still open
		//
		if (stream)
		{
			CFReadStreamClose(stream);
			CFRelease(stream);
			stream = nil;
		}
		
		//
		// Close the audio file strea,
		//
		if (audioFileStream)
		{
			err = AudioFileStreamClose(audioFileStream);
			audioFileStream = nil;
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_CLOSE_FAILED];
			}
		}
		
		//Shut down audio
		//
		if (system)
		{
			
			system->release();
			
			if (err)
			{
				[self failWithErrorCode:AS_FMOD_FAILED];
			}
		}

		pthread_mutex_destroy(&queueBuffersMutex);
		pthread_cond_destroy(&queueBufferReadyCondition);

#ifdef TARGET_OS_IPHONE			
		AudioSessionSetActive(false);
#endif

		bytesFilled = 0;
		packetsFilled = 0;
		seekTime = 0;
		seekNeeded = NO;
		self.state = AS_INITIALIZED;
	}

	[pool release];
}
//-----------------------------------------//


//-----------------------------------------//
//
// Calls startInternal in a new thread.
//
- (void)start
{
	system  = NULL;
	sound   = NULL;
	channel = NULL;
	
	NSLog(@"starting");
	
	
	@synchronized (self)
	{
		if (state == AS_PAUSED)
		{
			NSLog(@"starting1");

			[self pause];
		}
		else if (state == AS_INITIALIZED)
		{
			NSLog(@"starting2");

			NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]],
				@"Playback can only be started from the main thread.");
			notificationCenter =
				[[NSNotificationCenter defaultCenter] retain];
			self.state = AS_STARTING_FILE_THREAD;
			
			[NSThread
				detachNewThreadSelector:@selector(startInternal)
				toTarget:self
				withObject:nil];
		}
	}
}
//-----------------------------------------//


//-----------------------------------------//
// returns the current playback progress. Will return zero if sampleRate has
// not yet been detected.
//
- (double)progress
{
	@synchronized(self)
	{
		if (sampleRate > 0 && ![self isFinishing])
		{
			if (state != AS_PLAYING && state != AS_PAUSED && state != AS_BUFFERING)
			{
				return lastProgress;
			}

			AudioTimeStamp queueTime;
			bool discontinuity;
			//Get time from FDOD? For timer?
			if (err)
			{
				[self failWithErrorCode:AS_GET_AUDIO_TIME_FAILED];
			}

			double progress = seekTime + queueTime.mSampleTime / sampleRate;
			if (progress < 0.0)
			{
				progress = 0.0;
			}
			
			lastProgress = progress;
			return progress;
		}
	}
	
	return lastProgress;
}
//-----------------------------------------//


//-----------------------------------------//
// A togglable pause function.
//
- (void)pause
{
	
		if (state == AS_PLAYING || paused == false)
		
		{
			
			result = channel->getPaused(&paused);
			ERRCHECK(result);
			
			result = channel->setPaused(!paused);
			ERRCHECK(result);
			NSLog(@"system paused");
			
			self.state = AS_PAUSED;
		}
		else if (state == AS_PAUSED || paused == true)
		{
			NSLog(@"play again");
						
			result = channel->getPaused(&paused);
			ERRCHECK(result);
			
			result = channel->setPaused(!paused);
			ERRCHECK(result);
			
			self.state = AS_PLAYING;
		}
}
//-----------------------------------------//



//-----------------------------------------//
// Applies the logic to verify if seeking should occur.
//
// returns YES (seeking should occur) or NO (otherwise).
//
- (BOOL)shouldSeek
{
	@synchronized(self)
	{
		if (bitRate != 0 && bitRate != ~0 && seekNeeded &&
			(state == AS_PLAYING || state == AS_PAUSED || state == AS_BUFFERING))
		{
			return YES;
		}
	}
	return NO;
}
//-----------------------------------------//


//-----------------------------------------//
// This method can be called to stop downloading/playback before it completes.
// It is automatically called when an error occurs.
//
// If playback has not started before this method is called, it will toggle the
// "isPlaying" property so that it is guaranteed to transition to true and
// back to false 
//
- (void)stop
{
	@synchronized(self)
	{
		if (1 &&
			(state == AS_PLAYING || state == AS_PAUSED ||
				state == AS_BUFFERING || state == AS_WAITING_FOR_QUEUE_TO_START))
		{
			self.state = AS_STOPPING;
			stopReason = AS_STOPPING_USER_ACTION;
						
			result = channel->getPaused(&paused);
			ERRCHECK(result);
			
			result = channel->setPaused(!paused);
			ERRCHECK(result);
	
		}
		else if (state != AS_INITIALIZED)
		{
			self.state = AS_STOPPED;
			stopReason = AS_STOPPING_USER_ACTION;
		}
	}
	
	while (state != AS_INITIALIZED)
	{
		[NSThread sleepForTimeInterval:0.1];
	}
}
//-----------------------------------------//


//-----------------------------------------//
// Reads data from the network file stream into the AudioFileStream
//
// Parameters:
//    aStream - the network file stream
//    eventType - the event which triggered this method
//
- (void)handleReadFromStream:(CFReadStreamRef)aStream
	eventType:(CFStreamEventType)eventType
{
	if (eventType == kCFStreamEventErrorOccurred)
	{
		[self failWithErrorCode:AS_AUDIO_DATA_NOT_FOUND];
	}
	else if (eventType == kCFStreamEventEndEncountered)
	{
		@synchronized(self)
		{
			if ([self isFinishing])
			{
				return;
			}
		}
		
		//
		// If there is a partially filled buffer, pass it to FMOD for
		// processing
		//
		if (bytesFilled)
		{
			[self enqueueBuffer];
		}

		@synchronized(self)
		{
			if (state == AS_WAITING_FOR_DATA)
			{
				[self failWithErrorCode:AS_AUDIO_DATA_NOT_FOUND];
			}
			
			//
			// We left the synchronized section to enqueue the buffer so we
			// must check that we are !finished again before touching the
			// audioQueue
			//
			else if (![self isFinishing])
			{
				if (system)
				{
					//
					// Set the progress at the end of the stream
					//
					[self stop];
					if (sound !=NULL)
					{
						[self failWithErrorCode:AS_FMOD_FAILED];
						return;
					}

					self.state = AS_STOPPING;
					stopReason = AS_STOPPING_EOF;
					
					if (channel != NULL)
					{
						channel->stop();
						
					}
					
					if (sound != NULL)
					{
						sound->release();
					
					}
					if (err)
					{
						[self failWithErrorCode:AS_FMOD_FAILED];
						return;
					}
				}
				else
				{
					self.state = AS_STOPPED;
					stopReason = AS_STOPPING_EOF;
				}
			}
		}
	}
	else if (eventType == kCFStreamEventHasBytesAvailable)
	{
		UInt8 bytes[kFMODBufSize];
		CFIndex length;
		@synchronized(self)
		{
			if ([self isFinishing])
			{
				return;
			}
			
			//
			// Read the bytes from the stream
			//
			length = CFReadStreamRead(stream, bytes, kFMODBufSize);
			
			if (length == -1)
			{
				[self failWithErrorCode:AS_AUDIO_DATA_NOT_FOUND];
				return;
			}
			
			if (length == 0)
			{
				return;
			}
		}

		if (discontinuous)
		{
			err = AudioFileStreamParseBytes(audioFileStream, length, bytes, kAudioFileStreamParseFlag_Discontinuity);
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_PARSE_BYTES_FAILED];
				return;
			}
		}
		else
		{
			err = AudioFileStreamParseBytes(audioFileStream, length, bytes, 0);
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_PARSE_BYTES_FAILED];
				return;
			}
		}
	}
}
//-----------------------------------------//


//-----------------------------------------//
// Called from MyPacketsProc and connectionDidFinishLoading to pass filled audio
// bufffers (filled by MyPacketsProc) to FMOD for playback. This
// function does not return until a buffer is idle for further filling or
// FMOD is stopped.
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
- (void)enqueueBuffer
{
	@synchronized(self)
	{
		if ([self isFinishing])
		{
			return;
		}
		
		inuse[fillBufferIndex] = true;		// set in use flag
		buffersUsed++;
		
		result = FMOD_OK;

		result = system->createSound(buffer, FMOD_SOFTWARE | FMOD_2D | FMOD_CREATESTREAM | FMOD_NONBLOCKING, NULL, &sound);
		ERRCHECK(result);
		NSLog(@"Buffer queued from enqueueBuffer. Duh.");
		
		// go to next buffer
		if (++fillBufferIndex >= kNumFMODBufs) fillBufferIndex = 0;
		bytesFilled = 0;		// reset bytes filled
		packetsFilled = 0;		// reset packets filled
	}

	// wait until next buffer is not in use
	pthread_mutex_lock(&queueBuffersMutex); 
	while (inuse[fillBufferIndex])
	{
		pthread_cond_wait(&queueBufferReadyCondition, &queueBuffersMutex);
	}
	pthread_mutex_unlock(&queueBuffersMutex);
}

//
// handlePropertyChangeForFileStream:fileStreamPropertyID:ioFlags:
//
// Object method which handles implementation of MyPropertyListenerProc
//
// Parameters:
//    inAudioFileStream - should be the same as self->audioFileStream
//    inPropertyID - the property that changed
//    ioFlags - the ioFlags passed in
//
- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream
	fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID
	ioFlags:(UInt32 *)ioFlags
{
	@synchronized(self)
	{
		if ([self isFinishing])
		{
			return;
		}
		
		if (inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets)
		{
			discontinuous = true;
			
			AudioStreamBasicDescription asbd;
			UInt32 asbdSize = sizeof(asbd);
			
			// get the stream format.
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_GET_PROPERTY_FAILED];
				return;
			}
			
			sampleRate = asbd.mSampleRate;
			
			// create the FMOD system or channel
			//err = FMOD do stuff 
			if (err)
			{
				[self failWithErrorCode:AS_FMOD_FAILED];
				return;
			}
			
			// start the queue if it has not been started already
			// listen to the "isRunning" property
			
			//Check to see if fMOD is running
			
			if (err)
			{
				[self failWithErrorCode:AS_FMOD_FAILED];
				return;
			}
			
			// allocate audio queue buffers
			for (unsigned int i = 0; i < kNumFMODBufs; ++i)
			{
			// Allocate fMOD buffer
				if (err)
				{
					[self failWithErrorCode:AS_FMOD_FAILED];
					return;
				}
			}

			// get the cookie size
			UInt32 cookieSize;
			Boolean writable;
			OSStatus ignorableError;
			ignorableError = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
			if (ignorableError)
			{
				return;
			}

			// get the cookie data
			void* cookieData = calloc(1, cookieSize);
			ignorableError = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
			if (ignorableError)
			{
				return;
			}

			// set the cookie on the queue.
			//Set cookie property, if applicable
			free(cookieData);
			if (ignorableError)
			{
				return;
			}
		}
		else if (inPropertyID == kAudioFileStreamProperty_DataOffset)
		{
			SInt64 offset;
			UInt32 offsetSize = sizeof(offset);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataOffset, &offsetSize, &offset);
			dataOffset = offset;
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_GET_PROPERTY_FAILED];
				return;
			}
		}
	}
}
//-----------------------------------------//


//-----------------------------------------//
// handleAudioPackets:numberBytes:numberPackets:packetDescriptions:
//
// Object method which handles the implementation of MyPacketsProc
//
// Parameters:
//    inInputData - the packet data
//    inNumberBytes - byte size of the data
//    inNumberPackets - number of packets in the data
//    inPacketDescriptions - packet descriptions
//
- (void)handleAudioPackets:(const void *)inInputData
	numberBytes:(UInt32)inNumberBytes
	numberPackets:(UInt32)inNumberPackets
	packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;
{
	@synchronized(self)
	{
		if ([self isFinishing])
		{
			return;
		}
		
		if (bitRate == 0)
		{
			UInt32 dataRateDataSize = sizeof(UInt32);
			err = AudioFileStreamGetProperty(
				audioFileStream,
				kAudioFileStreamProperty_BitRate,
				&dataRateDataSize,
				&bitRate);
			if (err)
			{
				//
				// m4a and a few other formats refuse to parse the bitrate so
				// we need to set an "unparseable" condition here. If you know
				// the bitrate (parsed it another way) you can set it on the
				// class if needed.
				//
				bitRate = ~0;
				//bitRate = 128000;
			}
		}
		
		// we have successfully read the first packests from the audio stream, so
		// clear the "discontinuous" flag
		discontinuous = false;
	}

	// the following code assumes we're streaming VBR data. for CBR data, the second branch is used.
	if (inPacketDescriptions)
	{
		for (int i = 0; i < inNumberPackets; ++i)
		{
			SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
			SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
			size_t bufSpaceRemaining;
			
			@synchronized(self)
			{
				// If the audio was terminated before this point, then
				// exit.
				if ([self isFinishing])
				{
					return;
				}
				
				//
				// If we need to seek then unroll the stack back to the
				// appropriate point
				//
				if ([self shouldSeek])
				{
					return;
				}
				
				if (packetSize > kFMODBufSize)
				{
					[self failWithErrorCode:AS_AUDIO_BUFFER_TOO_SMALL];
				}

				bufSpaceRemaining = kFMODBufSize - bytesFilled;
			}

			// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
			if (bufSpaceRemaining < packetSize)
			{
				[self enqueueBuffer];
			}
			
			@synchronized(self)
			{
				// If the audio was terminated while waiting for a buffer, then
				// exit.
				if ([self isFinishing])
				{
					return;
				}
				
				//
				// If we need to seek then unroll the stack back to the
				// appropriate point
				//
				if ([self shouldSeek])
				{
					return;
				}
				 
				// copy data to the audio queue buffer
				//AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];

			
				//Copy to FMOD buffer, from data passed in callback
				
			
				memcpy((char*)buffer + bytesFilled, (const char*)inInputData + packetOffset, packetSize);
				NSLog(@"Yep, memcpy.");
				
				result = system->createSound(buffer, FMOD_SOFTWARE | FMOD_2D | FMOD_LOOP_NORMAL, NULL, &sound);
				ERRCHECK(result);
				NSLog(@"FMOD sound created in handleAudioPackets.");
				
				result = system->playSound(FMOD_CHANNEL_FREE, sound, true, &channel);
				ERRCHECK(result);
				}
				
				// fill out packet description
				packetDescs[packetsFilled] = inPacketDescriptions[i];
				packetDescs[packetsFilled].mStartOffset = bytesFilled;
				// keep track of bytes filled and packets filled
				bytesFilled += packetSize;
				packetsFilled += 1;
			
			
			// if that was the last free packet description, then enqueue the buffer.
			size_t packetsDescsRemaining = kFMODMaxPacketDescs - packetsFilled;
			if (packetsDescsRemaining == 0) {
				[self enqueueBuffer];
			}
		}	
	}
	else
	{
		size_t offset = 0;
		while (inNumberBytes)
		{
			// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
			size_t bufSpaceRemaining = kFMODBufSize - bytesFilled;
			if (bufSpaceRemaining < inNumberBytes)
			{
				[self enqueueBuffer];
			}
			
			@synchronized(self)
			{
				// If the audio was terminated while waiting for a buffer, then
				// exit.
				if ([self isFinishing])
				{
					return;
				}
				
				//
				// If we need to seek then unroll the stack back to the
				// appropriate point
				//
				if ([self shouldSeek])
				{
					return;
				}
				
				// copy data to the audio queue buffer
				//AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
				
				//Copy data to FMOD buffer
				
				bufSpaceRemaining = kFMODBufSize - bytesFilled;
				size_t copySize;
				if (bufSpaceRemaining < inNumberBytes)
				{
					copySize = bufSpaceRemaining;
				}
				else
				{
					copySize = inNumberBytes;
				}
				//memcpy((char*)buffer + bytesFilled, (const char*)(inInputData + offset), copySize);
				
				result = system->createSound(buffer, FMOD_SOFTWARE | FMOD_2D | FMOD_LOOP_NORMAL, NULL, &sound);
				ERRCHECK(result);
				
				result = system->playSound(FMOD_CHANNEL_FREE, sound, true, &channel);
				ERRCHECK(result);

				// keep track of bytes filled and packets filled
				bytesFilled += copySize;
				packetsFilled = 0;
				inNumberBytes -= copySize;
				offset += copySize;
			}
		}
	}
}
//-----------------------------------------//


//-----------------------------------------//
#ifdef TARGET_OS_IPHONE
//
// handleInterruptionChangeForQueue:propertyID:
//
// Implementation for MyAudioQueueInterruptionListener
//
// Parameters:
//    inAQ - the audio queue
//    inID - the property ID
//
- (void)handleInterruptionChangeToState:(AudioQueuePropertyID)inInterruptionState
{
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		[self pause];
	}
	else if (inInterruptionState == kAudioSessionEndInterruption)
	{
		[self start];
	}
}
#endif
//-----------------------------------------//

@end


