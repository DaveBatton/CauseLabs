//
//  DCBDataManager.h
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCBDataManager : NSObject

+ (DCBDataManager *)sharedDataManager;

- (void)addPlaceWithID:(NSString *)ID name:(NSString *)name latitude:(float)latitude longitude:(float)longitude;
- (NSArray *)places;
- (void)deleteAllPlaces;
- (void)saveContext;

@end
