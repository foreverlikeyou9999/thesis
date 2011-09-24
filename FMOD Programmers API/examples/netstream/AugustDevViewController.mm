#import "AugustDevViewController.h"

@implementation AugustDevViewController



@synthesize time;
@synthesize status;
@synthesize buffered;
@synthesize lasttag;
@synthesize urltext, panner; 
 

- (void)viewDidLoad
{
	[self createStreamer];
}

- (void)createStreamer
{
	if (stream)
	{
		return;
	}
	
	[stream stop];
	[stream fmodKill];
	
	NSString *escapedValue =
	[(NSString *)CFURLCreateStringByAddingPercentEscapes(
														 nil,
														 //(CFStringRef)@"http://www.jiwok.com/uploads/staticworkouts/french/AE_RUN_30_8L_1000000.mp3",
														 (CFStringRef)@"http://204.93.192.135:80/q2.aac",											 
														 NULL,
														 NULL,
														 kCFStringEncodingUTF8)
	 autorelease];
	
	NSURL *url = [NSURL URLWithString:escapedValue];
	stream = [[AudioStreamer_Sept alloc] initWithURL:url];
	[stream start];
}

-(IBAction)pannerMoved:(id)sender {
	
	[stream changePan:panner.value];

}


- (void)viewWillDisappear:(BOOL)animated
{
    /*
	 Shut down
	 */    
    [timer invalidate];
    
    [stream fmodKill];

}


- (IBAction)pauseResume:(id)sender
{
    [stream pause];		
}


- (void)dealloc 
{  
	[time release];
	[status release];
	[buffered release];
	[lasttag release]; 
	[stream release];
	[super dealloc];
}

@end