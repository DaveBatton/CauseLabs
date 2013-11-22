//
//  DCBAppDelegate.h
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#define APPDELEGATE ((DCBAppDelegate *)[UIApplication sharedApplication].delegate)

#import <UIKit/UIKit.h>

@interface DCBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
