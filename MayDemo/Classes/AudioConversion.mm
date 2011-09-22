//
//  AudioConverter.m
//  AprilDemo 
//
//  Created by Russell de Moose on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioConversion.h"
 

#pragma mark callbacks 

void myASReadStreamCallBack  (CFReadStreamRef aStream,
							CFStreamEventType eventType,
							void* inClientInfo);

OSStatus audioConverterCallback (AudioConverterRef converter, 
								 UInt32 *ioNumberDataPackets, 
								 AudioBufferList *ioData,
								 AudioStreamPacketDescription *outDataPacketDescription, 
								 void *inUserData) ;


 

void PropertyListenerProc (	void *							inClientData, //whatever you want back 
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags);

void PacketsProc(				void *							inClientData, //whatever you want back
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions);

void myInterruptionListenerCallback (void *inUserData,  
								   UInt32 interruptionState);




void myASReadStreamCallBack  (CFReadStreamRef aStream, CFStreamEventType eventType, void* inClientInfo)
{
	AudioConversion* convert = (AudioConversion *)inClientInfo;
	[convert handleReadFromStream:aStream eventType:eventType];
}



OSStatus audioConverterCallback (AudioConverterRef converter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData,
											 AudioStreamPacketDescription *outDataPacketDescription, void *inUserData) 

{
	
	AudioConversion* convert = (AudioConversion *)inUserData;
	[convert
	 provideAudio:converter 
	 inputData:ioData
	// numberPackets:ioNumberDataPackets
	 ]; //the audio converter calls an instance method, which has access to instance variables, etc...)	
	
	/*
	
	MyAudioConverterSettings *audioConverterSettings = (MyAudioConverterSettings) * inUserData;

	UInt32 ioPackets = 2048 / audioConverterSettings.bytesPerPacket;
	NSLog(@"packet size is %i", ioPackets);
	
	ioNumberDataPackets = &ioPackets;
	
	*ioData = sourceBuffer;
		
	// use a static instance of ASPD for callback input
	AudioStreamPacketDescription aspdesc;
   	outDataPacketDescription = &aspdesc;
   	aspdesc.mDataByteSize = &audioConverterSettings.bytesPerPacket;
   	//aspdesc.mStartOffset = &AudioConversion.offset;
	aspdesc.mStartOffset = 0;
   	aspdesc.mVariableFramesInPacket = 1;

	*/ 
	 
	return noErr;	 

}





// Audio File Stream Callback Functions 

void PropertyListenerProc (	void *							inClientData,
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags)
{
	
	// this is called by audio file stream when it finds property values
	AudioConversion* convert = (AudioConversion *)inClientData;
	[convert 
	 streamProperties:inAudioFileStream
	 fileStreamPropertyID:inPropertyID
	 ioFlags:ioFlags]; 	
	
}



void PacketsProc(				void *							inClientData,
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions)

{
	// this is called by audio file stream when it finds packets of audio
	// Here I am making the callback defer to this instance method. 

	
	
	
	AudioConversion* convert = (AudioConversion *)inClientData;
	[convert
	 audioToConverter:inInputData
	 numberBytes:inNumberBytes
	 numberPackets:inNumberPackets
	 packetDescriptions:inPacketDescriptions]; //the streamer handles packets from the specified input. 	
}



void myInterruptionListenerCallback (void *inUserData, UInt32 interruptionState) {
	
	// This callback, being outside the implementation block, needs a reference 
	//to the AudioPlayer object
	AudioConversion *convert = (AudioConversion *)inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) {
		NSLog(@"kAudioSessionBeginInterruption");
		[convert dealloc];
	}

	else if (interruptionState == kAudioSessionEndInterruption) {
		NSLog(@"kAudioSessionEndInterruption");
		AudioSessionSetActive( true );

	}
}



// ---------END OF CALLBACKS------------------//

@implementation AudioConversion


