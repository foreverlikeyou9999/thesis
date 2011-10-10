//
//  fmodStreamer.m
//  AugustDev
//
//  Created by Russell de Moose on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "fmodStreamer.h"


@implementation fmodStreamer

@synthesize url, url2, url3, search;

//const float distanceFactor = 1.0f;
char audioBuffer[200] = {0};
char audioBuffer2[200] = {0};
char audioBuffer3[200] = {0};

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
- (void)createSystem

{
	
	/* From previous viewDidLoad method. Moved in an attempt to MVC this billy. */
	
	system  = NULL;
    sound   = NULL;
	sound2	= NULL;
	sound3  = NULL;
    channel = NULL;
    channel2 = NULL;
    channel3 = NULL;
	version = 0;

	//Create a System object and initialize
    result = FMOD::System_Create(&system); 
    ERRORCHECK(result);
    
    result = system->getVersion(&version);
    ERRORCHECK(result);
    
    if (version < FMOD_VERSION)
    {
        fprintf(stderr, "You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
        exit(-1);
    }
	
    result = system->init(3, FMOD_INIT_NORMAL | FMOD_INIT_ENABLE_PROFILE, NULL);
    ERRORCHECK(result);	
	
	NSLog(@"FMOD system started");

	//result = system->setStreamBufferSize(64 * 512  OR MAYBE 1024, FMOD_TIMEUNIT_RAWBYTES);
	result = system->setStreamBufferSize(64 * 2048, FMOD_TIMEUNIT_RAWBYTES);
	
    ERRORCHECK(result); 
	
	NSLog(@"FMOD stream size set");

}

- (void)startStream:(NSString *)first andAlso:(NSString *)second andAlso:(NSString *)third
//- (void)startStream:(NSString *)whichStation
{	
    url = first;
    url2 = second;
    url3 = third;
    

	//Create sound descriptor for createSound, specifying stream type.	
	FMOD_CREATESOUNDEXINFO info;	
	info.suggestedsoundtype = FMOD_SOUND_TYPE_MPEG;
	memset(&info, 0, sizeof(FMOD_CREATESOUNDEXINFO));
	info.cbsize = sizeof(FMOD_CREATESOUNDEXINFO);
	info.suggestedsoundtype = FMOD_SOUND_TYPE_MPEG;
    
//---HEY HEY HEY THIS ONE WORKS---//
  //  url = whichStation;
    search = @"http";
    
    if ([url rangeOfString:search].location == NSNotFound)
    {
          NSLog(@"First stream is not valid.");
        
    }    
    else 
    {
        urlStream= [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(play:) userInfo:nil repeats:YES];
        [url getCString:audioBuffer maxLength:200 encoding:NSASCIIStringEncoding];     
        result = system->createSound(audioBuffer, FMOD_SOFTWARE | FMOD_2D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound);
        NSLog(@"Sound found.");
    }
    

    if ([url2 rangeOfString:search].location == NSNotFound)
    {
        NSLog(@"Second stream is not valid.");
        
    }    
    else 
    {
        urlStream2= [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(play2:) userInfo:nil repeats:YES];
        [url2 getCString:audioBuffer2 maxLength:200 encoding:NSASCIIStringEncoding];     
        result = system->createSound(audioBuffer2, FMOD_SOFTWARE | FMOD_2D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound2);
        NSLog(@"Sound2 found.");
    }
    
    if ([url3 rangeOfString:search].location == NSNotFound)
    {
        NSLog(@"Third stream is not valid.");
        
    }    
    else 
    {
        urlStream3= [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(play3:) userInfo:nil repeats:YES];
        [url3 getCString:audioBuffer3 maxLength:200 encoding:NSASCIIStringEncoding];     
        result = system->createSound(audioBuffer3, FMOD_SOFTWARE | FMOD_2D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound3);
        NSLog(@"Sound3 found.");
    }
  
	//Haven't gotten to 3D yet. So it goes. 
	//result = system->createSound(audioBuffer, FMOD_SOFTWARE | FMOD_3D | FMOD_CREATESTREAM | FMOD_MPEGSEARCH | FMOD_IGNORETAGS | FMOD_NONBLOCKING, &info, &sound);	
	
	ERRORCHECK(result); 

}
//-----------------------------------------//



//-----------------------------------------//
- (void)restartStream
{

	//put stuff from startStream in here. Keep the same. 
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
    
    if (sound != NULL || sound2 != NULL || sound3 != NULL)
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
            NSLog(@"Playing stream one.");
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
    
    
- (void) play2:(NSTimer *)urlStream2
{
   
    FMOD_OPENSTATE  openstate2       = (FMOD_OPENSTATE)0;
    unsigned int    percentbuffered2 = 0;
    bool            starving2        = false; 
    bool            playing2         = false;
   

    
    if (sound2 != NULL )
    {
       
        result = sound2->getOpenState(&openstate2, &percentbuffered2, &starving2, &playing2);
        
        if (result == FMOD_ERR_FILE_NOTFOUND)
        {
            sound2->release();
            sound2 = NULL; 
                      
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Not Found" message:@"The 2nd URL specified could not be found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [errorAlert show];
            [errorAlert release];
        }
        else
        {
            ERRORCHECK(result);
			NSLog(@"2nd URL Found?");
        }

        if ((openstate2 == FMOD_OPENSTATE_READY) && (channel2 == NULL))
        {
            result = system->playSound(FMOD_CHANNEL_FREE, sound2, false, &channel2);
            ERRORCHECK(result);
            NSLog(@"Playing stream two.");
			
        }
        
    }  
    
    if (channel2 != NULL)
    {
        while (true)
        {
            FMOD_TAG tag;
            
            result = sound2->getTag(NULL, -1, &tag);
            if (result == FMOD_ERR_TAGNOTFOUND)
            {
                break;
            }
            ERRORCHECK(result);            
        }
        
        result = channel2->isPlaying(&playing2);
            ERRORCHECK(result);
        result = channel2->getPaused(&paused);
            ERRORCHECK(result);
        result = channel2->setMute(starving2);
            ERRORCHECK(result);
    } 
   
    result = system->update();
    ERRORCHECK(result);
}
 

- (void) play3:(NSTimer *)urlStream3
{
    

    FMOD_OPENSTATE  openstate3       = (FMOD_OPENSTATE)0;
    unsigned int    percentbuffered3 = 0;
    bool            starving3        = false;
    bool            playing3        = false;

    
    // ---------Third stream. Should combine these into a simpler method soon.-------------//
    
    if (sound3 != NULL )
    {
        
        result = sound3->getOpenState(&openstate3, &percentbuffered3, &starving3, &playing3);
        
        if (result == FMOD_ERR_FILE_NOTFOUND)
        {
            sound3->release();
            sound3 = NULL; 
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Not Found" message:@"The 3rd URL specified could not be found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [errorAlert show];
            [errorAlert release];
        }
        else
        {
            ERRORCHECK(result);
			NSLog(@"3rd URL Found?");
        }
        
        if ((openstate3 == FMOD_OPENSTATE_READY) && (channel3 == NULL))
        {
            result = system->playSound(FMOD_CHANNEL_FREE, sound3, false, &channel3);
            ERRORCHECK(result);
            NSLog(@"Playing stream three.");
			
        }
        
    }
    
    if (channel3 != NULL)
    {
        while (true)
        {
            FMOD_TAG tag;
            
            result = sound3->getTag(NULL, -1, &tag);
            if (result == FMOD_ERR_TAGNOTFOUND)
            {
                break;
            }
            ERRORCHECK(result);            
		}
        
        result = channel3->isPlaying(&playing3);
        ERRORCHECK(result);
        result = channel3->getPaused(&paused);
        ERRORCHECK(result);
        result = channel3->setMute(starving3);
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

	result = channel->setPan(panRatio);

	ERRORCHECK(result);
	
} 

//-----------------------------------------//

//-----------------------------------------//
- (void)setVolume:(float)volume
{

	result = channel->setVolume(volume);
	
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

       if (channel2 != NULL)
       {
        result = channel2->setPaused(!paused);
		ERRORCHECK(result);
		NSLog(@"system paused");
       }
        if (channel3 != NULL)
        {
            result = channel2->setPaused(!paused);
            ERRORCHECK(result);
            NSLog(@"system paused");
        }
	}
	else 
	{
		NSLog(@"play again");
		
		result = channel->getPaused(&paused);
		ERRORCHECK(result);
		
		result = channel->setPaused(!paused);
		ERRORCHECK(result);
        
        if (channel2 != NULL)
        {
            result = channel2->setPaused(!paused);
            ERRORCHECK(result);
            NSLog(@"system paused");
        }
        if (channel3 != NULL)
        {
            result = channel2->setPaused(!paused);
            ERRORCHECK(result);
            NSLog(@"system paused");
        }

	}
}
//-----------------------------------------//

@end
