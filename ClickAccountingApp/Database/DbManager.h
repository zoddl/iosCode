//
//  DbManager.h
//  Iris
//
//  Created by apptology on 05/12/17.
//  Copyright © 2017 apptology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>


@interface DbManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
+(DbManager*)getSharedInstance;
- (void)saveContext;
- (NSArray *)fatchAllObjectsForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate sortKey:(NSString *)sortKey ascending:(BOOL)sortAscending;
- (void)deleteObjectsForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate;
- (void)deleteObject:(NSManagedObject *)object;
- (void)clearTable:(NSString *)name;
@end
