//
//  fmodStreamer.m
//  AugustDev
//
//  Created by Russell de Moose on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fmodStreamer.h"


@implementation fmodStreamer

@synthesize url;


const float distanceFactor = 1.0f;
char audioBuffer[2000] = {0};

FMOD_RESULT result = FMOD_OK;


/* FMOD Methods */


//-----------------------------------------//
void ERRORCHECK(FMOD_RESULT result)
{
    if (result != FMOD_OK)
    {
        fprintf(stderr, "FMOD error! (%d) %s\n", result, FMOD_ErrorString(result));
        exit(-1);
    }
}
//-----------------------------------------//


//-----------------------------------------//
//- (void)startStream:(NSMutableArray *)whichStation
- (void)startStream:(NSString *)whichStation

{
	
	/* From previous viewDidLoad method. Moved in an attempt to MVC this billy. */
	
	system  = NULL;
    sound   = NULL;
    channel = NULL;
	version = 0;
	
	listenerpos.x = 30.0f;
	listenerpos.y = 0.0f;
	listenerpos.z = -1.0f * distanceFactor;
	
	/* End MVC change. */
	

	
    /*
	 Create a System object and initialize
	 */    
    result = FMOD::System_Create(&system); 
    ERRORCHECK(result);
    
    result = system->getVersion(&version);
    ERRORCHECK(result);
    
    if (version < FMOD_VERSION)
    {
        fprintf(stderr, "You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
        exit(-1);
    }
	
    result = system->init(1, FMOD_INIT_NORMAL | FMOD_INIT_ENABLE_PROFILE, NULL);
    ERRORCHECK(result);
	
	
	NSLog(@"FMOD system started");
    
	
	/*----Change to match audioStreamer buffer size
	 result = system->setStreamBufferSize(64 * 1024, FMOD_TIMEUNIT_RAWBYTES); 
	 */
	
	result = system->setStreamBufferSize(64 * 2048, FMOD_TIMEUNIT_RAWBYTES);
    ERRORCHECK(result); 
	
	NSLog(@"FMOD stream size set");
	/*
	 Set the distance units. (meters/feet etc)
	 */
	// result = system->set3DSettings(1.0, distanceFactor, 1.0f);
	//ERRCHECK(result);   
	
	urlStream= [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(play:) userInfo:nil repeats:YES];
	
	
	
	//--------------------------------------------------------------//

	
	FMOD_CREATESOUNDEXINFO info;
	
	info.suggestedsoundtype = FMOD_SOUND_TYPE_MPEG;
	memset(&info, 0, sizeof(FMOD_CREATESOUNDEXINFO));
	info.cbsize = sizeof(FMOD_CREATESOUNDEXINFO);
	info.suggestedsoundtype = FMOD_SOUND_TYPE_MPEG;
	
	//url = @"http://www.jiwok.com/uploads/staticworkouts/french/AE_RUN_30_8L_1000000.mp3";
	//url = @"http://www.fmod.org/stream.mp3";
	//url = @"http://wfuv-onair.streamguys.org:80/onair-hi";
	url = whichStation;
	//url = [whichStation objectAtIndex:0];
	NSLog(@"%@", url);
	
	[url getCString:audioBuffer maxLength:200 encoding:NSASCIIStringEncoding];     
	result = system->createSound(audioBuffer, FMOD_SOFTWARE | FMOD_2D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound);
	//result = system->createSound(audioBuffer, FMOD_SOFTWARE | FMOD_3D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound);

	
	
	ERRORCHECK(result); 
	
	NSLog(@"Sound created");
	
	//result = channel->set3DAttributes(&pos, &vel);
	//ERRORCHECK(result);

}
//-----------------------------------------//



//-----------------------------------------//
- (void)restartStream
{
	NSLog(@"System restarting.");
	
	
	/* From previous viewDidLoad method. Moved in an attempt to MVC this billy. */
	
	system  = NULL;
    sound   = NULL;
    channel = NULL;
	version = 0;
	
	listenerpos.x = 30.0f;
	listenerpos.y = 0.0f;
	listenerpos.z = -1.0f * distanceFactor;
	
	/* End MVC change. */
	
	
	
    /*
	 Create a System object and initialize
	 */  
	
	result = FMOD::System_Create(&system); 
    ERRORCHECK(result);
	
	result = system->init(1, FMOD_INIT_NORMAL | FMOD_INIT_ENABLE_PROFILE, NULL);
    ERRORCHECK(result);
       
    result = system->getVersion(&version);
    ERRORCHECK(result);
    
    if (version < FMOD_VERSION)
    {
        fprintf(stderr, "You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
        exit(-1);
    }
	
   	NSLog(@"FMOD system restarted");
    
	
	/*----Change to match audioStreamer buffer size
	 result = system->setStreamBufferSize(64 * 1024, FMOD_TIMEUNIT_RAWBYTES); 
	 */
	
	result = system->setStreamBufferSize(64 * 2048, FMOD_TIMEUNIT_RAWBYTES);
    ERRORCHECK(result); 
	
	NSLog(@"FMOD stream size set");
	/*
	 Set the distance units. (meters/feet etc)
	 */
	// result = system->set3DSettings(1.0, distanceFactor, 1.0f);
	//ERRCHECK(result);   
	
	urlStream= [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(play:) userInfo:nil repeats:YES];
	
	
	
	//--------------------------------------------------------------//
	
	
	FMOD_CREATESOUNDEXINFO info;
	
	info.suggestedsoundtype = FMOD_SOUND_TYPE_MPEG;
	memset(&info, 0, sizeof(FMOD_CREATESOUNDEXINFO));
	info.cbsize = sizeof(FMOD_CREATESOUNDEXINFO);
	info.suggestedsoundtype = FMOD_SOUND_TYPE_MPEG;
	
	//url = @"http://www.jiwok.com/uploads/staticworkouts/french/AE_RUN_30_8L_1000000.mp3";
	//url = @"http://www.fmod.org/stream.mp3";
	//url = @"http://wfuv-onair.streamguys.org:80/onair-hi";
	url = @"http://wnycfm.streamguys.com/";
	
	[url getCString:audioBuffer maxLength:200 encoding:NSASCIIStringEncoding];     
	result = system->createSound(audioBuffer, FMOD_SOFTWARE | FMOD_2D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound);
	//result = system->createSound(audioBuffer, FMOD_SOFTWARE | FMOD_3D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound);

	
	
	ERRORCHECK(result); 
	
	NSLog(@"Sound created");
	
	//result = channel->set3DAttributes(&pos, &vel);
	//ERRORCHECK(result);
	
}



- (void) play:(NSTimer *)urlStream

{
	/*
	 Main loop 
	 */    

    FMOD_OPENSTATE  openstate       = (FMOD_OPENSTATE)0;
    unsigned int    percentbuffered = 0;
    bool            starving        = false;
    bool            playing         = false;

    
    if (sound != NULL)
    {
        //result = sound->getOpenState(&openstate, &percentbuffered, &starving);
		result = sound->getOpenState(&openstate, &percentbuffered, &starving, &playing);
        if (result == FMOD_ERR_FILE_NOTFOUND)
        {
            sound->release();
            sound = NULL; 
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Not Found" message:@"The URL specified could not be found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            [errorAlert release];
        }
        else
        {
            ERRORCHECK(result);
			NSLog(@"URL Found?");
        }
        
        if ((openstate == FMOD_OPENSTATE_READY) && (channel == NULL))
        {
            result = system->playSound(FMOD_CHANNEL_FREE, sound, false, &channel);
            ERRORCHECK(result);
			NSLog(@"");			
        }
    }
    
    if (channel != NULL)
    {
        while (true)
        {
            FMOD_TAG tag;
            
            result = sound->getTag(NULL, -1, &tag);
            if (result == FMOD_ERR_TAGNOTFOUND)
            {
                break;
            }
            ERRORCHECK(result);            
            
		}
        
        result = channel->isPlaying(&playing);
        ERRORCHECK(result);
        
        result = channel->getPaused(&paused);
        ERRORCHECK(result);
        
        result = channel->setMute(starving);
        ERRORCHECK(result);
    } 
	
    result = system->update();
    ERRORCHECK(result);

}
//-----------------------------------------//
					   
					   
- (void) fmodKill 

{
	
	NSLog(@"Killing FMOD? Big jerk.");
	
	if (channel != NULL)
	{
		channel->stop();
		channel = NULL;
	}
	
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

- (void) killSoundForMenu

{
	
	NSLog(@"Don't like this station? Bigger jerk.");
	
	if (channel != NULL)
	{
		channel->stop();
		channel = NULL;
	}
	
	if (sound)
	{
		sound->release();
		sound = NULL;
	}
	
	[urlStream invalidate];
	
	
	/*
	 if (system)
	 {
	 system->release();
	 system = NULL;
	 }    
	 
	 */
	
}


//-----------------------------------------//
- (void)changePan:(float)panRatio
{
	

	NSLog(@"pan is %f",panRatio);
	//result = channel->setPan(panRatio);
	result = channel->setPan(panRatio);

	ERRORCHECK(result);
	
} 

//-----------------------------------------//

- (void)pause
{
	
	if (paused == false)
		
	{
		
		result = channel->getPaused(&paused);
		ERRORCHECK(result);
		
		result = channel->setPaused(!paused);
		ERRORCHECK(result);
		NSLog(@"system paused");
	
	}
	else 
	{
		NSLog(@"play again");
		
		result = channel->getPaused(&paused);
		ERRORCHECK(result);
		
		result = channel->setPaused(!paused);
		ERRORCHECK(result);

	}
}
//-----------------------------------------//

@end
