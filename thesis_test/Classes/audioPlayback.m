//
//  audioPlayback.m
//  thesis_test
//
//  Created by Russell de Moose on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "audioPlayback.h"


@implementation audioPlayback /*


// start up openAL
-(void)initOpenAL
{
	// Initialization
	mDevice = alcOpenDevice(NULL); // select the "preferred device"
	if (mDevice) {
		// use the device to make a context
		mContext=alcCreateContext(mDevice,NULL);
		// set my context to the currently active one
		alcMakeContextCurrent(mContext);
	}
}


// get the full path of the file
NSString* fileName = [[NSBundle mainBundle] pathForResource:@"03 Building Fully Sprinkled" ofType:@"aif"];

// first, open the file
AudioFileID fileID = [self openAudioFile:fileName];


// find out how big the actual audio data is
UInt32 fileSize = [self audioFileSize:fileID];



// this is where the audio data will live for the moment
unsigned char * outData = malloc(fileSize);

// this where we actually get the bytes from the file and put them
// into the data buffer

OSStatus result = noErr;
result = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);
AudioFileClose(fileID); //close the file

if (result != 0) NSLog(@"cannot load effect: %@",fileName);

NSUInteger bufferID; //unsigned int

// grab a buffer ID from openAL. Method to generate buffers. 
 
alGenBuffers(1, &bufferID);

// jam the audio data into the new buffer
alBufferData(bufferID,AL_FORMAT_STEREO16,outData,fileSize,44100); 

// save the buffer so I can release it later
[bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];




// grab a source ID from openAL
alGenSources(1, &sourceID); 

// attach the buffer to the source
alSourcei(sourceID, AL_BUFFER, bufferID);
// set some basic source prefs
alSourcef(sourceID, AL_PITCH, 1.0f);
alSourcef(sourceID, AL_GAIN, 1.0f);
if (loops) alSourcei(sourceID, AL_LOOPING, AL_TRUE);

// store this for future use
[soundDictionary setObject:[NSNumber numberWithUnsignedInt:sourceID] forKey:@"03 Building Fully Sprinkled"];	

// clean up the buffer
if (outData)
{
	free(outData);
	outData = NULL;
}



// the main method: grab the sound ID from the library
// and start the source playing
- (void)playSound:(NSString*)soundKey
{
	NSNumber * numVal = [soundDictionary objectForKey:soundKey];
	if (numVal == nil) return;
	NSUInteger sourceID = [numVal unsignedIntValue];
	alSourcePlay(sourceID);
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


*/
@end
