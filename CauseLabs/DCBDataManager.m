//
//  DCBDataManager.m
//  CauseLabs
//
//  Created by Dave Batton on 11/21/13.
//  Copyright (c) 2013 Dave Batton. All rights reserved.
//

#import "DCBDataManager.h"

@implementation DCBDataManager


#pragma mark - Public


- (void)addPlaceWithID:(NSString *)ID Name:(NSString *)name latitude:(float)latitude longitude:(float)longitude
{
    NSManagedObject *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                               inManagedObjectContext:self.managedObjectContext];
    [place setValue:ID forKey:@"facebookID"];
    [place setValue:name forKey:@"name"];
    [place setValue:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [place setValue:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
}


- (void)deleteAllPlaces
{
    [self deleteAllObjects:@"Places"];
}


#pragma mark - Private


- (void)deleteAllObjects:(NSString *)entityDescription
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    for (NSManagedObject *managedObject in items) {
    	[self.managedObjectContext deleteObject:managedObject];
    }

    if (![self.managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@", entityDescription, error);
    }
}


@end
