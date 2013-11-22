//
//  NSArray+DCBAdditions.m
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "NSArray+DCBAdditions.h"

@implementation NSArray (DCBAdditions)


- (NSArray *)randomObjects:(NSInteger)max
{
    NSMutableArray *sourceArray = [NSMutableArray arrayWithArray:self];
    NSMutableArray *randomArray = [NSMutableArray arrayWithCapacity:max];

    while ([randomArray count] < max && [sourceArray count] > 0) {
        NSInteger index = arc4random_uniform((u_int32_t)[sourceArray count]);
        [randomArray addObject:[sourceArray objectAtIndex:index]];
    }
    return [randomArray copy];
}


@end
