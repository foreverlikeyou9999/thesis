//
//  Annotation.m
//  thesis_test
//
//  Created by Russell de Moose on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h" 

 
@implementation Annotation

@synthesize latitude, longitude;
@synthesize coordinate;


- (CLLocationCoordinate2D)setCoordinate
{
    CLLocationCoordinate2D theCoordinate  = {self.latitude, self.longitude};

	return theCoordinate; 
}


- (NSString *)subtitle{
	return @"128kbps audio stream";
}
- (NSString *)title{
	return @"Streaming Audio Source";
}



@end
