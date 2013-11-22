//
//  DCBFacebookManager.h
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const DCBFacebookManagerDidLoginToFacebookNotification;
extern NSString * const DCBFacebookManagerDidLogoutOfFacebookNotification;


@interface DCBFacebookManager : NSObject

+ (BOOL)isLoggedIn;
+ (void)loginToFacebook;
+ (void)logoutOfFacebook;
+ (void)findPlacesNearCoordinate:(CLLocationCoordinate2D)coordinate distance:(NSUInteger)distance completion:(void (^)(NSMutableArray *places, NSError *error))completion;

@end