@synthesize state, bitRate;


- (void)start
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];


	NSLog(@"starting");
	
	
	@synchronized (self)
	{
		if (state == AS_PAUSED)
		{
			NSLog(@"starting; was paused");
			return;
			
		}
		else if (state == AS_INITIALIZED)
		{
			NSLog(@"starting; was initialized");
			
			NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]],
					 @"Playback can only be started from the main thread.");
			self.state = AS_STARTING_FILE_THREAD;
			[NSThread
			 detachNewThreadSelector:@selector(startInternal)
			 toTarget:self
			 withObject:nil];
		}
	}
}


- (void)startInternal
{
	NSLog(@"StartInternal called");
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
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
								myInterruptionListenerCallback,  // a reference to your interruption callback
								self                       // data to pass to your interruption listener callback
								);
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty (
								 kAudioSessionProperty_AudioCategory,
								 sizeof (sessionCategory),
								 &sessionCategory
								 );			
		

		AudioSessionSetActive(true);
		NSLog(@"AudioSession is active");
		
#endif
		
		self.state = AS_WAITING_FOR_DATA;
		
		// initialize a mutex and condition so that we can block on buffers in use.
		pthread_mutex_init(&queueBuffersMutex, NULL);
		pthread_cond_init(&queueBufferReadyCondition, NULL);
		
		if (![self openFileStream])
		{
			goto cleanup;
		}
	}
	
	//
	// Process the run loop until playback is finished or failed.
	//

	
	/*
	
	BOOL isRunning = YES;
	do
	{
		isRunning = [[NSRunLoop currentRunLoop]
					 runMode:NSDefaultRunLoopMode
					 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
		
	} while (isRunning && ![self runLoopShouldExit]);
	 
	 */
		
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
				NSLog(@"Failed to close");
			}
		}
		
		pthread_mutex_destroy(&queueBuffersMutex);
		pthread_cond_destroy(&queueBufferReadyCondition);
		
#ifdef TARGET_OS_IPHONE			
		AudioSessionSetActive(false);
#endif
		
		bytesFilled = 0;
		packetsFilled = 0;
		self.state = AS_INITIALIZED;
	}
	
	[pool release];
	
}


- (id)initWithURL:(NSURL *)someURL
{
	self = [super init];
	if (self != nil)
	{
		url = [someURL retain];
	}
		
	AudioSessionInitialize( NULL, NULL, myInterruptionListenerCallback, self );
	AudioSessionSetActive( true );
		return self;
}


//
// openFileStream
//
// Open the audioFileStream to parse data and the fileHandle as the data
// source.
//
- (BOOL)openFileStream
{
	NSLog(@"openFileStream called");
	
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
		else if ([fileExtension isEqual:@"m4a"])
		{
			fileTypeHint = kAudioFileM4AType;
		}
		else if ([fileExtension isEqual:@"mp4"])
		{
			fileTypeHint = kAudioFileMPEG4Type;
		}
		else if ([fileExtension isEqual:@"aac"])
		{
			fileTypeHint = kAudioFileAAC_ADTSType;
		}
		
		// create an audio file stream parser
		err = AudioFileStreamOpen(self, PropertyListenerProc, PacketsProc, 
								  fileTypeHint, &audioFileStream);
		if (err)
		{
			NSLog (@"File stream parser did not open properly");
			return NO;
		}
		
		if (!err)
		{
			NSLog(@"Parser created");
		}
		
		//
		// Create the GET request
		//
		CFHTTPMessageRef message= CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"GET", (CFURLRef)url, kCFHTTPVersion1_1);
		stream = CFReadStreamCreateForHTTPRequest(NULL, message);
			if (stream)
			{
				NSLog(@"Stream created with HTTP request");
			}
				
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
#endif
			return NO;
		}
		
		//
		// Set our callback function to receive the data
		//
		//This invokes the callback whenever these three properties have a value. 
		
		CFStreamClientContext context = {0, self, NULL, NULL, NULL};
		CFReadStreamSetClient(
							  stream,
							  kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered,
							  myASReadStreamCallBack,
							  &context);
		CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
				NSLog(@"Run loop scheduled");
	}
	
	return YES;
}


