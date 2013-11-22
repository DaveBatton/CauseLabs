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
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>


@interface DCBAppDelegate ()

//@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

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
    [self saveContext];
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


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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


#pragma mark - Core Data


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CauseLabs" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CauseLabs.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}


@end
