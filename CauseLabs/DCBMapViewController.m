//
//  DCBMapViewController.m
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "DCBMapViewController.h"
#import "DCBFacebookManager.h"
#import "NSArray+DCBAdditions.h"
#import "MRProgress.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>


const NSInteger DCBMapViewControllerMaxPlaces = 25;


@interface DCBMapViewController () <GMSMapViewDelegate>

// Outlets
@property (nonatomic, weak) IBOutlet GMSMapView *mapView;

// Private
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) GMSMarker *centerMarker;
@property (nonatomic, strong) NSMutableArray *placeMarkers;
@property (nonatomic, strong) MRProgressOverlayView *progressView;

@end


@implementation DCBMapViewController


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

    self.progressView = [[MRProgressOverlayView alloc] init];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];

    [self updateMap];
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
    [self removeAllPlaces];

    self.progressView.mode = MRProgressOverlayViewModeIndeterminate;
    self.progressView.titleLabelText = @"Loading random places from Facebook...";
    [self.progressView show:YES];

    NSUInteger meters = 1000;
    [DCBFacebookManager findPlacesNearCoordinate:self.centerMarker.position
                                        distance:meters
                                      completion:^(NSMutableArray *places, NSError *error) {
                                          self.places = [places randomObjects:25];

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
    [self removeAllPlaces];

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


- (void)removeAllPlaces
{
    // Remove all of the markers from the map (except the centerMarker).
    for (GMSMarker *marker in self.placeMarkers) {
        marker.map = nil;
    }
    [self.placeMarkers removeAllObjects];
}


- (void)savePlaces
{
    
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
                                             selector:@selector(applicationWillTerminateNotification:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}


- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self savePlaces];
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
