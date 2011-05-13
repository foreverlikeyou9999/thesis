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
//@synthesize coordinate;


- (CLLocationCoordinate2D)setCoordinate 
{
	//CLLocationCoordinate2D coord = {self.latitude, self.longitude};
	CLLocationCoordinate2D coord;
	coord.latitude = 40.75;
	coord.longitude = -73.9844722;
	return coord;
}


- (NSString *)subtitle{
	return @"something about audio";
}
- (NSString *)title{
	return @"Times Square";
}



@end