- (void) startConversion

{
	NSLog(@"startConversion called.");
	
	AudioConverterRef converter;	
	//AudioBufferList inAudioBuffers; 
	AudioBufferList convertedData;
	//AudioFileStreamID audioFileStream;
	//MyAudioConverterSettings audioConverterSettings;
	
	
	
	audioConverterSettings.inASBD.mSampleRate = 44100.0;
	audioConverterSettings.inASBD.mFormatID = kAudioFormatMPEGLayer3;
	audioConverterSettings.inASBD.mFormatFlags = 0;
	audioConverterSettings.inASBD.mBytesPerPacket = bytesPerPacket;
	audioConverterSettings.inASBD.mFramesPerPacket = 1; 
	audioConverterSettings.inASBD.mBytesPerFrame = 0;
	audioConverterSettings.inASBD.mChannelsPerFrame = 1;
	audioConverterSettings.inASBD.mBitsPerChannel = 0;
	audioConverterSettings.inASBD.mReserved = 0;
	
	audioConverterSettings.outASBD.mSampleRate = 44100.0;
	audioConverterSettings.outASBD.mFormatID = kAudioFormatLinearPCM;
	audioConverterSettings.outASBD.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger |kAudioFormatFlagIsPacked;
	audioConverterSettings.outASBD.mBytesPerPacket = 4;
	audioConverterSettings.outASBD.mFramesPerPacket = 1; 
	audioConverterSettings.outASBD.mBytesPerFrame = 4;
	audioConverterSettings.outASBD.mChannelsPerFrame = 1;
	audioConverterSettings.outASBD.mBitsPerChannel = 16;
	audioConverterSettings.outASBD.mReserved = 0;

		
		
		// Get a new Audio Converter and begin to get properties for it. 
		
		err =  AudioConverterNew(&audioConverterSettings.inASBD, &audioConverterSettings.outASBD, &converter);
		
		if (err) 
		{
			NSLog (@"WTF");
			NSLog (@"%i", err); 
		}
		
		UInt32  complexity = kAudioConverterSampleRateConverterComplexity_Linear;
		err = AudioConverterSetProperty(converter, kAudioConverterSampleRateConverterComplexity, sizeof (complexity), &complexity);	
		//This chooses the Fs complexity property of object converter, sets it to the size 
		//of the variable, and makes it the value of the value pointed to (complexity, here).	
		
		
		
		//----------------- Figure out buffer sizes in packets and determine how to fill.-------------//
		// This section lifted directly from core audio book.
		
		packetsPerBuffer = 0; 
		outputBufferSize = 32 * 2048; // 32 KB is a good starting point. I'm using 64 KB.  
	
		//------Added on May 11 for test---------//
	
	if (bytesPerPacket == 0) {
		bytesPerPacket = 1254;
	}
		packetsPerBuffer = outputBufferSize / bytesPerPacket;
		
		outputBuffer = (UInt32 *) malloc(sizeof(UInt32 *) * outputBufferSize); 
		
		//UInt32 outputFilePacketPosition = 0; 
		
		while(1) 
		{ 
			//convertedData represents the buffer list of data out of the converter, and into OpenAL. Will have to see how this actually works. 
			
			int i = 0;
			
			convertedData.mNumberBuffers;  //Only one buffer in BufferList receiving converted data. May have to change.
			convertedData.mBuffers[i].mNumberChannels = audioConverterSettings.inASBD.mChannelsPerFrame; //Number of channels of that buffer [0], the first and only buffer.
			convertedData.mBuffers[i].mDataByteSize = outputBufferSize;  // Its size; 
			convertedData.mBuffers[i].mData = outputBuffer; // The data itself. 
			
			UInt32 ioOutputDataPackets = packetsPerBuffer; 
		//	OSStatus error = AudioConverterFillComplexBuffer(converter, audioConverterCallback, self, &ioOutputDataPackets, &convertedData, NULL);
			
			if (1)
			
			//if (error || !ioOutputDataPackets) 
			{
				break;	// This is the termination condition
				NSLog(@"Conversion error from Fill Complex Buffer");
			}
			
			i++;
		}
			
			// AudioConverterFillComplexBuffer takes the following parameters:
			// 1. A previously-created AudioConverterRef	
			// 2. A callback function, conforming to AudioConverterComplexInputDataProc, which provides the input data for conversion
			// 3. A user data pointer - the data you want back to do stuff in callback function.
			// 4. The maximum size of the output buffer, as a packet count
			// 5. A pointer to an output buffer, where the converted data is received. Is an Audio Buffer List. 
			// 6. A pointer an array of packet descriptions, if needed for the output buffer (i.e., if converting to a variable-bi- trate format)	
			// for CBR (since I am going to .caf LPCM and the mp3 stream is CBR. 
			
	
		
		AudioConverterDispose (converter);
	}
	
	// --------------End of Core Audio Book Sample. ------------------//		
	


			
