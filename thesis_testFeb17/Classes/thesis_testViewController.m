

#import "thesis_testViewController.h"
 
 
 


@implementation thesis_testViewController
 


@synthesize map, whereabouts, play, audioPlayer; 

//@synthesize mContext, mDevice, soundDictionary, bufferStorageArray, audioPlayer;



//@synthesize locationManager;



/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	
		

	[super viewDidLoad];
}	
	
	
	/*
	
	// start up openAL
	[self initOpenAL];
	
		
	
	// get the full path of the file
	NSString* fileName = [[NSBundle mainBundle] pathForResource:@"03 Building Fully Sprinkled" ofType:@"aif"];
	if (fileName) {
		NSLog(@"filename exists and is: %d", fileName);
	}
	
	// first, open the file
	AudioFileID fileID = [self openAudioFile:fileName];
	if (fileID ) {
		NSLog(@"fileID exists");
	}
	
	// find out how big the actual audio data is
	UInt32 fileSize = [self audioFileSize:fileID];
	NSLog(@" filesize is %i", fileSize);
	
	
	
	
	
	// this is where the audio data will live for the moment
	unsigned char * outData = malloc(fileSize);
	NSLog(@"outData is the following size: %i", sizeof(outData));
	
	// this where we actually get the bytes from the file and put them
	// into the data buffer
	
	OSStatus result = noErr;
	result = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);
	AudioFileClose(fileID); //close the file
	
	if (result != 0) NSLog(@"cannot load effect: %@",fileName);
	
	NSUInteger bufferID; //unsigned int
	
	// grab a buffer ID from openAL. Method to generate buffers. 
	
	alGenBuffers(1, &bufferID);
	if (alGenBuffers) NSLog(@"OpenAL just generated a buffer.");
	
	// jam the audio data into the new buffer
	alBufferData(bufferID,AL_FORMAT_STEREO16,outData,fileSize,44100);
	if (alBufferData) NSLog(@"Now there's an audio buffer");
	
	// save the buffer so I can release it later
	[bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
	
	NSUInteger sourceID;
	

	// grab a source ID from openAL
	alGenSources(1, &sourceID); 
	
	// attach the buffer to the source
	alSourcei(sourceID, AL_BUFFER, bufferID);
	// set some basic source prefs
	alSourcef(sourceID, AL_PITCH, 1.0f);
	alSourcef(sourceID, AL_GAIN, 1.0f);
	
	
	//if (loops) alSourcei(sourceID, AL_LOOPING, AL_TRUE);
	
	// store this for future use
	[soundDictionary setObject:[NSNumber numberWithUnsignedInt:sourceID] forKey:@"03 Building Fully Sprinkled.aif"];	
	
	// clean up the buffer
	if (outData)
	{
		free(outData);
		outData = NULL;
	}
	
}	






	
	// the main method: grab the sound ID from the library
	// and start the source playing
	- (IBAction)playSound:(NSString*)soundKey
	{
		NSNumber * numVal = [soundDictionary objectForKey:soundKey];
		if (numVal == nil) return;
		NSUInteger sourceID = [numVal unsignedIntValue];
		alSourcePlay(sourceID);
	}






	
	
	//stop sound 
	
	- (IBAction)stopSound:(NSString*)soundKey
	{
		NSNumber * numVal = [soundDictionary objectForKey:soundKey];
		if (numVal == nil) return;
		NSUInteger sourceID = [numVal unsignedIntValue];
		alSourceStop(sourceID);
	}








// open the audio file
// returns a big audio ID struct

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
	
	
	// Override point for customization after application launch
    // Add the view controller's view to the window and display.
	
}	
	
	






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
	
	
	*/

	 
- (IBAction) playFile: (id) sender {  
	 
	 [audioPlayer initOpenAL]; 

	
	NSLog(@"I'm actually doing something here, stupid button press.");
	
	
	
	NSString* fileName = [[NSBundle mainBundle] pathForResource:@"Timmony" ofType:@"aif"];
	NSLog(@"%@", fileName); //prints the location of the file
	
	if (fileName) {
		NSLog(@"The filename was created. Presumably, the path exists too.");
	}
	
	
	// first, open the file
	AudioFileID fileID = [self openAudioFile:fileName];
	//AudioFileID fileID = [audioPlayer openAudioFile:fileName];
	if (fileID) { 
		NSLog(@"The file ID is open");
	}
	
	
	// find out how big the actual audio data is
	//UInt32 fileSize = [audioPlayer audioFileSize:fileID];
	
	UInt32 fileSize = [self audioFileSize:fileID];
	NSLog(@"The filesize is %u", fileSize);
	
	
	
	
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
	[audioPlayer.bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
	
	NSLog(@"Still going strong.");
	
	
	
	NSUInteger sourceID;
	
	// grab a source ID from openAL
	alGenSources(1, &sourceID); 
	
	// attach the buffer to the source
	alSourcei(sourceID, AL_BUFFER, bufferID);
	// set some basic source prefs
	alSourcef(sourceID, AL_PITCH, 1.0f);
	alSourcef(sourceID, AL_GAIN, 1.0f);
	//if (loops) alSourcei(sourceID, AL_LOOPING, AL_TRUE);
	
	// store this for future use
	[audioPlayer.soundDictionary setObject:[NSNumber numberWithUnsignedInt:sourceID] forKey:@"test"];	
	
	// clean up the buffer
	if (outData)
	{
		free(outData);
		outData = NULL;
		NSLog(@"Buffer cleaned up");
	}
	
	
	
	
	// [audioPlayer prepareOpenAL];
	 [audioPlayer playSound:@"test"];
	NSLog(@"Reached end of play button. Should have heard sound by now");

	// [audioPlayer cleanUpOpenAL:(id)self];
} 
	
/*	
	
	if (player) {
		NSLog(@"Well, there's a player here");
		[player pause];
	} else {
		NSURL *url = [[NSURL URLWithString:@"http://204.93.192.135:80/q2.aac"] retain]; 
		AVPlayer *player = [[AVPlayer playerWithURL:url] retain];
		[player play];
	}

 */

	
	
	/*
	
	[self playSound:soundKey];
	NSLog(@"playing...");

	
}

- (IBAction) stopFile: (id) sender {
	
	[self stopSound:(NSString *)soundKey];
	NSLog(@"I just stopped playing. OH SADNESS.");

}
	 
	 */
	
	//-----------------------------------------------------// 


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {

    [super dealloc];
}






//-----------Testing having helper methods not in separate class-------------//

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


@end


