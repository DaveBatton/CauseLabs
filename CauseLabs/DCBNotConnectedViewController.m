//
//  DCBNotConnectedViewController.m
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "DCBNotConnectedViewController.h"
#import "DCBFacebookManager.h"


@interface DCBNotConnectedViewController ()

@end


@implementation DCBNotConnectedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Actions


- (IBAction)loginToFacebook
{
    [DCBFacebookManager loginToFacebook];
}


@end
