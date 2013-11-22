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

@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

+ (NSString *)entityName;

@end
