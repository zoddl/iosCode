//
//  DbManager.m
//  Iris
//
//  Created by apptology on 05/12/17.
//  Copyright © 2017 apptology. All rights reserved.
//

#import "DbManager.h"
@interface DbManager()
{
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
@end

@implementation DbManager
static DbManager *sharedInstance = nil;

+(DbManager*)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
    }
    return sharedInstance;
}

#pragma mark - Core Data stack


- (NSManagedObject *)createObject:(NSString *)entityName {
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return obj;
}

- (void)deleteObject:(NSManagedObject *)object {
    if(!object){
        NSLog(@"nil object delete");
    }
    @try {
        [self.managedObjectContext deleteObject:object];
    }
    @catch (NSException *exception) {
        @try {
            [self.managedObjectContext deleteObject:[self.managedObjectContext objectWithID:object.objectID]];
        }
        @catch (NSException *exception) {
        }
    }
}

- (BOOL)saveDB:(BOOL) fireNotification {
    @try {
        
        NSError *error;
        BOOL save = [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"error::%@ :: %@", error.localizedDescription,error);
        }
        return save;
    }
    @catch (NSException *exception) {
        NSLog(@"save Exp : %@",exception);
    }
    @finally {
    }
}

static NSManagedObjectContext * extracted(DbManager *object) {
    return object.managedObjectContext;
}

- (void)clearTable:(NSString *)name {
    NSFetchRequest *allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    [allCars setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *manObjs = [extracted(self) executeFetchRequest:allCars error:&error];
    //error handling goes here
    for (NSManagedObject *manObj in manObjs) {
        [self.managedObjectContext deleteObject:manObj];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    //more error handling here
}

- (NSArray *)fatchAllObjectsForEntity:(NSString *)entityName sortKey:(NSString *)sortKey ascending:(BOOL)sortAscending {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    if (sortKey) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
        [request setSortDescriptors:@[sortDescriptor]];
    }
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    return [array copy];
}

- (void)deleteObjectsForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate{
    NSArray *array = [self fatchAllObjectsForEntity:entityName withPredicate:predicate sortKey:nil ascending:NO];
    if(array && array.count>0){
        for (int i=0; i<array.count; i++) {
            NSManagedObject* obj=array[i];
            [self deleteObject:obj];
            [self saveContext];
        }
    }
}

- (NSManagedObject *)fatchObjectForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate{
    NSArray *array = [self fatchAllObjectsForEntity:entityName withPredicate:predicate sortKey:nil ascending:NO];
    if(array&&array.count>0){
        NSManagedObject *obj=array[array.count-1];
        if(array.count>1){
            //                    abort();
            NSLog(@"*** erooro \n%@",array);
        }
        for (int i=0; i<array.count-1; i++) {
            NSManagedObject* obj=array[i];
            
            [self deleteObject:obj];
        }
        
        return obj;
    }
    return nil;
}
-(NSManagedObject*)topObjectFor:(NSString*)entityName sortBy:(NSString*)sortKey ascending:(BOOL)sortAscending{
    NSArray* arr=[self fatchAllObjectsForEntity:entityName sortKey:sortKey ascending:sortAscending];
    if(arr&&arr.count>0){
        return arr[0];
    }
    return nil;
}
- (NSArray *)fatchAllObjectsForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate sortKey:(NSString *)sortKey ascending:(BOOL)sortAscending {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    if (predicate) {
        [request setPredicate:predicate];
    }
    if (sortKey) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
        [request setSortDescriptors:@[sortDescriptor]];
    }
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    return [array copy];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.prospus.DBChecker" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Iris" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return [self persistentStoreCoordinator:YES];
    
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator:(BOOL)deleteOld {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    // Create the coordinator and store
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSString *dbfileName = [NSString stringWithFormat:@"Iris.sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dbfileName];
    NSLog(@"db path: %@", storeURL);
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        if(deleteOld){
            @try {
                NSFileManager* manager=  [NSFileManager defaultManager];
                [manager removeItemAtPath:[storeURL path] error:&error];
                persistentStoreCoordinator=nil;
                return [self persistentStoreCoordinator:NO];
            }
            @catch (NSException *exception) {
                NSLog(@"error %@",exception);
            }
            @finally {
            }
        }
    }
    return persistentStoreCoordinator;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    exit(0);
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
@end
