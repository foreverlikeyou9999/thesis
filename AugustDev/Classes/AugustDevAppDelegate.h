//
//  AugustDevAppDelegate.h
//  AugustDev
//
//  Created by Russell de Moose on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@class AugustDevViewController;
 
@interface AugustDevAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AugustDevViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AugustDevViewController *viewController;

@end

