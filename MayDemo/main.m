//
//  main.m
//  MayDemo
//
//  Created by Russell de Moose on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "MayDemoViewController.h"
#import "MayDemoAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   	NSLog(@"HEY!!!!!!");
		
	int retVal = UIApplicationMain(argc, argv, nil, nil);

    [pool release];
    return retVal;
}