// ---------Methods called from property and audio data callback functions. -------------//
	/* -----Callbacks themselves are basically wrappers for Objective-C methods. 
			Programming methodology taken from Matt Gallagher streaming example----- */
 		
		//
		// Object method which handles implementation of MyPropertyListenerProc
		//
		// Parameters:
		//    inAudioFileStream - should be the same as self.audioFileStream
		//    inPropertyID - the property that changed
		//    ioFlags - the ioFlags passed in
		
- (void)streamProperties:(AudioFileStreamID)inAudioFileStream
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
					AudioStreamBasicDescription sizeMe;
		
					// get the stream format and other File Stream Properties, to be passed to callback function. 
					UInt32 inASBDSize = sizeof (sizeMe);
					err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &inASBDSize, &audioConverterSettings.inASBD);
					if (err)
					{
						NSLog(@"Cannot get stream data format.");
						return;
					}					
				}			
				
				else if (inPropertyID == kAudioFileStreamProperty_DataOffset)
				{
					
					UInt32 offsetSize = sizeof(offset);
					err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataOffset, &offsetSize, &offset);
					if (err)
					{
						NSLog(@"could not get data offset.");
						return;
					}
				}
				
				else if (inPropertyID == kAudioFileStreamProperty_AverageBytesPerPacket)
						 {
							UInt32 bPP = sizeof (bytesPerPacket);
							 err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_AverageBytesPerPacket,&bPP, &bytesPerPacket);
							 if (err)
							 {
								 NSLog(@"Cannot get average packet size.");
								 return;
							 }
							 
						 }
				
				else if (inPropertyID == kAudioFileStreamProperty_MaximumPacketSize)
				{
						 
						 UInt32 size = sizeof(maxPacketSize);
						 err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MaximumPacketSize, &size, &maxPacketSize);
						 if (err)
						 {
							 NSLog(@"Cannot get average packet size.");
							 return;
						 }
				}
			}
		}
		
		
		//audioToConverter method.
		//
		// Object method which handles the implementation of MyPacketsProc
		//
		// Parameters:
		//    inInputData - the packet data
		//    inNumberBytes - byte size of the data
		//    inNumberPackets - number of packets in the data
		//    inPacketDescriptions - packet descriptions
		//
