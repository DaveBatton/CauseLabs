//
//  DCBPlace.m
//  CauseLabs
//
//  Created by Dave Batton on 11/22/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "DCBPlace.h"


@implementation DCBPlace

@dynamic facebookID;
@dynamic name;
@dynamic latitude;
@dynamic longitude;


#pragma mark - Class Methods


+ (NSString *)entityName
{
    return @"Place";
}


@end
