//
//  DCBFlipsideViewController.h
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCBFlipsideViewController;

@protocol DCBFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(DCBFlipsideViewController *)controller;
@end

@interface DCBFlipsideViewController : UIViewController

@property (weak, nonatomic) id <DCBFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
