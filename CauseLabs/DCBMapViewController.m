//
//  DCBMapViewController.m
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "DCBMapViewController.h"
#import "DCBFacebookManager.h"
#import "DCBDataManager.h"
#import "DCBPlace.h"
#import "NSArray+DCBAdditions.h"
#import "MRProgress.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>


const NSInteger DCBMapViewControllerMaxPlaces = 25;


@interface DCBMapViewController () <GMSMapViewDelegate>

// Outlets
@property (nonatomic, weak) IBOutlet GMSMapView *mapView;

// Private
@property (nonatomic, strong) NSArray *places;  // Facebook FBGraphPlace objects.
@property (nonatomic, strong) GMSMarker *centerMarker;  // We search around this location.
@property (nonatomic, strong) NSMutableArray *placeMarkers;  // Google GMSMarker objects.
@property (nonatomic, strong) MRProgressOverlayView *progressView;

@end


@implementation DCBMapViewController


#pragma mark - Setup & Teardown


- (void)dealloc
{
    [self stopListeningForNotifications];
}


#pragma mark - UIViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.delegate = self;

    self.centerMarker = [[GMSMarker alloc] init];
    self.centerMarker.title = @"Center of Attention";
    self.centerMarker.snippet = @"Drag to Change";
    self.centerMarker.position = CLLocationCoordinate2DMake(39.750655, -104.999127);  // Default position dictated by CauseLabs.;
    self.centerMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    self.centerMarker.draggable = YES;
    self.centerMarker.map = self.mapView;

    self.placeMarkers = [NSMutableArray arrayWithCapacity:DCBMapViewControllerMaxPlaces];
    [self loadSavedPlaces];

    self.progressView = [[MRProgressOverlayView alloc] init];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];

    [self updateMap];

    [self startListeningForNotifications];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([self.places count] == 0) {
        [self loadNewPlaces];
    }
}


#pragma mark - Private


- (void)loadNewPlaces
{
    [self removeAllPlaceMarkers];

    self.progressView.mode = MRProgressOverlayViewModeIndeterminate;
    self.progressView.titleLabelText = @"Loading random places from Facebook...";
    [self.progressView show:YES];

    NSUInteger meters = 1000;
    [DCBFacebookManager findPlacesNearCoordinate:self.centerMarker.position
                                        distance:meters
                                      completion:^(NSMutableArray *places, NSError *error) {
                                          self.places = [places randomObjects:DCBMapViewControllerMaxPlaces];

                                          self.progressView.mode = MRProgressOverlayViewModeCheckmark;
                                          self.progressView.titleLabelText = [NSString stringWithFormat:@"%lu places found.", (unsigned long)[self.places count]];
                                          [self.progressView show:self.progressView.hidden];

                                          double delayInSeconds = 2.0;
                                          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                          dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                              [self.progressView hide:YES];

                                              // This is a work-around for a bug in MRProgress.
                                              double delayInSeconds = 1.0;
                                              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                              dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                  for (UIView *subview in self.progressView.subviews) {
                                                      subview.transform = CGAffineTransformIdentity;
                                                  }
                                              });
                                          });

                                      }];
}


- (void)updateMap
{
    [self removeAllPlaceMarkers];

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.self.centerMarker.position coordinate:self.centerMarker.position];

    for (id<FBGraphPlace> place in self.places) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.title = [place name];
        marker.position = CLLocationCoordinate2DMake([[[place location] latitude] floatValue], [[[place location] longitude] floatValue]);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = self.mapView;

        [self.placeMarkers addObject:marker];

        bounds = [bounds includingCoordinate:marker.position];
    }

    double delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:20.0f];
        [self.mapView animateWithCameraUpdate:update];
    });
}


- (void)removeAllPlaceMarkers
{
    // Remove all of the markers from the map (except the centerMarker).
    for (GMSMarker *marker in self.placeMarkers) {
        marker.map = nil;
    }
    [self.placeMarkers removeAllObjects];
}


- (void)savePlaces
{
    [[DCBDataManager sharedDataManager] deleteAllPlaces];

    for (id<FBGraphPlace> place in self.places) {
        [[DCBDataManager sharedDataManager] addPlaceWithID:place.id
                                                      name:place.name
                                                  latitude:[place.location.latitude floatValue]
                                                 longitude:[place.location.longitude floatValue]];
    }

    [[DCBDataManager sharedDataManager] saveContext];
}


- (void)loadSavedPlaces
{
    NSArray *savedPlaces = [[DCBDataManager sharedDataManager] places];  // These are DCBPlace objects.

    NSMutableArray *places = [NSMutableArray arrayWithCapacity:[savedPlaces count]];  // These will be FBGraphPlace objects.

    for (DCBPlace *savedPlace in savedPlaces) {
        id<FBGraphPlace> place = (FBGraphObject<FBGraphPlace> *)[FBGraphObject graphObject];
        place.id = savedPlace.facebookID;
        place.name = savedPlace.name;
        place.location = (FBGraphObject<FBGraphLocation> *)[FBGraphObject graphObject];
        place.location.latitude = savedPlace.latitude;
        place.location.longitude = savedPlace.longitude;
        [places addObject:place];
    }

    self.places = [places copy];
}


#pragma mark - GMSMapViewDelegate


- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadNewPlaces];
    });
}


#pragma mark - Notifications


- (void)startListeningForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookManagerDidLogoutOfFacebook:)
                                                 name:DCBFacebookManagerDidLogoutOfFacebookNotification
                                               object:nil];
}


- (void)stopListeningForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DCBFacebookManagerDidLogoutOfFacebookNotification
                                                  object:nil];
}


- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self savePlaces];
}


- (void)facebookManagerDidLogoutOfFacebook:(NSNotification *)notification
// Clear any data we got from the user's account.
{
    self.places = nil;
    [self.placeMarkers removeAllObjects];
    [self updateMap];
}


#pragma mark - Actions


- (IBAction)refresh
{
    [self loadNewPlaces];
}


- (IBAction)logoutOfFacebook
{
    [DCBFacebookManager logoutOfFacebook];
}


#pragma mark - Accessors


- (void)setPlaces:(NSArray *)places
{
    if ([_places isEqualToArray:places] == NO) {
        _places = places;
        [self updateMap];
    }
}


@end
