//
//  DCBDataManager.h
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCBDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)addPlaceWithID:(NSString *)ID Name:(NSString *)name latitude:(float)latitude longitude:(float)longitude;
- (void)deleteAllPlaces;

@end
