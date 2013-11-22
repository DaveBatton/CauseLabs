//
//  DCBPlace.h
//  CauseLabs
//
//  Created by Dave Batton on 11/22/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DCBPlace : NSManagedObject

@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
