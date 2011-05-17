//
//  EarthquakeEventView.m
//  EarthquakeMap
//
//  Created by Charlie Key on 8/24/09.
//  Copyright 2009 Paranoid Ferret Productions. All rights reserved.
//

#import "EarthquakeEventView.h"

@implementation EarthquakeEventView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation 
         reuseIdentifier:(NSString *)reuseIdentifier {
  if(self = [super initWithAnnotation:annotation 
                      reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation {
  super.annotation = annotation;
  if([annotation isMemberOfClass:[Annotation class]]) {
    event = (Annotation *)annotation;
  }
}

- (void)drawRect:(CGRect)rect {
 	CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextFillEllipseInRect(context, rect);
}

- (void)dealloc {
  [event release];
  [super dealloc];
}

@end
