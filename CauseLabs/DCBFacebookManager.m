//
//  DCBFacebookManager.m
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "DCBFacebookManager.h"
#import <FacebookSDK/FacebookSDK.h>


NSString * const DCBFacebookManagerDidLoginToFacebookNotification = @"DCBFacebookManagerDidLoginToFacebookNotification";
NSString * const DCBFacebookManagerDidLogoutOfFacebookNotification = @"DCBFacebookManagerDidLogoutOfFacebookNotification";


@implementation DCBFacebookManager


#pragma mark - Public


+ (BOOL)isLoggedIn
{
    return ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded);
}


+ (void)loginToFacebook
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [DCBFacebookManager sessionStateChanged:session
                                                                        state:state
                                                                        error:error];
                                  }];
}


+ (void)logoutOfFacebook
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [self sessionStateChanged:[FBSession activeSession]
                        state:FBSessionStateClosed
                        error:nil];
}


#pragma mark - Private (Facebook)


+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            [[NSNotificationCenter defaultCenter] postNotificationName:DCBFacebookManagerDidLoginToFacebookNotification
                                                                object:self];
            break;

        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [[FBSession activeSession] closeAndClearTokenInformation];
            [[NSNotificationCenter defaultCenter] postNotificationName:DCBFacebookManagerDidLogoutOfFacebookNotification
                                                                object:self];
            break;

        default:
            break;
    }

    if (error) {
        NSString *message = [error localizedDescription];
        if ([[error domain] isEqualToString:@"com.facebook.sdk"] && [error code] == 2) {
            message = @"This app is really boring without access to your Facebook account.";
        }
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook Login Error"
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


+ (void)findPlacesNearCoordinate:(CLLocationCoordinate2D)coordinate distance:(NSUInteger)distance completion:(void (^)(NSMutableArray *places, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"search?type=place&center=%f,%f&distance=%lu", coordinate.latitude, coordinate.longitude, (unsigned long)distance];
    FBRequest *request = [FBRequest requestForGraphPath:path];
    request.session = [FBSession activeSession];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSMutableArray *places = [result objectForKey:@"data"];
        if (completion) {
            completion(places, error);
        }
    }];
}


@end
