//
//  DCBAppDelegate.m
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "DCBAppDelegate.h"
#import "DCBMapViewController.h"
#import "DCBNotConnectedViewController.h"
#import "DCBFacebookManager.h"
#import "DCBDataManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>


@interface DCBAppDelegate ()

@property (strong, nonatomic) UINavigationController *navigationController;

@end


@implementation DCBAppDelegate


#pragma mark - UIApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:@"AIzaSyClga5kY_T2PLzjH6UyRGJHGTfnLAIRvOo"];

    self.navigationController = (UINavigationController *)self.window.rootViewController;
    [self.window makeKeyAndVisible];

    if ([DCBFacebookManager isLoggedIn] == NO) {
        [self presentNotConnectedViewControllerAnimated:NO];
    }

    [self startListeningForNotifications];

    return YES;
}
							

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSession activeSession] handleOpenURL:url];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[FBSession activeSession] handleDidBecomeActive];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [[DCBDataManager sharedDataManager] saveContext];
}


#pragma mark - Private


- (void)presentNotConnectedViewControllerAnimated:(BOOL)animated
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    DCBNotConnectedViewController *loginViewController = (DCBNotConnectedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DCBNotConnectedViewController"];
    [self.navigationController presentViewController:loginViewController
                                                              animated:animated
                                                            completion:NULL];
}


#pragma mark - Notifications


- (void)startListeningForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookManagerDidLoginToFacebook:)
                                                 name:DCBFacebookManagerDidLoginToFacebookNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookManagerDidLogoutOfFacebook:)
                                                 name:DCBFacebookManagerDidLogoutOfFacebookNotification
                                               object:nil];
}


- (void)facebookManagerDidLoginToFacebook:(NSNotification *)notification
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)facebookManagerDidLogoutOfFacebook:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self presentNotConnectedViewControllerAnimated:YES];
}


@end