- (void)audioToConverter:(const void *)inInputData
	numberBytes:(UInt32)inNumberBytes
	numberPackets:(UInt32)inNumberPackets
	packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions
		{
			
			
			@synchronized(self)
			{
				if ([self isFinishing])
				{
					return;
				}
				
				if (bitRate == 0)
				{
					NSLog(@"Bitrate currently 0.");
					
					UInt32 dataRateDataSize = sizeof(UInt32);
					err = AudioFileStreamGetProperty(audioFileStream, kAudioFileStreamProperty_BitRate, &dataRateDataSize, &bitRate);
					
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
				NSLog(@"There are packet descriptions. This means we have VBR data.");
				
				@synchronized(self)
				{
				
				for (int i = 0; i < inNumberPackets; ++i)
				{
					//SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
					//SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
					//size_t bufSpaceRemaining;
					
					//-----------Pulled from CBR else, but on 5/17, stream appears to have VBR data. -------//
					
					
					int i = 0;
					
					bytesPerBuffer = inNumberBytes;
					
					sourceBuffer.mBuffers[i].mData = (void *) calloc(1, inNumberBytes);
					NSLog(@"Buffer created");
					
					
					memcpy (sourceBuffer.mBuffers[i].mData, (const void*)(inInputData), bytesPerBuffer);
					//memcpy (sourceBuffer, (const char*)(inInputData), bytesPerBuffer);
					
					// copies bytesPerBuffer's worth of data to sourceBuffer from inInputData 
					
					i++;
					
					//-------HEY THIS WILL BE IMPORTANT-------//
					/*
					self.state = AS_STARTING_FILE_THREAD;
					[NSThread
					 detachNewThreadSelector:@selector(startConversion)
					 toTarget:self
					 withObject:nil];
					 */

				}
					
					/*
					
					
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
						
						if (packetSize > kAQBufSize)
						{
							return;
						}
						
						bufSpaceRemaining = kAQBufSize - bytesFilled;
					}
					
					// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
					//if (bufSpaceRemaining < packetSize)
					//{
						[self enqueueBuffer];
					//}
					
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
						AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
						memcpy((char*)fillBuf->mAudioData + bytesFilled, (const char*)inInputData + packetOffset, packetSize);
						
					
						
						// fill out packet description
						packetDescs[packetsFilled] = inPacketDescriptions[i];
						packetDescs[packetsFilled].mStartOffset = bytesFilled;
						// keep track of bytes filled and packets filled
						bytesFilled += packetSize;
						packetsFilled += 1;
					}
					
					// if that was the last free packet description, then enqueue the buffer.
					size_t packetsDescsRemaining = kAQMaxPacketDescs - packetsFilled;
					if (packetsDescsRemaining == 0) {
						[self enqueueBuffer];
					}
						 
						 */
						 
				}
						
			}
						 
						 
			else
				
			{
				//If CBR data, then create source buffer, and copy data from stream parser callback to converter buffer.
				
				int i = 0;
				
				bytesPerBuffer = inNumberBytes;
				
				sourceBuffer.mBuffers[i].mData = (void *) calloc(1, inNumberBytes);
				UInt32 bufferSize = sizeof(sourceBuffer);
				NSLog(@"Buffer created at size %i", bufferSize);
			
		
				memcpy (sourceBuffer.mBuffers[i].mData, (const void*)(inInputData), bytesPerBuffer);
				//memcpy (sourceBuffer, (const char*)(inInputData), bytesPerBuffer);
				
				// copies bytesPerBuffer's worth of data to sourceBuffer from inInputData 
					
				i++;
				
				self.state = AS_STARTING_FILE_THREAD;
				[NSThread
				 detachNewThreadSelector:@selector(startConversion)
				 toTarget:self
				 withObject:nil];
			
					
				}
				
				
				/*
				
				size_t packetOffset = 0;
				while (inNumberBytes)
				{
					// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
					size_t bufSpaceRemaining = kAQBufSize - bytesFilled;
					if (bufSpaceRemaining < inNumberBytes)
					{
						[self enqueueBuffer];
						//
					
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
						AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
						bufSpaceRemaining = kAQBufSize - bytesFilled;
						size_t copySize;
						if (bufSpaceRemaining < inNumberBytes)
						{
							copySize = bufSpaceRemaining;
						}
						else
						{
							copySize = inNumberBytes;
						}
						memcpy((char*)fillBuf->mAudioData + bytesFilled, (const char*)(inInputData + offset), copySize);
						
						
						// keep track of bytes filled and packets filled
						bytesFilled += copySize;
						packetsFilled = 0;
						inNumberBytes -= copySize;
						offset += copySize;
					}
				}
				 
				 */
			}


// handleReadFromStream:eventType:data:
//
// Reads data from the network file stream into the AudioFileStream
//
// Parameters:
//    aStream - the network file stream
//    eventType - the event which triggered this method
//
- (void)handleReadFromStream:(CFReadStreamRef)aStream
				   eventType:(CFStreamEventType)eventType
{
	NSLog(@"handleReadFromStream called by callback.");
	
	if (eventType == kCFStreamEventErrorOccurred)
	{
		NSLog(@"No audio data");
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
		
		@synchronized(self)
		
		{
			if (state == AS_WAITING_FOR_DATA)
			{
				
			}
			
			//
			// We left the synchronized section to enqueue the buffer so we
			// must check that we are !finished again before touching the
			// audioQueue
			//
			else if (![self isFinishing])
			{
				
			}
				else
				{
					state = AS_STOPPED;
					
				}
			}
		}
	
	else if (eventType == kCFStreamEventHasBytesAvailable)
	{
		NSLog(@"Bytes available");
		

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
			length = CFReadStreamRead(stream, bytes, kBufSize); // Reads data from stream into buffer of specified size. 
			
			NSLog(@"Reading from network stream");
			
			if (length == -1)
			{
				NSLog(@"CFReadStream problem");
				return;
			}
			
			if (length == 0)
			{
				NSLog(@"Read stream success.");
				return;
			}
		}
		
		if (discontinuous)
		{
			err = AudioFileStreamParseBytes(audioFileStream, length, bytes, kAudioFileStreamParseFlag_Discontinuity);
			if (err)
			{
				NSLog(@"DOH! Parse error.");
				return;
			}
		}
		else
		{
			
			err = AudioFileStreamParseBytes(audioFileStream, length, bytes, 0);
			NSLog(@"Audio file stream parser active.");
			if (err)
			{
				NSLog(@"DOH! Parse error.");
				return;
			}
		}
	}
}


