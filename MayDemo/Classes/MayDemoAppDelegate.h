//
//  MayDemoAppDelegate.h
//  MayDemo
//
//  Created by Russell de Moose on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MayDemoViewController;

@interface MayDemoAppDelegate : NSObject <UIApplicationDelegate> {
	
    UIWindow *window;
    MayDemoViewController *viewController;
	//UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MayDemoViewController *viewController;
//@property (nonatomic, retain) UINavigationController *navigationController;




@end
