//
//  audioStream.m
//  thesis_test
//
//  Created by Russell de Moose on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "audioStream.h"


@implementation audioStream

@synthesize mContext, mDevice, soundDictionary, bufferStorageArray;


/*

BOOL active = NO;

// the main method: grab the sound ID from the library
// and start the source playing
- (void) playSound:(NSString*)soundKey
{
	NSNumber * numVal = [soundDictionary objectForKey:soundKey];
	
	NSLog(@"Here are the soundKey values: %@",[soundDictionary allValues]);
	
	if (numVal == nil) return;
	NSUInteger sourceID = [numVal unsignedIntValue];
	alSourcePlay(sourceID);
	NSLog(@"Play sound method completed");
}


//stop sound 

- (void)stopSound:(NSString*)soundKey
{
	NSNumber * numVal = [soundDictionary objectForKey:soundKey];
	if (numVal == nil) return;
	NSUInteger sourceID = [numVal unsignedIntValue];
	alSourceStop(sourceID);
	
}


//some cleanup, reversing the OpenAL process

-(void)cleanUpOpenAL:(id)sender
{
	// delete the sources
	for (NSNumber * sourceNumber in [soundDictionary allValues]) {
		NSUInteger sourceID = [sourceNumber unsignedIntegerValue];
		alDeleteSources(1, &sourceID);
	}
	[soundDictionary removeAllObjects];
	
	// delete the buffers
	for (NSNumber * bufferNumber in bufferStorageArray) {
		NSUInteger bufferID = [bufferNumber unsignedIntegerValue];
		alDeleteBuffers(1, &bufferID);
	}
	[bufferStorageArray removeAllObjects];
	
	// destroy the context
	alcDestroyContext(mContext);
	// close the device
	alcCloseDevice(mDevice);
}



-(AudioFileID)openAudioFile:(NSString*)filePath
{
	
	AudioFileID outAFID;
	// use the NSURl instead of a cfurlref cuz it is easier
	NSURL * afUrl = [NSURL fileURLWithPath:filePath];
	
	// do some platform specific stuff..
#if TARGET_OS_IPHONE
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
#else
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
	if (result != 0) NSLog(@"cannot openf file: %@",filePath);
	return outAFID;
}


// find the audio portion of the file
// return the size in bytes
-(UInt32)audioFileSize:(AudioFileID)fileDescriptor
{
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if(result != 0) NSLog(@"cannot find file size");
	return (UInt32)outDataSize;
}


// start up openAL
-(void)initOpenAL
{
	// Initialization
	mDevice = alcOpenDevice(NULL); // select the "preferred device"
	
	if (mDevice) {
		// use the device to make a context
		mContext=alcCreateContext(mDevice,NULL);
		
		NSLog(@"Device opened successsfully");
		
		if (mContext)
		{
			NSLog(@"Created AL context");
		}
		
		// set my context to the currently active one
		
		alcMakeContextCurrent(mContext);
	}
}



//------------Previous code from audioPlayback class, from original OpenAL tutorial-------------//




- (NSMutableDictionary *) initializeStreamFromFile:(NSString *)fileName format:(ALenum)format freq:(ALsizei)freq {
	
	//open the file
	AudioFileID fileID = [self openAudioFile:fileName];
	
	//how big is the audio data - maybe not be applicable for streams
	//For calucation of buffers: if streaming file, may not work)
	UInt32 fileSize = [self audioFileSize:fileID];
	


//------ Feb 19 2011 -----------//

UInt32 bufferSize = 48000; // OPENAL_STREAMING_BUFFER_SIZE;
UInt32 bufferIndex = 0; // The current buffer that is full

// ok, now we build a data record for this streaming file
// before, with straight sounds this is just a sound
// but with the streaming sound, we need more info

NSMutableDictionary * record = [NSMutableDictionary dictionary];

// These are all the values, or parameters, of the streaming sound 

[record setObject:fileName forKey:@"fileName"];
[record setObject:[NSNumber numberWithUnsignedInteger:fileSize] forKey:@"fileSize"];
[record setObject:[NSNumber numberWithUnsignedInteger:bufferSize] forKey:@"bufferSize"];
[record setObject:[NSNumber numberWithUnsignedInteger:bufferIndex] forKey:@"bufferIndex"];
[record setObject:[NSNumber numberWithInteger:format] forKey:@"format"];
[record setObject:[NSNumber numberWithInteger:freq] forKey:@"freq"];
[record setObject:[NSNumber numberWithBool:NO] forKey:@"isPlaying"];


// this will hold our buffer IDs

NSMutableArray * bufferList = [NSMutableArray array];

int i;
for (i = 0; i < 3; i++) {
	
	NSUInteger bufferID;
	// grab a buffer ID from openAL
	alGenBuffers(1, &bufferID);
	
	[bufferList addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
}	

// Creates buffers without parameters, and adds them to bufferList array. Essentially creating number of threads. 

[record setObject:bufferList forKey:@"bufferList"]; // Adds to file descriptor dictionary

	AudioFileClose(fileID);
	
	return record;
	
}

     // Returns the sourceID so the object can also stop playback

- (NSUInteger)playStream:(NSString*)soundKey gain:(ALfloat)gain pitch:(ALfloat)pitch loops:(BOOL)loops
{
	// if we are not active, then dont do anything
	if (!active) return 0;
	
	ALenum err = alGetError(); // clear error code
	
	// generally the 'play sound method' would be called for all sounds
	// however if someone did call this one in error, it is nice to be able to handle it
	
	if ([[soundLibrary objectForKey:soundKey] isKindOfClass:[NSNumber class]]) {
		return [self playSound:soundKey gain:1.0 pitch:1.0 loops:loops];
		//this defaults to playSound method in audioPlayback class, for non-streaming sounds. 
	}
	

	// get our keyed sound record
	
	NSMutableDictionary * record = [soundLibrary objectForKey:soundKey];
	
	// first off, check to see if this sound is already playing. Set to NO above. 
	if ([[record objectForKey:@"isPlaying"] boolValue]) return 0;

	
	// first, find the buffer we want to play. bufferList is currently the only entry in the dictionary
	
	NSArray * bufferList = [record objectForKey:@"bufferList"];
	NSLog(@"Size of record is %u", [bufferList count]);
	
	// now find an available source
	NSUInteger sourceID = [self nextAvailableSource];
	alSourcei(sourceID, AL_BUFFER, 0);
	
	// reset the buffer index to 0. Essentially moves buffer to beginning og 
	[record setObject:[NSNumber numberWithUnsignedInteger:0] forKey:@"bufferIndex"];
	
	// queue up the first 3 buffers on the source
	for (NSNumber * bufferNumber in bufferList) {
		NSUInteger bufferID = [bufferNumber unsignedIntegerValue];
		[self loadNextStreamingBufferForSound:soundKey intoBuffer:bufferID];
		alSourceQueueBuffers(sourceID, 1, &bufferID);
		err = alGetError();
		if (err != 0) [self _error:err note:@"Error alSourceQueueBuffers!"];
	}
	
	
	 
	//Ok, this is pretty simple looking but there is the one magic method: loadNextStreamingBufferForSound: intoBuffer: I will get to this 
	//in a minute, but basically it grabs a chunk of the audio file based on the bufferIndex and loads it into the buffer. 
	//then it increments the bufferIndex so that the next time I call this method I will get the next chunk.
	//We load a chunk into every buffer in the buffer list (which in our case will be three buffers)
	//And here is the important part: (this would be the Step B part of the diagram)
	 
	
	
	alSourceQueueBuffers(sourceID, 1, &bufferID);
	
	
	
	// set the pitch and gain of the source
	alSourcef(sourceID, AL_PITCH, pitch);
	err = alGetError();
	
	if (err != 0) [self _error:err note:@"Error AL_PITCH!"];
	
	alSourcef(sourceID, AL_GAIN, gain);
	err = alGetError();
	
	if (err != 0) [self _error:err note:@"Error AL_GAIN!"];
	
	// streams should not be looping
	// we will handle that in the buffer refill code
	alSourcei(sourceID, AL_LOOPING, AL_FALSE);
	err = alGetError();
	
	if (err != 0) [self _error:err note:@"Error AL_LOOPING!"];
	
	
	
	
	// everything is queued, start the buffer playing
	alSourcePlay(sourceID);
	
	// check to see if there are any errors
	err = alGetError();
	
	if (err != 0) {
		[self _error:err note:@"Error Playing Stream!"];
		return 0;
	}
	
	
	// set up some state
	[record setObject:[NSNumber numberWithBool:YES] forKey:@"isPlaying"];
	[record setObject:[NSNumber numberWithBool:loops] forKey:@"loops"];
	[record setObject:[NSNumber numberWithUnsignedInteger:sourceID] forKey:@"sourceID"];
	
	// kick off the refill methods. Creates a new thread, 
	
	[NSThread detachNewThreadSelector:@selector(rotateBufferThread:) toTarget:self withObject:soundKey];
	return sourceID;

}

// this takes the stream record, figures out where we are in the file
// and loads the next chunk into the specified buffer

-(BOOL)loadNextStreamingBufferForSound:(NSString*)key intoBuffer:(NSUInteger)bufferID
{
	// check some escape conditions
	
	if ([soundLibrary objectForKey:key] == nil) return NO; //checks to see that there is a file there
	if (![[soundLibrary objectForKey:key] isKindOfClass:[NSDictionary class]]) return NO; //checks to see that its a stream
	
	
	// get the record, with states inititally provided
	NSMutableDictionary * record = [soundLibrary objectForKey:key];
	
	// open the file specified
	AudioFileID fileID = [self openAudioFile:[record objectForKey:@"fileName"]];
	
	
	// now we need to calculate where we are in the file
	
	UInt32 fileSize = [[record objectForKey:@"fileSize"] unsignedIntegerValue];
	UInt32 bufferSize = [[record objectForKey:@"bufferSize"] unsignedIntegerValue];
	UInt32 bufferIndex = [[record objectForKey:@"bufferIndex"] unsignedIntegerValue];;
	
	// how many chunks does the file have total?
	NSInteger totalChunks = fileSize/bufferSize;
	
	// are we past the end? if so get out
	if (bufferIndex > totalChunks) return NO;
	
	// this is where we need to start reading from the file
	NSUInteger startOffset = bufferIndex * bufferSize;
	
	// are we in the last chunk? it might not be the same size as all the others
	if (bufferIndex == totalChunks) {
		NSInteger leftOverBytes = fileSize - (bufferSize * totalChunks);
		bufferSize = leftOverBytes;
	}// this is where the audio data will live for the moment
	unsigned char * outData = malloc(bufferSize);
	
	// this where we actually get the bytes from the file and put them
	// into the data buffer
	UInt32 bytesToRead = bufferSize;
	OSStatus result = noErr;
	result = AudioFileReadBytes(fileID, false, startOffset, &bytesToRead, outData);
	if (result != 0) NSLog(@"cannot load stream: %@",[record objectForKey:@"fileName"]);
	
	// if we are past the end, and no bytes were read, then no need to Q a buffer
	// this should not happen if the math above is correct, but to be sae we will add it
	if (bytesToRead == 0) {
		free(outData);
		return NO; // no more file!
	}

	ALsizei freq = [[record objectForKey:@"freq"] intValue];
	ALenum format = [[record objectForKey:@"format"] intValue];
	
	// jam the audio data into the supplied buffer
	alBufferData(bufferID,format,outData,bytesToRead,freq);
	
	// clean up the buffer
	if (outData)
	{
		free(outData);
		outData = NULL;
	}
	
	AudioFileClose(fileID);
	
	
	//Do some cleanup.
	
	
	// increment the index so that next time we get the next chunk
	bufferIndex ++;
	// are we looping? if so then flip back to 0
	if ((bufferIndex > totalChunks) && ([[record objectForKey:@"loops"] boolValue])) {
		bufferIndex = 0;
	}
	[record setObject:[NSNumber numberWithUnsignedInteger:bufferIndex] forKey:@"bufferIndex"];
	return YES;
}

-(void)rotateBufferThread:(NSString*)soundKey
{
	// new autorelease pool because of new thread
	
	NSAutoreleasePool * apool = [[NSAutoreleasePool alloc] init];
	BOOL stillPlaying = YES;
	while (stillPlaying) {
		stillPlaying = [self rotateBufferForStreamingSound:soundKey]; // calls helper method, which runs in this thread. 
		if (interrupted) 	{
			// slow down our thread during interruptions
			[NSThread sleepForTimeInterval:kBufferRefreshDelay * 3]; //Check thread less frequently, based on Fs. 
		} else {
			// normal thread delay
			[NSThread sleepForTimeInterval:kBufferRefreshDelay]; 
		}
	}
	[apool release]; // Pool releases when stillPlaying is false, i.e. when the playback is stopped/finished.
}


//Decrease the amount of time we are checking the thread - good programming practice? 



// this checks to see if there is a buffer that has been used up.
// if it finds one then it loads the next bit of the sound into that buffer
// and puts it into the back of the queue

-(BOOL)rotateBufferForStreamingSound:(NSString*)soundKey
{
	// make sure we arent trying to stream a normal sound
	if (![[soundLibrary objectForKey:soundKey] isKindOfClass:[NSDictionary class]]) return NO;
	if (interrupted) return YES; // we are still 'playing' but we arent loading new buffers
	
	// get the keyed record
	NSMutableDictionary * record = [soundLibrary objectForKey:soundKey];
	NSUInteger sourceID = [[record objectForKey:@"sourceID"] unsignedIntegerValue];	
	
	
	First some defensive programming, if we are getting called with the wrong key then get out, if we are interrupted then we are not loading any new buffers, so get out (but return YES because we want to keep the thread alive)
		Then we grab our ubiquitous record and start to fill in some variables.
		
		
		// check to see if we are stopped
		NSInteger sourceState;
	alGetSourcei(sourceID, AL_SOURCE_STATE, &sourceState);
	if (sourceState != AL_PLAYING) {
		[record setObject:[NSNumber numberWithBool:NO] forKey:@"isPlaying"];
		return NO; // we are stopped, do not load any more buffers
	}
	
	// get the processed buffer count
	NSInteger buffersProcessed = 0;
	alGetSourcei(sourceID, AL_BUFFERS_PROCESSED, &buffersProcessed);
	
	// check to see if we have a buffer to deQ
	if (buffersProcessed > 0) {
		// great! deQ a buffer and re-fill it
		NSUInteger bufferID;
		// remove the buffer form the source
		alSourceUnqueueBuffers(sourceID, 1, &bufferID);
		// fill the buffer up and reQ!
		// if we cant fill it up then we are finished
		// in which case we dont need to re-Q
		// return NO if we dont have mroe buffers to Q
		if (![self loadNextStreamingBufferForSound:soundKey intoBuffer:bufferID]) return NO;
		// Q the loaded buffer
		alSourceQueueBuffers(sourceID, 1, &bufferID);
	}
	
	
	return YES;
}

	
*/


@end
