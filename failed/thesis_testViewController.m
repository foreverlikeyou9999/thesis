

#import "thesis_testViewController.h"
 
 
 


@implementation thesis_testViewController
 


@synthesize map, whereabouts, audioStreamer, mContext, mDevice; 

//@synthesize soundDictionary, bufferStorageArray;



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
	
	
	// -----Mirrored from Brent Shadel code - 03-08-2011---------------//
	
	soundDictionary = [[NSMutableArray alloc] init]; // Holds arrays of records for large file lookup, as per Ben Britten example. 
	soundsloaded = NO;
	[self initOpenAL]; 
	
	// set buffer size
	bufferSize = 44100; //Fs, I guess? Gives one second one audio
	//bufferSize = 4096;
	// set numBuffers
	numBuffers = 3;
	//numBuffers = 3;
	// set filter size
	filterSize = 1;
	
	gaussianC = 0.2;
	
	
	// when format is set to mono, the freq has to be 2x 44100 = 88200 Hz
	// when set to stereo, 44100 Hz is correct
	// how is the format 16 bit when mData is an array of 8 bit UInts??
	format = AL_FORMAT_MONO16;
	freq = 44100;
	
	// -----Mirrored from Brent Shadel code - 03-08-2011---------------//
	
	
	
	
	[super viewDidLoad];	
	
}

- (void) play {
	
	
	
	
	//------------02-20-11 Test-----------//
	
	//NSMutableDictionary * soundLibrary = [audioStreamer initializeStreamFromFile:"Timmony" format:"aif" freq:44100];

	
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
	NSLog(@"outdata is this size: %c", outData);
	
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
	//alBufferData(<#ALuint bid#>, <#ALenum format#>, <#const ALvoid *data#>, <#ALsizei size#>, <#ALsizei freq#>)
	
	// save the buffer so I can release it later
	[bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
	
	NSNumber *number;
	[bufferStorageArray addObject:number];
	
	NSMutableArray *check = [NSMutableArray arrayWithCapacity:10];
	NSLog(@"test array size is %u", [check count]);
	
	NSLog(@"bufferID size is %u", bufferID);
	NSLog(@"buffer values are %u", [bufferStorageArray count]); 
	
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
	[soundDictionary setObject:[NSNumber numberWithUnsignedInt:sourceID] forKey:@"test"];	
	
	//NSLog(@"Here are the soundKey values: %@",[soundDictionary objectForKey:"test"]);
	
	// clean up the buffer
	if (outData)
	{
		free(outData);
		outData = NULL;
		NSLog(@"Buffer cleaned up");
	}
	
	// [audioPlayer prepareOpenAL];
	 [self playSound:@"test"];
	NSLog(@"Reached end of play button. Should have heard sound by now");

	// [audioPlayer cleanUpOpenAL:(id)self];
} 


//--------- Pulling methods out of separate audioPlayback class gradually-------Feb 19 2011 Test--------- //




// the main method: grab the sound ID from the library
// and start the source playing
- (void) playSound:(NSString*)soundKey
{
	NSNumber * numVal = [soundDictionary objectForKey:soundKey];
	
	NSLog(@"Number of soundKey values: %u",[soundDictionary count]);
	
	if (numVal == nil) return;
	NSUInteger sourceID = [numVal unsignedIntValue];
	alSourcePlay(sourceID);
	NSLog(@"Play sound method completed");


}

/*	
 
 //stop sound 
 
 - (IBAction)stopSound:(NSString*)soundKey
 {
 NSNumber * numVal = [soundDictionary objectForKey:soundKey];
 if (numVal == nil) return;
 NSUInteger sourceID = [numVal unsignedIntValue];
 alSourceStop(sourceID);
 }	
 
 */

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


