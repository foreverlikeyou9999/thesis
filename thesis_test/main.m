//
//  main.m
//  thesis_test
//
//  Created by Russell de Moose on 1/30/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "audioPlayback.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    
	audioPlayback *audio = [[audioPlayback alloc] init];
	
	[audio initOpenAL]; 
	NSLog(@"I'm actually doing something here, stupid button press.");
	[audio prepareOpenAL];
	[audio playSound:@"03 Building Fully Sprinkled.aif"];
	
	
	
	[pool release];
    return retVal;
	
	
}
