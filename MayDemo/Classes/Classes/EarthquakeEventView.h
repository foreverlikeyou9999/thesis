//
//  EarthquakeEventView.h
//  EarthquakeMap
//
//  Created by Charlie Key on 8/24/09.
//  Copyright 2009 Paranoid Ferret Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Annotation.h"

@interface EarthquakeEventView : MKAnnotationView {
  Annotation *event;
}

@end
