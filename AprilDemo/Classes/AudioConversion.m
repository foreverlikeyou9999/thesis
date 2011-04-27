//
//  AudioConverter.m
//  AprilDemo
//
//  Created by Russell de Moose on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioConversion.h"


#pragma mark callbacks 

void ASReadStreamCallBack  (CFReadStreamRef aStream,
							CFStreamEventType eventType,
							void* inClientInfo);

OSStatus audioConverterCallback (AudioConverterRef converter, 
								 UInt32 *ioNumberDataPackets, 
								 AudioBufferList *ioData,
								 AudioStreamPacketDescription *outDataPacketDescription, 
								 void *inUserData) ;


 

void MyPropertyListenerProc (	void *							inClientData, //whatever you want back 
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags);

void MyPacketsProc(				void *							inClientData, //whatever you want back
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions);


void ASReadStreamCallBack  (CFReadStreamRef aStream,
							CFStreamEventType eventType,
							void* inClientInfo)
{
	AudioConversion* converter = (AudioConversion *)inClientInfo;
	[converter handleReadFromStream:aStream eventType:eventType];
}


OSStatus audioConverterCallback (AudioConverterRef converter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData,
											 AudioStreamPacketDescription *outDataPacketDescription, void *inUserData) 

{
	
	MyAudioConverterSettings *audioConverterSettings = (MyAudioConverterSettings) * inUserData;

	UInt32 ioPackets = 2048 / audioConverterSettings.bytesPerPacket;
	NSLog(@"packet size is %i", ioPackets);
	
	ioNumberDataPackets = &ioPackets;
	
	*ioData = audioConverterSettings.sourceBuffer;
		
	// use a static instance of ASPD for callback input
	AudioStreamPacketDescription aspdesc;
   	outDataPacketDescription = &aspdesc;
   	aspdesc.mDataByteSize = &audioConverterSettings.bytesPerPacket;
   	//aspdesc.mStartOffset = &AudioConversion.offset;
	aspdesc.mStartOffset = 0;
   	aspdesc.mVariableFramesInPacket = 1;
	
	return noErr;
	
}





// Audio File Stream Callback Functions 

void MyPropertyListenerProc (	void *							inClientData,
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



void MyPacketsProc(				void *							inClientData,
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
	
	void *sourceBuffer; 
	
} MyAudioConverterSettings;


//-------------streamer state structure----------------------



@implementation AudioConversion


- (void) startConversion

{
	
	AudioConverterRef converter;	
	//AudioBufferList inAudioBuffers; 
	AudioBufferList convertedData;
	AudioFileStreamID audioFileStream;
	MyAudioConverterSettings audioConverterSettings;
	
	
	
	audioConverterSettings.inASBD.mSampleRate;
	audioConverterSettings.inASBD.mFormatID = kAudioFormatMPEGLayer3;
	audioConverterSettings.inASBD.mFormatFlags = 0;
	audioConverterSettings.inASBD.mBytesPerPacket = audioConverterSettings.bytesPerPacket;
	audioConverterSettings.inASBD.mFramesPerPacket = 1; 
	audioConverterSettings.inASBD.mBytesPerFrame = 0;
	audioConverterSettings.inASBD.mChannelsPerFrame = 1;
	audioConverterSettings.inASBD.mBitsPerChannel = 16;
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
		}
		
		UInt32  complexity = kAudioConverterSampleRateConverterComplexity_Linear;
		err = AudioConverterSetProperty(converter, kAudioConverterSampleRateConverterComplexity, sizeof (complexity), &complexity);	
		//This chooses the Fs complexity property of object converter, sets it to the size 
		//of the variable, and makes it the value of the value pointed to (complexity, here).	
		
		
		
		//----------------- Figure out buffer sizes in packets and determine how to fill.-------------//
		// This section lifted directly from core audio book.
		
		packetsPerBuffer = 0; 
		outputBufferSize = 32 * 2048; // 32 KB is a good starting point. I'm using 64 KB.  
		packetsPerBuffer = outputBufferSize / audioConverterSettings.bytesPerPacket;
		
		outputBuffer = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize);
		
		UInt32 outputFilePacketPosition = 0; 
		
		while(1) 
		{
			//convertedData represents the buffer list of data out of the converter, and into OpenAL. Will have to see how this actually works. 
			
			convertedData.mNumberBuffers = 1;  //Only one buffer in BufferList receiving converted data. May have to change.
			convertedData.mBuffers[0].mNumberChannels = audioConverterSettings.inASBD.mChannelsPerFrame; //Number of channels of that buffer [0], the first and only buffer.
			convertedData.mBuffers[0].mDataByteSize = outputBufferSize;  // Its size; 
			convertedData.mBuffers[0].mData = outputBuffer; // The data itself. 
			
			UInt32 ioOutputDataPackets = packetsPerBuffer; 
			OSStatus error = AudioConverterFillComplexBuffer(converter, audioConverterCallback, &audioConverterSettings, &ioOutputDataPackets, &convertedData, NULL);
			if (error || !ioOutputDataPackets) 
			{
				break;	// This is the termination condition
			}
			
			// AudioConverterFillComplexBuffer takes the following parameters:
			// 1. A previously-created AudioConverterRef	
			// 2. A callback function, conforming to AudioConverterComplexInputDataProc, which provides the input data for conversion
			// 3. A user data pointer - the data you want back to do stuff in callback function.
			// 4. The maximum size of the output buffer, as a packet count
			// 5. A pointer to an output buffer, where the converted data is received. Is an Audio Buffer List. 
			// 6. A pointer an array of packet descriptions, if needed for the output buffer (i.e., if converting to a variable-bi- trate format)	
			// for CBR (since I am going to .caf LPCM and the mp3 stream is CBR. 
			
		}
		
		AudioConverterDispose (converter);
	}
	
	// --------------End of Core Audio Book Sample. ------------------//		
	


			
// ---------Methods called from property and audio data callback functions. -------------//
	
		
		
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
							UInt32 bPP = sizeof (audioConverterSettings.bytesPerPacket);
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
				
				for (int i = 0; i < inNumberPackets; ++i)
				{
					SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
					SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
					size_t bufSpaceRemaining;
					
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
				
				bytesPerBuffer = inNumberBytes;
				
				audioConverterSettings.sourceBuffer = (void *) calloc(1, inNumberBytes);
				UInt32 bufferSize = sizeof(audioConverterSettings.sourceBuffer);
				NSLog(@"Buffer created at size %i", bufferSize);
			
		
				memcpy (audioConverterSettings.sourceBuffer, (const char*)(inInputData), bytesPerBuffer);
				
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
					self.state = AS_STOPPED;
					
				}
			}
		}
	
	else if (eventType == kCFStreamEventHasBytesAvailable)
	{
		UInt8 bytes[2048];
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
			length = CFReadStreamRead(stream, bytes, 2048); // Reads data from stream into buffer of specified size. 
			
			if (length == -1)
			{
				
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
				
				return;
			}
		}
		else
		{
			err = AudioFileStreamParseBytes(audioFileStream, length, bytes, 0);
			if (err)
			{
				
				return;
			}
		}
	}
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



@end
