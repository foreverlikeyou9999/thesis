//
//  Annotation.h
//  thesis_test 
//
//  Created by Russell de Moose on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Annotation : NSObject <MKAnnotation> 

{

	NSNumber *latitude;
	NSNumber *longitude;
	//CLLocationCoordinate2D coordinate;
	
	
}

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

//2-axis coordinates, as only property of MKAnnotation.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSString *)title;
- (NSString *)subtitle;
- (CLLocationCoordinate2D)setCoordinate;



@end