- (void) provideAudio:(AudioConverterRef) converter 
				inputData:(AudioBufferList)ioData
				numberPackets:(UInt32)ioNumberDataPackets


{
	NSLog(@"Provide audio method called");
	
	UInt32 ioPackets = 2048 / bytesPerPacket;
	NSLog(@"packet size is %i", ioPackets);
	
	ioNumberDataPackets = ioPackets;
	
	int i = 0;
	
	ioData.mBuffers[i].mData = sourceBuffer.mBuffers[i].mData;
	
	i++;
	
	// use a static instance of ASPD for callback input
	AudioStreamPacketDescription aspdesc;
   //	outDataPacketDescription = &aspdesc;
   	aspdesc.mDataByteSize = bytesPerPacket;
   	//aspdesc.mStartOffset = &AudioConversion.offset;
	aspdesc.mStartOffset = 0;
   	aspdesc.mVariableFramesInPacket = 1;
	
}
	

//-----------------------Audio Streamer bool and state methods---------------------------//

//
// isFinishing
//
// returns YES if the audio has reached a stopping condition.
//
- (BOOL)isFinishing
{
	
	return NO;
}

//
// runLoopShouldExit
//
// returns YES if the run loop should exit.
//
- (BOOL)runLoopShouldExit
{
	@synchronized(self)	{}
	return NO;
}



//
// isPlaying
//
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

//
// isPaused
//
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

//
// isWaiting
//
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

//
// isIdle
//
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



- (void) dealloc 
{
	[url release];
	[super dealloc];

}



@end
